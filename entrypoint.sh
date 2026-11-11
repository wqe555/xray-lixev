#!/bin/sh
set -eu
: "${UUID:?UUID env required}"
: "${WS_PATH:?WS_PATH env required}"
PORT="${PORT:-10000}"
cat > /etc/xray/config.json <<EOF
{
  "log": {"loglevel": "warning"},
  "inbounds": [
    {
      "listen": "0.0.0.0",
      "port": ${PORT},
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
exec /usr/local/bin/xray run -c /etc/xray/config.json
