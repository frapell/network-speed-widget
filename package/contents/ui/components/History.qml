// SPDX-FileCopyrightText: 2026 Franco Pellegrini
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick

import "../code/history.js" as H

// Owns the sample buffer. The buffer is a plain JS array mutated in place;
// everything derived from it is returned as fresh values.
QtObject {
    id: history

    // How far back samples are kept, in ms.
    property real maxAgeMs: 15 * 60 * 1000

    property var _buffer: []

    function push(sample) {
        H.push(_buffer, sample, maxAgeMs);
    }

    function clear() {
        _buffer = [];
    }

    function peak(windowMs, now, key) {
        return H.peak(_buffer, windowMs, now, key);
    }

    function stats(windowMs, now, key) {
        return H.stats(_buffer, windowMs, now, key);
    }

    function series(windowMs, now, points, key) {
        return H.bucketSeries(_buffer, windowMs, now, points, key);
    }
}
