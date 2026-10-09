// SPDX-FileCopyrightText: 2026 Franco Pellegrini
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.plasma.plasmoid
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols as KQuickControls

ConfigPage {
    id: page

    // Rates are edited in the unit family chosen on the General page.
    readonly property bool useBits: Plasmoid.configuration.useBits
    readonly property bool useDecimal: Plasmoid.configuration.useDecimal

    Kirigami.FormLayout {
        KQuickControls.ColorButton {
            Kirigami.FormData.label: i18n("Download color:")
            color: page.cfg_downloadColor
            onAccepted: (color) => page.cfg_downloadColor = color
        }
        KQuickControls.ColorButton {
            Kirigami.FormData.label: i18n("Upload color:")
            color: page.cfg_uploadColor
            onAccepted: (color) => page.cfg_uploadColor = color
        }

        Item { Kirigami.FormData.isSection: true }

        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Panel layout:")
            model: [
                i18nc("@item:inlistbox panel layout", "Bars with text on the right"),
                i18nc("@item:inlistbox panel layout", "Bars with text on the left"),
                i18nc("@item:inlistbox panel layout", "Bars only"),
                i18nc("@item:inlistbox panel layout", "Text only")
            ]
            currentIndex: page.cfg_textPosition
            onActivated: page.cfg_textPosition = currentIndex
        }

        QQC2.CheckBox {
            text: i18n("Show ↓ ↑ arrows")
            checked: page.cfg_showArrows
            onToggled: page.cfg_showArrows = checked
        }

        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Bar length:")
            from: 1
            to: 20
            value: page.cfg_barLengthUnits
            onValueModified: page.cfg_barLengthUnits = value
            textFromValue: (v, locale) => i18ncp("@item:valuesuffix bar length", "%1 unit", "%1 units", v)
            valueFromText: (text, locale) => parseInt(text) || 4
        }

        Item { Kirigami.FormData.isSection: true }

        QQC2.ButtonGroup { id: rangeGroup }
        QQC2.RadioButton {
            Kirigami.FormData.label: i18n("Bar scale:")
            text: i18n("Automatic")
            checked: page.cfg_rangeAuto
            QQC2.ButtonGroup.group: rangeGroup
            onToggled: page.cfg_rangeAuto = true
        }
        QQC2.RadioButton {
            text: i18n("Fixed maximum")
            checked: !page.cfg_rangeAuto
            QQC2.ButtonGroup.group: rangeGroup
            onToggled: page.cfg_rangeAuto = false
        }

        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Follow peak over the last:")
            enabled: page.cfg_rangeAuto
            from: 5
            to: 3600
            stepSize: 5
            value: page.cfg_rangeWindowSeconds
            onValueModified: page.cfg_rangeWindowSeconds = value
            textFromValue: (v, locale) => i18ncp("@item:valuesuffix", "%1 second", "%1 seconds", v)
            valueFromText: (text, locale) => parseInt(text) || 60
        }

        RateSpinBox {
            Kirigami.FormData.label: i18n("Never scale below:")
            enabled: page.cfg_rangeAuto
            bits: page.useBits
            decimal: page.useDecimal
            value: page.cfg_rangeFloor
            onEdited: page.cfg_rangeFloor = value
        }

        RateSpinBox {
            Kirigami.FormData.label: i18n("Download maximum:")
            enabled: !page.cfg_rangeAuto
            bits: page.useBits
            decimal: page.useDecimal
            value: page.cfg_fixedMaxDownload
            onEdited: page.cfg_fixedMaxDownload = value
        }

        RateSpinBox {
            Kirigami.FormData.label: i18n("Upload maximum:")
            enabled: !page.cfg_rangeAuto
            bits: page.useBits
            decimal: page.useDecimal
            value: page.cfg_fixedMaxUpload
            onEdited: page.cfg_fixedMaxUpload = value
        }
    }
}
