#!/bin/sh
set -eu
: "${UUID:?UUID env required}"
: "${WS_PATH:?WS_PATH env required}"
PORT="${PORT:-10000}"
XRAY_PORT="10001"
cat > /etc/xray/config.json <<EOF
{
  "log": {"loglevel": "warning"},
  "inbounds": [
    {
      "listen": "127.0.0.1",
      "port": ${XRAY_PORT},
      "protocol": "vless",
      "settings": {
        "clients": [{"id": "${UUID}", "flow": ""}],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {"path": "${WS_PATH}"}
      }
    }
  ],
  "outbounds": [
    {"protocol": "freedom", "settings": {"domainStrategy": "UseIPv4"}},
    {"protocol": "blackhole", "tag": "blocked"}
  ]
}
EOF
cat > /etc/nginx/nginx.conf <<EOF
daemon off;
worker_processes 1;
error_log /dev/stderr warn;
pid /tmp/nginx.pid;
events { worker_connections 256; }
http {
  access_log /dev/stdout;
  server {
    listen 0.0.0.0:${PORT};
    location = ${WS_PATH} {
      proxy_pass http://127.0.0.1:${XRAY_PORT};
      proxy_http_version 1.1;
      proxy_set_header Upgrade \$http_upgrade;
      proxy_set_header Connection "upgrade";
      proxy_set_header Host \$host;
      proxy_read_timeout 3600s;
      proxy_send_timeout 3600s;
    }
    location / {
      access_log off;
      default_type text/plain;
      return 200 'ok';
    }
  }
}
EOF
/usr/local/bin/xray run -c /etc/xray/config.json &
exec nginx -c /etc/nginx/nginx.conf
