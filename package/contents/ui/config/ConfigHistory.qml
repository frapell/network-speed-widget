// SPDX-FileCopyrightText: 2026 Franco Pellegrini
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami as Kirigami

ConfigPage {
    id: page

    Kirigami.FormLayout {
        QQC2.SpinBox {
            Kirigami.FormData.label: i18n("Show the last:")
            from: 1
            to: 180
            value: page.cfg_historyMinutes
            onValueModified: page.cfg_historyMinutes = value
            textFromValue: (v, locale) => i18ncp("@item:valuesuffix", "%1 minute", "%1 minutes", v)
            valueFromText: (text, locale) => parseInt(text) || 15
        }

        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("Chart:")
            text: i18n("Smooth lines")
            checked: page.cfg_chartSmooth
            onToggled: page.cfg_chartSmooth = checked
        }
        QQC2.CheckBox {
            text: i18n("Grid lines")
            checked: page.cfg_showGridLines
            onToggled: page.cfg_showGridLines = checked
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Fill opacity:")
            QQC2.Slider {
                id: fillSlider
                from: 0
                to: 100
                stepSize: 5
                value: page.cfg_chartFillOpacity
                onMoved: page.cfg_chartFillOpacity = value
            }
            QQC2.Label {
                text: i18nc("@item percentage", "%1%", fillSlider.value)
                textFormat: Text.PlainText
            }
        }

        Item { Kirigami.FormData.isSection: true }

        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("Statistics:")
            text: i18n("Current")
            checked: page.cfg_showStatCurrent
            onToggled: page.cfg_showStatCurrent = checked
        }
        QQC2.CheckBox {
            text: i18n("Average")
            checked: page.cfg_showStatAverage
            onToggled: page.cfg_showStatAverage = checked
        }
        QQC2.CheckBox {
            text: i18n("Peak")
            checked: page.cfg_showStatPeak
            onToggled: page.cfg_showStatPeak = checked
        }
        QQC2.CheckBox {
            text: i18n("Total transferred")
            checked: page.cfg_showStatTotal
            onToggled: page.cfg_showStatTotal = checked
        }

        QQC2.CheckBox {
            Kirigami.FormData.label: i18n("Footer:")
            text: i18n("Interface and totals since boot")
            checked: page.cfg_showFooter
            onToggled: page.cfg_showFooter = checked
        }
    }
}
