#!/bin/sh
if [ ! -f melange.rsa ] &&
   [ ! -f melange.rsa.pub ] &&
   [ ! -f packages/melange.rsa.pub ]; then
	melange keygen && mkdir packages && mv melange.rsa.pub packages
fi

if [ ! -f config/bloat.conf ] && [ -f config/bloat.default.conf ]; then
	cp config/bloat.default.conf config/bloat.conf
fi

if [ -z "$(ss -tHl src :8000)" ]; then
	cd packages && python3 -m http.server &
	sleep 2
fi

melange build --signing-key melange.rsa

apko build apko.yml bloat:latest bloat.oci.tar

if [ ! -z "$(ss -tHl src :8000)" ]; then
	pkill -f "python3 -m http.server"
fi
