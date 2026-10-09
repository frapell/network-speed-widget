// SPDX-FileCopyrightText: 2026 Franco Pellegrini
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami
import org.kde.quickcharts as Charts

import "code/units.js" as Units
import "components"

ColumnLayout {
    id: full

    readonly property var cfg: Plasmoid.configuration

    readonly property int intervals: Units.axisIntervals(root.chartRange, root.unitOpts)
    readonly property var axisLabels: Units.axisLabels(root.chartRange, intervals, root.unitOpts)

    Layout.minimumWidth: Kirigami.Units.gridUnit * 20
    Layout.minimumHeight: Kirigami.Units.gridUnit * 14
    Layout.preferredWidth: Kirigami.Units.gridUnit * 26
    Layout.preferredHeight: Kirigami.Units.gridUnit * 18

    spacing: Kirigami.Units.largeSpacing

    Kirigami.InlineMessage {
        Layout.fillWidth: true
        visible: !root.sensorsOk
        type: Kirigami.MessageType.Warning
        text: i18n("Interface %1 is not available.", root.interfaceLabel)
    }

    Item {
        id: chartArea

        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.minimumHeight: Kirigami.Units.gridUnit * 5

        readonly property real labelWidth: {
            axisMetrics.font;
            let widest = 0;
            for (const t of full.axisLabels) {
                widest = Math.max(widest, axisMetrics.advanceWidth(t));
            }
            return Math.ceil(widest);
        }

        FontMetrics {
            id: axisMetrics
            font: Kirigami.Theme.smallFont
        }

        Item {
            id: plotArea
            anchors {
                left: parent.left
                leftMargin: chartArea.labelWidth + Kirigami.Units.smallSpacing
                right: parent.right
                top: parent.top
                topMargin: Math.ceil(axisMetrics.height / 2)
                bottom: parent.bottom
                bottomMargin: Math.ceil(axisMetrics.height / 2)
            }
        }

        Repeater {
            model: full.intervals + 1

            Item {
                required property int index
                readonly property real lineY: plotArea.y + plotArea.height * (1 - index / full.intervals)

                Rectangle {
                    visible: full.cfg.showGridLines || index === 0
                    x: plotArea.x
                    y: Math.round(parent.lineY)
                    width: plotArea.width
                    height: 1
                    color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor,
                                                                   Kirigami.Theme.textColor, 0.2)
                }

                PlasmaComponents3.Label {
                    x: 0
                    width: chartArea.labelWidth
                    y: Math.round(parent.lineY - height / 2)
                    text: full.axisLabels[index] ?? ""
                    font: Kirigami.Theme.smallFont
                    opacity: 0.7
                    horizontalAlignment: Text.AlignRight
                    textFormat: Text.PlainText
                }
            }
        }

        Charts.LineChart {
            anchors.fill: plotArea
            direction: Charts.XYChart.ZeroAtEnd
            interpolate: full.cfg.chartSmooth
            lineWidth: 2
            fillOpacity: full.cfg.chartFillOpacity / 100
            yRange {
                automatic: false
                from: 0
                to: root.chartRange
            }
            valueSources: [
                Charts.ArraySource { array: root.chartUp },
                Charts.ArraySource { array: root.chartDown }
            ]
            nameSource: Charts.ArraySource {
                array: [i18n("Upload"), i18n("Download")]
            }
            colorSource: Charts.ArraySource {
                array: [full.cfg.uploadColor, full.cfg.downloadColor]
            }
        }
    }

    StatsGrid {
        Layout.fillWidth: true
        opts: root.unitOpts
        available: root.sensorsOk
        statsDown: root.statsDown
        statsUp: root.statsUp
        downloadColor: full.cfg.downloadColor
        uploadColor: full.cfg.uploadColor
        showCurrent: full.cfg.showStatCurrent
        showAverage: full.cfg.showStatAverage
        showPeak: full.cfg.showStatPeak
        showTotal: full.cfg.showStatTotal
        formatBytes: root.bytes
    }

    PlasmaComponents3.Label {
        Layout.fillWidth: true
        visible: full.cfg.showFooter
        font: Kirigami.Theme.smallFont
        opacity: 0.7
        elide: Text.ElideRight
        textFormat: Text.PlainText
        text: i18nc("@info footer", "Interface: %1 · Since boot: ↓ %2 ↑ %3 · Last %4 min",
                    root.interfaceLabel, root.bytes(root.totalDown), root.bytes(root.totalUp),
                    full.cfg.historyMinutes)
    }
}
