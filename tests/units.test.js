// SPDX-FileCopyrightText: 2026 Franco Pellegrini
// SPDX-License-Identifier: GPL-2.0-or-later

const assert = require("assert/strict");
const U = require("./load")("units.js");

const KiB = 1024, MiB = 1024 * KiB;
const bin = { bits: false, decimal: false, prefix: 0, decimals: 1, locale: null };
const opt = (o) => Object.assign({}, bin, o);

// formatRate
assert.equal(U.formatRate(0, bin), "0 B/s");
assert.equal(U.formatRate(512, bin), "512 B/s");
assert.equal(U.formatRate(1536, bin), "1.5 KiB/s");
assert.equal(U.formatRate(2.25 * MiB, opt({ decimals: 2 })), "2.25 MiB/s");
assert.equal(U.formatRate(1023.97 * KiB, bin), "1.0 MiB/s", "rounding rolls over to next prefix");
assert.equal(U.formatRate(1023, bin), "1023 B/s");
assert.equal(U.formatRate(1000, opt({ decimal: true })), "1.0 kB/s");
assert.equal(U.formatRate(125000, opt({ bits: true, decimal: true })), "1.0 Mb/s");
assert.equal(U.formatRate(128, opt({ bits: true })), "1.0 Kib/s");
assert.equal(U.formatRate(3 * KiB, opt({ prefix: 2, decimals: 3 })), "0.003 MiB/s");
assert.equal(U.formatRate(5 * MiB, opt({ prefix: 1, decimals: 0 })), "5120 KiB/s");
assert.equal(U.formatRate(-5, bin), "0 B/s");
assert.equal(U.formatRate(undefined, bin), "0 B/s");

// formatBytes
assert.equal(U.formatBytes(0, bin), "0 B");
assert.equal(U.formatBytes(1.5 * 1024 * MiB, bin), "1.5 GiB");
assert.equal(U.formatBytes(2500000, opt({ decimal: true, bits: true })), "2.5 MB", "totals ignore bits");

// niceCeil, binary
assert.equal(U.niceCeil(0, 1024), 1);
assert.equal(U.niceCeil(1, 1024), 1);
assert.equal(U.niceCeil(3, 1024), 5);
assert.equal(U.niceCeil(100 * KiB, 1024), 100 * KiB);
assert.equal(U.niceCeil(101 * KiB, 1024), 200 * KiB);
assert.equal(U.niceCeil(600 * KiB, 1024), 1000 * KiB);
assert.equal(U.niceCeil(1010 * KiB, 1024), MiB, "1000 KiB is followed by 1 MiB");
assert.equal(U.niceCeil(1.5 * MiB, 1024), 2 * MiB);
assert.equal(U.niceCeil(2.1 * MiB, 1024), 5 * MiB);
assert.equal(U.niceCeil(6 * MiB, 1024), 10 * MiB);
// decimal
assert.equal(U.niceCeil(999, 1000), 1000);
assert.equal(U.niceCeil(1001, 1000), 2000);
assert.equal(U.niceCeil(45e6, 1000), 50e6);

// autoRange
assert.equal(U.autoRange(0, 100 * KiB, 0, bin), 100 * KiB, "floor applies when idle");
assert.equal(U.autoRange(1.5 * MiB, 100 * KiB, 0, bin), 2 * MiB);
assert.equal(U.autoRange(3 * MiB, 100 * KiB, 2 * MiB, bin), 5 * MiB, "steps up");
assert.equal(U.autoRange(0.8 * MiB, 100 * KiB, 5 * MiB, bin), 1000 * KiB, "steps down");
assert.equal(U.autoRange(0.98 * MiB, 100 * KiB, 2 * MiB, bin), 2 * MiB, "hysteresis near the lower step");
// bits: 1 MiB/s = 8 Mib/s -> 10 Mib/s
assert.equal(U.autoRange(MiB, 0, 0, opt({ bits: true })), 10 * MiB / 8);

// widestTexts covers what formatRate produces
for (const o of [bin, opt({ decimal: true }), opt({ bits: true }), opt({ decimals: 3 })]) {
    const widest = Math.max(...U.widestTexts(o).map((s) => s.length));
    for (let v = 1; v < 1e12; v *= 1.37) {
        assert.ok(U.formatRate(v, o).length <= widest, `${U.formatRate(v, o)} wider than reserved`);
    }
}
assert.deepEqual(Array.from(U.widestTexts(opt({ prefix: 2 }))), ["99999.9 MiB/s"]);

console.log("units: ok");

// axis
assert.equal(U.axisIntervals(5 * MiB, bin), 5);
assert.equal(U.axisIntervals(2 * MiB, bin), 4);
assert.equal(U.axisIntervals(100 * KiB, bin), 4);
assert.deepEqual(Array.from(U.axisLabels(5 * MiB, 5, bin)), ["0 MiB/s", "1 MiB/s", "2 MiB/s", "3 MiB/s", "4 MiB/s", "5 MiB/s"]);
assert.deepEqual(Array.from(U.axisLabels(MiB, 4, bin)), ["0.00 MiB/s", "0.25 MiB/s", "0.50 MiB/s", "0.75 MiB/s", "1.00 MiB/s"]);
assert.deepEqual(Array.from(U.axisLabels(200 * KiB, 4, bin)), ["0 KiB/s", "50 KiB/s", "100 KiB/s", "150 KiB/s", "200 KiB/s"]);
assert.deepEqual(Array.from(U.axisLabels(10 * MiB / 8, 4, opt({ bits: true }))), ["0.0 Mib/s", "2.5 Mib/s", "5.0 Mib/s", "7.5 Mib/s", "10.0 Mib/s"]);
console.log("axis: ok");

// stacked
assert.equal(U.formatRate(1536, opt({ separator: "\n" })), "1.5\nKiB/s");
assert.deepEqual(Array.from(U.widestTexts(opt({ separator: "\n", decimals: 0 }))), ["1023\nB/s", "1024\nKiB/s", "1024\nMiB/s", "1024\nGiB/s"]);
console.log("stacked: ok");
