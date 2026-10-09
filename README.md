# Network Speed

A Plasma 6 widget that shows download and upload speed at a glance in the
panel, as two fill bars with text, and expands to a history chart with
statistics.

- **Panel (horizontal):** download over upload, each a bar plus a rate
  label. Text can go right or left of the bars, or you can show bars only or
  text only.
- **Panel (vertical):** two thin vertical bars, with labels underneath when
  the panel is wide enough.
- **Popup / desktop:** line chart of the last 15 minutes (configurable), with
  current, average, peak and total transferred per direction, plus totals
  since boot.
- Bytes or bits, binary or decimal prefixes, automatic or fixed unit,
  configurable decimals.
- The bar scale follows the recent peak, snapped to round 1/2/5 steps, with a
  configurable floor. A fixed maximum is also available.
- Monitors all interfaces or a single one.

## Requirements

Plasma 6 with `ksystemstats` running (it ships with Plasma System Monitor and
the standard system monitor widgets).

Data comes from `ksystemstats`, which only knows about interfaces managed by
NetworkManager. Loopback, WireGuard, Docker bridges and `veth` devices are
not listed.

## Install

From the KDE Store: *Add Widgets → Get New Widgets → Download New Plasma
Widgets*, search for "Network Speed".

From source:

```sh
make install        # first time
make upgrade        # afterwards
make restart        # restart plasmashell to drop the QML cache
```

`make build` runs the tests and writes `dist/org.frapell.networkspeed-<version>.plasmoid`.

## Development

| Command | What it does |
|---|---|
| `make test` | Unit tests for the formatting and history code (needs `node`) |
| `make view` | Opens the widget in a window with `plasmawindowed` |
| `make log` | Follows plasmashell's log, filtered to QML and this widget |

The formatting and statistics code lives in `package/contents/ui/code/` as
plain JavaScript with no QML dependencies, so the tests load it directly.

## License

GPL-2.0-or-later. See `LICENSE`.
