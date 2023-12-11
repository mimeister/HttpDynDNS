#!/bin/bash

cp HttpDynDNS.sh /usr/local/bin/HttpDynDNS.sh
chmod +x /usr/local/bin/HttpDynDNS.sh
cp http_dyndns.* /etc/systemd/system/
systemctl daemon-reload
systemctl enable http_dyndns.timer
systemctl start http_dyndns.timer