// SPDX-FileCopyrightText: 2026 Franco Pellegrini
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

import "../code/units.js" as Units
import "../components"

ConfigPage {
    id: page

    readonly property InterfaceModel interfaces: InterfaceModel {
        keepId: page.cfg_interfaceId || "all"
        onRevisionChanged: interfaceCombo.currentIndex = interfaceCombo.indexOfValue(page.cfg_interfaceId || "all")
    }

    Kirigami.FormLayout {
        QQC2.ComboBox {
            id: interfaceCombo
            Kirigami.FormData.label: i18n("Interface:")
            model: page.interfaces.model
            textRole: "label"
            valueRole: "ifaceId"
            onActivated: page.cfg_interfaceId = currentValue
        }

        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Update every:")
            from: 250
            to: 10000
            stepSize: 250
            value: page.cfg_pollInterval
            onValueModified: page.cfg_pollInterval = value
            textFromValue: (v, locale) => i18nc("@item:valuesuffix milliseconds", "%1 ms", v)
            valueFromText: (text, locale) => parseInt(text) || 1000
        }

        Item { Kirigami.FormData.isSection: true }

        QQC2.ButtonGroup { id: bitsGroup }
        QQC2.RadioButton {
            Kirigami.FormData.label: i18n("Show speed in:")
            text: i18n("Bytes per second")
            checked: !page.cfg_useBits
            QQC2.ButtonGroup.group: bitsGroup
            onToggled: page.cfg_useBits = false
        }
        QQC2.RadioButton {
            text: i18n("Bits per second")
            checked: page.cfg_useBits
            QQC2.ButtonGroup.group: bitsGroup
            onToggled: page.cfg_useBits = true
        }

        QQC2.ButtonGroup { id: decimalGroup }
        QQC2.RadioButton {
            Kirigami.FormData.label: i18n("Prefixes:")
            text: i18n("Binary (KiB = 1024)")
            checked: !page.cfg_useDecimal
            QQC2.ButtonGroup.group: decimalGroup
            onToggled: page.cfg_useDecimal = false
        }
        QQC2.RadioButton {
            text: i18n("Decimal (kB = 1000)")
            checked: page.cfg_useDecimal
            QQC2.ButtonGroup.group: decimalGroup
            onToggled: page.cfg_useDecimal = true
        }

        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Unit:")
            readonly property var suffixes: Units.rateSuffixes(page.previewOpts)
            model: [i18nc("@item:inlistbox unit prefix", "Automatic"), suffixes[1], suffixes[2], suffixes[3]]
            currentIndex: page.cfg_unitPrefix
            onActivated: page.cfg_unitPrefix = currentIndex
        }

        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Decimal places:")
            from: 0
            to: 3
            value: page.cfg_decimals
            onValueModified: page.cfg_decimals = value
        }

        QQC2.Label {
            Kirigami.FormData.label: i18n("Example:")
            text: Units.formatRate(1234567, page.previewOpts) + "   " + Units.formatRate(54321, page.previewOpts)
            textFormat: Text.PlainText
            font.features: { "tnum": 1 }
        }
    }

    readonly property var previewOpts: ({
        bits: !!cfg_useBits,
        decimal: !!cfg_useDecimal,
        prefix: cfg_unitPrefix || 0,
        decimals: cfg_decimals ?? 1,
        locale: Qt.locale()
    })
}
