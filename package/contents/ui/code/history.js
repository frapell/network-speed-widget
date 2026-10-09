// SPDX-FileCopyrightText: 2026 Franco Pellegrini
// SPDX-License-Identifier: GPL-2.0-or-later
//
// Pure ring-buffer helpers for throughput samples. A sample is
// { t: ms timestamp, dt: seconds covered, down: B/s, up: B/s, ok: bool }.
// Samples are appended in time order; `key` is "down" or "up".

// Appends `sample` and drops everything older than `maxAgeMs`.
function push(buf, sample, maxAgeMs) {
    buf.push(sample);
    var cutoff = sample.t - maxAgeMs;
    var drop = 0;
    while (drop < buf.length && buf[drop].t < cutoff) {
        ++drop;
    }
    if (drop > 0) {
        buf.splice(0, drop);
    }
    return buf;
}

// Highest rate within the last `windowMs` before `now`.
function peak(buf, windowMs, now, key) {
    var cutoff = now - windowMs;
    var best = 0;
    for (var i = buf.length - 1; i >= 0; --i) {
        var s = buf[i];
        if (s.t < cutoff) {
            break;
        }
        if (s.ok && s[key] > best) {
            best = s[key];
        }
    }
    return best;
}

// current, time-weighted average, peak and bytes transferred in the window.
function stats(buf, windowMs, now, key) {
    var cutoff = now - windowMs;
    var current = 0;
    var haveCurrent = false;
    var best = 0;
    var total = 0;
    var seconds = 0;
    for (var i = buf.length - 1; i >= 0; --i) {
        var s = buf[i];
        if (s.t < cutoff) {
            break;
        }
        if (!s.ok) {
            continue;
        }
        var v = s[key];
        if (!haveCurrent) {
            current = v;
            haveCurrent = true;
        }
        if (v > best) {
            best = v;
        }
        total += v * s.dt;
        seconds += s.dt;
    }
    return {
        current: current,
        average: seconds > 0 ? total / seconds : 0,
        peak: best,
        total: total
    };
}

// Fixed-length series for the chart, index 0 = newest. Each bucket keeps
// its maximum so short bursts survive downsampling; empty buckets are 0.
function bucketSeries(buf, windowMs, now, points, key) {
    var out = new Array(points);
    for (var j = 0; j < points; ++j) {
        out[j] = 0;
    }
    if (points <= 0) {
        return out;
    }
    var width = windowMs / points;
    for (var i = buf.length - 1; i >= 0; --i) {
        var s = buf[i];
        var age = now - s.t;
        if (age >= windowMs) {
            break;
        }
        if (!s.ok) {
            continue;
        }
        var idx = Math.min(points - 1, Math.max(0, Math.floor(age / width)));
        if (s[key] > out[idx]) {
            out[idx] = s[key];
        }
    }
    return out;
}
