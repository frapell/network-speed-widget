// SPDX-FileCopyrightText: 2026 Franco Pellegrini
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick

import org.kde.kitemmodels as KItemModels
import org.kde.ksysguard.sensors as Sensors

// Network interfaces known to ksystemstats, as a ListModel of
// { ifaceId, label }. The first entry is always "all". `keepId` is listed even
// when absent so a saved choice for an unplugged device isn't lost.
QtObject {
    id: interfaces

    property string keepId: "all"
    readonly property ListModel model: ListModel {}
    // Bumped after every rebuild.
    property int revision: 0

    readonly property var _filtered: KItemModels.KSortFilterProxyModel {
        sourceModel: KItemModels.KDescendantsProxyModel {
            model: Sensors.SensorTreeModel {}
        }
        filterRowCallback: function (row, parent) {
            const id = sourceModel.data(sourceModel.index(row, 0, parent), Sensors.SensorTreeModel.SensorId);
            return /^network\/(?!all\/)[^\/]+\/download$/.test(id || "");
        }
        onRowsInserted: interfaces._debounce.restart()
        onRowsRemoved: interfaces._debounce.restart()
        onModelReset: interfaces._debounce.restart()
    }

    readonly property Timer _debounce: Timer {
        interval: 200
        onTriggered: interfaces.rebuild()
    }

    // Connection names ("Home Wi-Fi") to decorate the plain device ids.
    readonly property Instantiator _names: Instantiator {
        model: interfaces.model
        delegate: Sensors.Sensor {
            required property int index
            required property string ifaceId
            sensorId: ifaceId === "all" ? "" : "network/" + ifaceId + "/network"
            onValueChanged: interfaces.setConnectionName(index, ifaceId, value)
        }
    }

    function rebuild() {
        const ids = [];
        for (let i = 0; i < _filtered.rowCount(); ++i) {
            const sensorId = _filtered.data(_filtered.index(i, 0), Sensors.SensorTreeModel.SensorId);
            const id = sensorId.split("/")[1];
            if (ids.indexOf(id) === -1) {
                ids.push(id);
            }
        }
        ids.sort();

        model.clear();
        model.append({ ifaceId: "all", label: i18n("All interfaces") });
        for (const id of ids) {
            model.append({ ifaceId: id, label: id });
        }
        if (keepId !== "all" && ids.indexOf(keepId) === -1) {
            model.append({ ifaceId: keepId, label: i18nc("@item:inlistbox interface id", "%1 (not present)", keepId) });
        }
        ++revision;
    }

    function setConnectionName(index, id, name) {
        if (index < model.count && model.get(index).ifaceId === id && name) {
            model.setProperty(index, "label", i18nc("@item:inlistbox interface id, connection name", "%1 (%2)", id, name));
        }
    }

    Component.onCompleted: _debounce.start()
}
