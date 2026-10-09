// SPDX-FileCopyrightText: 2026 Franco Pellegrini
// SPDX-License-Identifier: GPL-2.0-or-later
//
// Pure unit formatting and range helpers. No QML dependencies so the
// node tests can load this file directly.
//
// `opts` everywhere is { bits, decimal, prefix, decimals, locale }:
//   bits     - show bits/s instead of bytes/s
//   decimal  - 1000-based prefixes instead of 1024-based
//   prefix   - 0 auto, 1 K, 2 M, 3 G
//   decimals - digits after the separator (0 below the K prefix)
//   locale   - Qt.locale() or null (falls back to toFixed)
//   separator - between number and unit, " " when unset ("\n" stacks them)

var MAX_PREFIX = 4;

function unitBase(opts) {
    return opts.decimal ? 1000 : 1024;
}

function rateSuffixes(opts) {
    if (opts.bits) {
        return opts.decimal
            ? ["b/s", "kb/s", "Mb/s", "Gb/s", "Tb/s"]
            : ["b/s", "Kib/s", "Mib/s", "Gib/s", "Tib/s"];
    }
    return opts.decimal
        ? ["B/s", "kB/s", "MB/s", "GB/s", "TB/s"]
        : ["B/s", "KiB/s", "MiB/s", "GiB/s", "TiB/s"];
}

function sizeSuffixes(opts) {
    return opts.decimal
        ? ["B", "kB", "MB", "GB", "TB"]
        : ["B", "KiB", "MiB", "GiB", "TiB"];
}

function formatNumber(value, decimals, locale) {
    if (locale) {
        return Number(value).toLocaleString(locale, "f", decimals);
    }
    return Number(value).toFixed(decimals);
}

function autoPrefix(value, base) {
    if (!(value > 0)) {
        return 0;
    }
    var p = Math.floor(Math.log(value) / Math.log(base));
    return Math.max(0, Math.min(MAX_PREFIX, p));
}

// Scales `value` (already in the display unit) to a prefix. In auto mode a
// value that would round up to `base` (e.g. 1023.97 -> "1024.0") moves on
// to the next prefix instead.
function scale(value, base, prefix, decimals) {
    var auto = prefix <= 0;
    var p = auto ? autoPrefix(value, base) : prefix;
    var d = p === 0 ? 0 : decimals;
    var mantissa = value / Math.pow(base, p);
    if (auto && p < MAX_PREFIX) {
        var f = Math.pow(10, d);
        if (Math.round(mantissa * f) / f >= base) {
            p += 1;
            d = decimals;
            mantissa = value / Math.pow(base, p);
        }
    }
    return { mantissa: mantissa, prefix: p, decimals: d };
}

function separator(opts) {
    return opts.separator || " ";
}

function formatRate(bytesPerSec, opts) {
    var v = Math.max(0, bytesPerSec || 0) * (opts.bits ? 8 : 1);
    var s = scale(v, unitBase(opts), opts.prefix, opts.decimals);
    return formatNumber(s.mantissa, s.decimals, opts.locale) + separator(opts) + rateSuffixes(opts)[s.prefix];
}

// Byte counts (totals) are always shown in bytes, auto prefix.
function formatBytes(bytes, opts) {
    var s = scale(Math.max(0, bytes || 0), unitBase(opts), 0, opts.decimals);
    return formatNumber(s.mantissa, s.decimals, opts.locale) + " " + sizeSuffixes(opts)[s.prefix];
}

// Smallest 1/2/5 x 10^k x base^n that is >= value. Steps never cross into
// the next prefix in odd places: 1000 KiB is followed by 1 MiB, not 2000 KiB.
function niceCeil(value, base) {
    if (!(value > 0)) {
        return 1;
    }
    var eps = 1e-9;
    var e = Math.max(0, Math.floor(Math.log(value) / Math.log(base) + eps));
    var unit = Math.pow(base, e);
    var m = value / unit;
    var d = Math.pow(10, Math.floor(Math.log(m) / Math.LN10 + eps));
    var n = m / d;
    var step = n <= 1 + eps ? 1 : n <= 2 + eps ? 2 : n <= 5 + eps ? 5 : 10;
    var result = step * d;
    if (result > base) {
        result = base;
    }
    return result * unit;
}

// Auto range in bytes/s. Snapping happens in the displayed unit so bit
// ranges land on round bit values. Keeps `current` when the candidate is
// lower but the peak sits right under it, to avoid flapping between steps.
function autoRange(peak, floor, current, opts) {
    var f = opts.bits ? 8 : 1;
    var candidate = niceCeil(Math.max(peak, floor) * f, unitBase(opts)) / f;
    if (current > 0 && candidate < current && peak > 0.95 * candidate) {
        return current;
    }
    return candidate;
}

// Strings at least as wide as anything formatRate can produce with these
// options, used to reserve a stable label width.
function widestTexts(opts) {
    var base = unitBase(opts);
    var suffixes = rateSuffixes(opts);
    var out = [];
    if (opts.prefix > 0) {
        out.push(formatNumber(99999.9, opts.decimals, opts.locale) + separator(opts) + suffixes[opts.prefix]);
        return out;
    }
    var nines = base === 1024 ? 1023.9 : 999.9;
    out.push(formatNumber(base - 1, 0, opts.locale) + separator(opts) + suffixes[0]);
    for (var p = 1; p <= 3; ++p) {
        out.push(formatNumber(nines, opts.decimals, opts.locale) + separator(opts) + suffixes[p]);
    }
    return out;
}

// Number of grid intervals for a niceCeil'd range so every line lands on a
// round value: 5 -> 1 2 3 4 5, 1 and 2 -> quarters.
function axisIntervals(range, opts) {
    var v = range * (opts.bits ? 8 : 1);
    var base = unitBase(opts);
    var m = v / Math.pow(base, autoPrefix(v, base));
    var lead = m / Math.pow(10, Math.floor(Math.log(m) / Math.LN10 + 1e-9));
    return Math.round(lead) === 5 ? 5 : 4;
}

// Labels for 0..range in `intervals` steps, all with the range's prefix and
// the fewest decimals that keep them exact.
function axisLabels(range, intervals, opts) {
    var f = opts.bits ? 8 : 1;
    var base = unitBase(opts);
    var p = opts.prefix > 0 ? opts.prefix : autoPrefix(range * f, base);
    var unit = Math.pow(base, p);
    var mantissas = [];
    for (var i = 0; i <= intervals; ++i) {
        mantissas.push(range * f * i / intervals / unit);
    }
    var d = 0;
    while (d < 3 && mantissas.some(function (m) {
        return Math.abs(m * Math.pow(10, d) - Math.round(m * Math.pow(10, d))) > 1e-6;
    })) {
        ++d;
    }
    var suffix = rateSuffixes(opts)[p];
    return mantissas.map(function (m) {
        return formatNumber(m, d, opts.locale) + " " + suffix;
    });
}
