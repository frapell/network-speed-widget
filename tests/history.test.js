// SPDX-FileCopyrightText: 2026 Franco Pellegrini
// SPDX-License-Identifier: GPL-2.0-or-later

const assert = require("assert/strict");
const H = require("./load")("history.js");

function filled(n, rate, ok = () => true) {
    const buf = [];
    for (let i = 1; i <= n; ++i) {
        H.push(buf, { t: i * 1000, dt: 1, down: rate(i), up: rate(i) / 2, ok: ok(i) }, 1e9);
    }
    return buf;
}

// push trims by age
{
    const buf = [];
    for (let i = 0; i < 100; ++i) {
        H.push(buf, { t: i * 1000, dt: 1, down: i, up: 0, ok: true }, 10000);
    }
    assert.equal(buf.length, 11);
    assert.equal(buf[0].t, 89000);
}

// peak only looks at the window
{
    const buf = filled(100, (i) => (i === 10 ? 5000 : 100));
    assert.equal(H.peak(buf, 200000, 100000, "down"), 5000);
    assert.equal(H.peak(buf, 60000, 100000, "down"), 100);
    assert.equal(H.peak([], 60000, 0, "down"), 0);
}

// stats
{
    const buf = filled(10, (i) => i * 100);
    const s = H.stats(buf, 1e9, 10000, "down");
    assert.equal(s.current, 1000);
    assert.equal(s.peak, 1000);
    assert.equal(s.total, 5500);
    assert.equal(s.average, 550);
    assert.equal(H.stats(buf, 1e9, 10000, "up").total, 2750);
    // window of 3 s -> samples at 8, 9, 10 s
    const w = H.stats(buf, 2000, 10000, "down");
    assert.equal(w.total, 2700);
    assert.equal(w.average, 900);
}

// not-ok samples are excluded
{
    const buf = filled(4, () => 1000, (i) => i !== 4);
    const s = H.stats(buf, 1e9, 4000, "down");
    assert.equal(s.current, 1000);
    assert.equal(s.total, 3000);
    const none = H.stats(filled(3, () => 9, () => false), 1e9, 3000, "down");
    assert.deepEqual({ ...none }, { current: 0, average: 0, peak: 0, total: 0 });
}

// bucketSeries: newest first, max per bucket, fixed length
{
    const buf = filled(10, (i) => (i === 3 ? 900 : i));
    const series = Array.from(H.bucketSeries(buf, 10000, 10000, 5, "down"));
    // ages 0,1 -> b0; 2,3 -> b1; ... age 7 (t=3000) -> b3
    assert.deepEqual(series, [10, 8, 6, 900, 2]);
    const sparse = Array.from(H.bucketSeries(filled(2, () => 7), 60000, 2000, 6, "down"));
    assert.deepEqual(sparse, [7, 0, 0, 0, 0, 0]);
    assert.equal(H.bucketSeries([], 1000, 0, 0, "down").length, 0);
}

console.log("history: ok");
