// SPDX-FileCopyrightText: 2026 Franco Pellegrini
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Layouts

import org.kde.plasma.components as PlasmaComponents3
import org.kde.kirigami as Kirigami

// Legend plus per-direction statistics. Columns are placed explicitly so
// hidden ones simply collapse.
GridLayout {
    id: grid

    property var opts
    property bool available: true
    property var statsDown
    property var statsUp
    property color downloadColor
    property color uploadColor
    property bool showCurrent: true
    property bool showAverage: true
    property bool showPeak: true
    property bool showTotal: true
    // function(bytes) -> string
    property var formatBytes

    columns: 5
    rowSpacing: Kirigami.Units.smallSpacing
    columnSpacing: Kirigami.Units.largeSpacing

    component Header: PlasmaComponents3.Label {
        Layout.row: 0
        Layout.alignment: Qt.AlignRight
        font: Kirigami.Theme.smallFont
        opacity: 0.7
        textFormat: Text.PlainText
    }

    component Name: RowLayout {
        property alias text: nameLabel.text
        property color color
        spacing: Kirigami.Units.smallSpacing
        Layout.column: 0
        Layout.fillWidth: true

        Rectangle {
            color: parent.color
            radius: height / 4
            Layout.preferredWidth: Kirigami.Units.smallSpacing * 2
            Layout.preferredHeight: nameLabel.implicitHeight * 0.8
        }
        PlasmaComponents3.Label {
            id: nameLabel
            textFormat: Text.PlainText
            elide: Text.ElideRight
            Layout.fillWidth: true
        }
    }

    component Rate: SpeedText {
        opts: grid.opts
        available: grid.available
        Layout.alignment: Qt.AlignRight
    }

    component Total: PlasmaComponents3.Label {
        property real bytes
        text: grid.available ? grid.formatBytes(bytes) : "—"
        textFormat: Text.PlainText
        horizontalAlignment: Text.AlignRight
        font.features: { "tnum": 1 }
        Layout.column: 4
        Layout.alignment: Qt.AlignRight
    }

    Item { Layout.row: 0; Layout.column: 0; Layout.fillWidth: true }
    Header { Layout.column: 1; visible: grid.showCurrent; text: i18nc("@title:column", "Current") }
    Header { Layout.column: 2; visible: grid.showAverage; text: i18nc("@title:column", "Average") }
    Header { Layout.column: 3; visible: grid.showPeak; text: i18nc("@title:column", "Peak") }
    Header { Layout.column: 4; visible: grid.showTotal; text: i18nc("@title:column bytes transferred", "Total") }

    Name { Layout.row: 1; text: i18n("Download"); color: grid.downloadColor }
    Rate { Layout.row: 1; Layout.column: 1; visible: grid.showCurrent; value: grid.statsDown.current }
    Rate { Layout.row: 1; Layout.column: 2; visible: grid.showAverage; value: grid.statsDown.average }
    Rate { Layout.row: 1; Layout.column: 3; visible: grid.showPeak; value: grid.statsDown.peak }
    Total { Layout.row: 1; visible: grid.showTotal; bytes: grid.statsDown.total }

    Name { Layout.row: 2; text: i18n("Upload"); color: grid.uploadColor }
    Rate { Layout.row: 2; Layout.column: 1; visible: grid.showCurrent; value: grid.statsUp.current }
    Rate { Layout.row: 2; Layout.column: 2; visible: grid.showAverage; value: grid.statsUp.average }
    Rate { Layout.row: 2; Layout.column: 3; visible: grid.showPeak; value: grid.statsUp.peak }
    Total { Layout.row: 2; visible: grid.showTotal; bytes: grid.statsUp.total }
}
