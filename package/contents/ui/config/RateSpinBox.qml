// SPDX-FileCopyrightText: 2026 Franco Pellegrini
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import "../code/units.js" as Units

// Edits a rate stored in bytes/s, shown as a whole number with a K/M/G
// prefix in the unit family the user picked.
RowLayout {
    id: control

    // bytes/s
    property real value: 0
    property bool bits: false
    property bool decimal: false

    signal edited()

    readonly property var _opts: ({ bits: bits, decimal: decimal })
    readonly property real _factor: bits ? 8 : 1
    readonly property real _base: Units.unitBase(_opts)
    property bool _syncing: false

    function _sync() {
        const v = value * _factor;
        const p = Math.max(1, Math.min(3, Units.autoPrefix(v, _base)));
        _syncing = true;
        number.value = Math.round(v / Math.pow(_base, p));
        prefix.currentIndex = p - 1;
        _syncing = false;
    }

    function _commit() {
        if (_syncing) {
            return;
        }
        // Keep what the user typed instead of re-normalizing it.
        _syncing = true;
        value = number.value * Math.pow(_base, prefix.currentIndex + 1) / _factor;
        _syncing = false;
        edited();
    }

    onValueChanged: if (!_syncing) _sync()
    on_OptsChanged: _sync()
    Component.onCompleted: _sync()

    QQC2.SpinBox {
        id: number
        from: 1
        to: 99999
        editable: true
        onValueModified: control._commit()
    }

    QQC2.ComboBox {
        id: prefix
        model: Units.rateSuffixes(control._opts).slice(1, 4)
        onActivated: control._commit()
    }
}
