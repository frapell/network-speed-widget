// SPDX-FileCopyrightText: 2026 Franco Pellegrini
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.components as PlasmaComponents3

import "../code/units.js" as Units

// Rate label that reserves the width of the widest possible value, so the
// panel item doesn't jitter as numbers change.
PlasmaComponents3.Label {
    id: label

    property real value: 0
    property var opts
    property bool available: true
    property string arrow: ""

    readonly property real reservedWidth: {
        metrics.font; // re-measure when the font changes
        return widthFor(opts);
    }

    // Puts the arrow after the first line, so with right alignment the
    // arrows stay in one column whatever the number's width.
    function withArrow(t) {
        if (arrow.length === 0) {
            return t;
        }
        const lines = t.split("\n");
        lines[0] += " " + arrow;
        return lines.join("\n");
    }

    // Width needed for any value formatted with `o`, line by line when the
    // separator stacks number and unit.
    function widthFor(o) {
        const texts = Units.widestTexts(o).concat(["—"]);
        let widest = 0;
        for (const t of texts) {
            for (const line of withArrow(t).split("\n")) {
                widest = Math.max(widest, metrics.advanceWidth(line));
            }
        }
        return Math.ceil(widest) + 1;
    }

    text: withArrow(available ? Units.formatRate(value, opts) : "—")
    textFormat: Text.PlainText
    horizontalAlignment: Text.AlignRight
    verticalAlignment: Text.AlignVCenter
    font.features: { "tnum": 1 }
    elide: Text.ElideNone

    Layout.minimumWidth: reservedWidth
    Layout.preferredWidth: reservedWidth

    FontMetrics {
        id: metrics
        font: label.font
    }
}
