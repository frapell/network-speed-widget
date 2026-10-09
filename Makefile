# SPDX-FileCopyrightText: 2026 Franco Pellegrini
# SPDX-License-Identifier: GPL-2.0-or-later

ID      := org.frapell.networkspeed
VERSION := $(shell sed -n 's/.*"Version": "\(.*\)".*/\1/p' package/metadata.json)
DIST    := dist/$(ID)-$(VERSION).plasmoid

.PHONY: install upgrade uninstall restart build test log view clean

install:
	kpackagetool6 -t Plasma/Applet -i package

upgrade:
	kpackagetool6 -t Plasma/Applet -u package

uninstall:
	kpackagetool6 -t Plasma/Applet -r $(ID)

# plasmashell caches compiled QML; restart it to pick up edits.
restart:
	systemctl --user restart plasma-plasmashell.service

build: test
	@mkdir -p dist
	rm -f $(DIST)
	cd package && zip -qr ../$(DIST) . -x '*.qmlc'
	@echo $(DIST)

test:
	node tests/units.test.js
	node tests/history.test.js

log:
	journalctl --user -u plasma-plasmashell -f | grep --line-buffered -iE 'networkspeed|qml'

view:
	plasmawindowed $(ID)

clean:
	rm -rf dist
