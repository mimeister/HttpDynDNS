#!/bin/bash

systemctl disable http_dyndns.timer
rm /etc/systemd/system/http_dyndns.*
systemctl daemon-reload
rm /usr/local/bin/HttpDynDNS.sh