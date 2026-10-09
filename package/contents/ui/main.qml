// SPDX-FileCopyrightText: 2026 Franco Pellegrini
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick

import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.ksysguard.sensors as Sensors

import "code/units.js" as Units
import "components"

PlasmoidItem {
    id: root

    readonly property var cfg: Plasmoid.configuration

    readonly property string interfaceId: cfg.interfaceId || "all"
    readonly property int pollInterval: Math.max(250, Math.min(10000, cfg.pollInterval))
    readonly property var unitOpts: ({
        bits: cfg.useBits,
        decimal: cfg.useDecimal,
        prefix: cfg.unitPrefix,
        decimals: cfg.decimals,
        locale: Qt.locale()
    })

    // Desktop, plasmawindowed and the like show the full view directly.
    readonly property bool inPanel: Plasmoid.formFactor === PlasmaCore.Types.Horizontal
                                    || Plasmoid.formFactor === PlasmaCore.Types.Vertical
    readonly property bool fullShown: expanded || !inPanel
    readonly property real historyWindowMs: cfg.historyMinutes * 60000
    readonly property real rangeWindowMs: cfg.rangeWindowSeconds * 1000

    readonly property bool sensorsOk: downSensor.status === Sensors.Sensor.Ready
                                      && upSensor.status === Sensors.Sensor.Ready

    // Latest rates in bytes/s.
    property real downRate: 0
    property real upRate: 0

    // Bar maxima in bytes/s.
    property real rangeDown: 0
    property real rangeUp: 0

    // Full representation data, only refreshed while it is visible.
    property var statsDown: ({ current: 0, average: 0, peak: 0, total: 0 })
    property var statsUp: ({ current: 0, average: 0, peak: 0, total: 0 })
    property var chartDown: []
    property var chartUp: []
    property real chartRange: 0

    readonly property string interfaceLabel: interfaceId === "all" ? i18n("All interfaces") : interfaceId

    property real _lastSampleTime: 0

    function rate(bytesPerSec) {
        return Units.formatRate(bytesPerSec, unitOpts);
    }

    function bytes(count) {
        return Units.formatBytes(count, unitOpts);
    }

    function sample() {
        const now = Date.now();
        const nominal = pollInterval / 1000;
        const dt = _lastSampleTime > 0 ? Math.min((now - _lastSampleTime) / 1000, 2 * nominal) : nominal;
        _lastSampleTime = now;

        const ok = sensorsOk;
        downRate = ok ? Math.max(0, downSensor.value || 0) : 0;
        upRate = ok ? Math.max(0, upSensor.value || 0) : 0;
        history.push({ t: now, dt: dt, down: downRate, up: upRate, ok: ok });

        updateRanges(now);
        if (fullShown) {
            updateFull(now);
        }
    }

    function updateRanges(now) {
        if (!cfg.rangeAuto) {
            rangeDown = Math.max(1, cfg.fixedMaxDownload);
            rangeUp = Math.max(1, cfg.fixedMaxUpload);
            return;
        }
        rangeDown = Units.autoRange(history.peak(rangeWindowMs, now, "down"), cfg.rangeFloor, rangeDown, unitOpts);
        rangeUp = Units.autoRange(history.peak(rangeWindowMs, now, "up"), cfg.rangeFloor, rangeUp, unitOpts);
    }

    function updateFull(now) {
        statsDown = history.stats(historyWindowMs, now, "down");
        statsUp = history.stats(historyWindowMs, now, "up");
        const points = Math.max(2, Math.min(cfg.chartMaxPoints, Math.round(historyWindowMs / pollInterval)));
        chartDown = history.series(historyWindowMs, now, points, "down");
        chartUp = history.series(historyWindowMs, now, points, "up");
        chartRange = Units.autoRange(Math.max(statsDown.peak, statsUp.peak), cfg.rangeFloor, 0, unitOpts);
    }

    function refresh() {
        const now = Date.now();
        updateRanges(now);
        if (fullShown) {
            updateFull(now);
        }
    }

    Component.onCompleted: refresh()
    onFullShownChanged: if (fullShown) updateFull(Date.now())
    onInterfaceIdChanged: {
        history.clear();
        _lastSampleTime = 0;
        refresh();
    }
    onHistoryWindowMsChanged: refresh()
    onRangeWindowMsChanged: refresh()
    onUnitOptsChanged: refresh()
    Connections {
        target: root.cfg
        function onRangeAutoChanged() { root.refresh() }
        function onRangeFloorChanged() { root.refresh() }
        function onFixedMaxDownloadChanged() { root.refresh() }
        function onFixedMaxUploadChanged() { root.refresh() }
        function onChartMaxPointsChanged() { root.refresh() }
    }

    Sensors.Sensor {
        id: downSensor
        sensorId: "network/" + root.interfaceId + "/download"
        updateRateLimit: root.pollInterval
    }
    Sensors.Sensor {
        id: upSensor
        sensorId: "network/" + root.interfaceId + "/upload"
        updateRateLimit: root.pollInterval
    }
    Sensors.Sensor {
        id: totalDownSensor
        sensorId: "network/" + root.interfaceId + "/totalDownload"
        updateRateLimit: Math.max(5000, root.pollInterval)
    }
    Sensors.Sensor {
        id: totalUpSensor
        sensorId: "network/" + root.interfaceId + "/totalUpload"
        updateRateLimit: Math.max(5000, root.pollInterval)
    }

    readonly property real totalDown: totalDownSensor.value || 0
    readonly property real totalUp: totalUpSensor.value || 0

    History {
        id: history
        maxAgeMs: Math.max(root.historyWindowMs, root.rangeWindowMs) + 2 * root.pollInterval
    }

    Timer {
        interval: root.pollInterval
        running: true
        repeat: true
        onTriggered: root.sample()
    }

    Plasmoid.icon: "network-wired-activated"

    toolTipMainText: sensorsOk
        ? i18nc("@info:tooltip download and upload speed", "↓ %1   ↑ %2", rate(downRate), rate(upRate))
        : i18n("Network Speed")
    toolTipSubText: sensorsOk
        ? i18nc("@info:tooltip", "Interface: %1\nSince boot: ↓ %2   ↑ %3", interfaceLabel, bytes(totalDown), bytes(totalUp))
        : i18nc("@info:tooltip", "Interface %1 is not available", interfaceLabel)

    preferredRepresentation: inPanel ? compactRepresentation : fullRepresentation
    compactRepresentation: CompactRepresentation {}
    fullRepresentation: FullRepresentation {}
}
