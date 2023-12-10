#!/bin/bash

cp HttpDynDNS.py /usr/local/bin/HttpDynDNS.py
cp http_dyndns.* /etc/systemd/system/
systemctl daemon-reload
systemctl enable http_dyndns.timer