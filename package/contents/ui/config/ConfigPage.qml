// SPDX-FileCopyrightText: 2026 Franco Pellegrini
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick

import org.kde.kcmutils as KCM

// Base for every settings page. Plasma assigns every cfg_<entry> and
// cfg_<entry>Default to each page, so all of them are declared here; the
// pages read and write the ones they show.
KCM.SimpleKCM {
    property var cfg_interfaceId
    property var cfg_interfaceIdDefault
    property var cfg_pollInterval
    property var cfg_pollIntervalDefault
    property var cfg_useBits
    property var cfg_useBitsDefault
    property var cfg_useDecimal
    property var cfg_useDecimalDefault
    property var cfg_unitPrefix
    property var cfg_unitPrefixDefault
    property var cfg_decimals
    property var cfg_decimalsDefault
    property var cfg_downloadColor
    property var cfg_downloadColorDefault
    property var cfg_uploadColor
    property var cfg_uploadColorDefault
    property var cfg_textPosition
    property var cfg_textPositionDefault
    property var cfg_showArrows
    property var cfg_showArrowsDefault
    property var cfg_barLengthUnits
    property var cfg_barLengthUnitsDefault
    property var cfg_rangeAuto
    property var cfg_rangeAutoDefault
    property var cfg_rangeWindowSeconds
    property var cfg_rangeWindowSecondsDefault
    property var cfg_rangeFloor
    property var cfg_rangeFloorDefault
    property var cfg_fixedMaxDownload
    property var cfg_fixedMaxDownloadDefault
    property var cfg_fixedMaxUpload
    property var cfg_fixedMaxUploadDefault
    property var cfg_historyMinutes
    property var cfg_historyMinutesDefault
    property var cfg_chartSmooth
    property var cfg_chartSmoothDefault
    property var cfg_chartFillOpacity
    property var cfg_chartFillOpacityDefault
    property var cfg_showGridLines
    property var cfg_showGridLinesDefault
    property var cfg_showStatCurrent
    property var cfg_showStatCurrentDefault
    property var cfg_showStatAverage
    property var cfg_showStatAverageDefault
    property var cfg_showStatPeak
    property var cfg_showStatPeakDefault
    property var cfg_showStatTotal
    property var cfg_showStatTotalDefault
    property var cfg_showFooter
    property var cfg_showFooterDefault
    property var cfg_chartMaxPoints
    property var cfg_chartMaxPointsDefault

    // Not ours: the panel passes these to every applet's pages, which logs a
    // warning per page unless they exist.
    property var cfg_expanding
    property var cfg_expandingDefault
    property var cfg_length
    property var cfg_lengthDefault
}
