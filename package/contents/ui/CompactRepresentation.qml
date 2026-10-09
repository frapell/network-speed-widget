// SPDX-FileCopyrightText: 2026 Franco Pellegrini
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

import "components"

Item {
    id: compact

    readonly property var cfg: Plasmoid.configuration
    readonly property bool vertical: Plasmoid.formFactor === PlasmaCore.Types.Vertical

    // 0 text right, 1 text left, 2 bars only, 3 text only
    readonly property int textPosition: cfg.textPosition
    readonly property real barLength: Kirigami.Units.gridUnit * Math.max(1, cfg.barLengthUnits)

    readonly property bool useSmallFont: !vertical && height < 2 * defaultMetrics.height

    // Vertical panels try progressively narrower text: one line, number
    // stacked over unit, then stacked without decimals.
    readonly property var verticalCandidates: [
        root.unitOpts,
        Object.assign({}, root.unitOpts, { separator: "\n" }),
        Object.assign({}, root.unitOpts, { separator: "\n", decimals: 0 })
    ]
    readonly property int verticalFit: {
        if (!vertical) {
            return -1;
        }
        for (let i = 0; i < verticalCandidates.length; ++i) {
            if (width >= verticalDown.widthFor(verticalCandidates[i])) {
                return i;
            }
        }
        return -1;
    }
    readonly property var verticalOpts: verticalCandidates[Math.max(0, verticalFit)]

    readonly property bool textFits: vertical
        ? verticalFit >= 0
        : height >= 2 * smallMetrics.height
    readonly property bool showText: textPosition !== 2 && textFits
    // Text-only falls back to bars when the text has nowhere to go.
    readonly property bool showBars: textPosition !== 3 || !showText

    readonly property string downArrow: cfg.showArrows ? "↓" : ""
    readonly property string upArrow: cfg.showArrows ? "↑" : ""

    Layout.minimumWidth: vertical ? -1 : horizontalLayout.implicitWidth
    Layout.preferredWidth: vertical ? -1 : horizontalLayout.implicitWidth
    Layout.maximumWidth: vertical ? -1 : horizontalLayout.implicitWidth
    Layout.minimumHeight: vertical ? verticalLayout.implicitHeight : -1
    Layout.preferredHeight: vertical ? verticalLayout.implicitHeight : -1
    Layout.maximumHeight: vertical ? verticalLayout.implicitHeight : -1

    FontMetrics {
        id: defaultMetrics
        font: Kirigami.Theme.defaultFont
    }

    FontMetrics {
        id: smallMetrics
        font: Kirigami.Theme.smallFont
    }

    component DirectionRow: RowLayout {
        id: row

        property real value
        property real maximum
        property color color
        property string arrow

        spacing: Kirigami.Units.smallSpacing
        layoutDirection: compact.textPosition === 1 ? Qt.RightToLeft : Qt.LeftToRight

        SpeedBar {
            visible: compact.showBars
            value: row.value
            maximum: row.maximum
            color: row.color
            Layout.preferredWidth: compact.barLength
            Layout.preferredHeight: Math.max(2, Math.round(row.height * 0.7))
            Layout.alignment: Qt.AlignVCenter
        }

        SpeedText {
            visible: compact.showText
            value: row.value
            opts: root.unitOpts
            available: root.sensorsOk
            arrow: row.arrow
            font: compact.useSmallFont ? Kirigami.Theme.smallFont : Kirigami.Theme.defaultFont
            Layout.fillHeight: true
        }
    }

    ColumnLayout {
        id: horizontalLayout

        visible: !compact.vertical
        anchors {
            top: parent.top
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        spacing: 0

        DirectionRow {
            value: root.downRate
            maximum: root.rangeDown
            color: compact.cfg.downloadColor
            arrow: compact.downArrow
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
        DirectionRow {
            value: root.upRate
            maximum: root.rangeUp
            color: compact.cfg.uploadColor
            arrow: compact.upArrow
            Layout.fillHeight: true
            Layout.fillWidth: true
        }
    }

    ColumnLayout {
        id: verticalLayout

        visible: compact.vertical
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
        }
        spacing: Kirigami.Units.smallSpacing

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: Kirigami.Units.smallSpacing
            visible: compact.showBars

            readonly property real barWidth: Math.max(2, Math.min(Kirigami.Units.gridUnit * 0.6,
                                                                  (compact.width - spacing) / 2))

            SpeedBar {
                vertical: true
                value: root.downRate
                maximum: root.rangeDown
                color: compact.cfg.downloadColor
                Layout.preferredWidth: parent.barWidth
                Layout.preferredHeight: compact.barLength
            }
            SpeedBar {
                vertical: true
                value: root.upRate
                maximum: root.rangeUp
                color: compact.cfg.uploadColor
                Layout.preferredWidth: parent.barWidth
                Layout.preferredHeight: compact.barLength
            }
        }

        SpeedText {
            id: verticalDown
            visible: compact.showText
            value: root.downRate
            opts: compact.verticalOpts
            available: root.sensorsOk
            arrow: compact.downArrow
            font: Kirigami.Theme.smallFont
            // Right-aligned when arrows are shown so they line up.
            horizontalAlignment: compact.cfg.showArrows ? Text.AlignRight : Text.AlignHCenter
            Layout.fillWidth: true
        }
        SpeedText {
            visible: compact.showText
            value: root.upRate
            opts: compact.verticalOpts
            available: root.sensorsOk
            arrow: compact.upArrow
            font: Kirigami.Theme.smallFont
            // Right-aligned when arrows are shown so they line up.
            horizontalAlignment: compact.cfg.showArrows ? Text.AlignRight : Text.AlignHCenter
            Layout.fillWidth: true
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.expanded = !root.expanded
    }
}
