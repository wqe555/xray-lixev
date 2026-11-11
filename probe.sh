#!/bin/sh
P="${PORT:-10000}"
cat > /etc/nginx/conf.d/default.conf <<EOC
server {
  listen 0.0.0.0:$P;
  access_log /dev/stdout;
  location / { return 200 'LIXEV-PROBE-OK uri=$request_uri\n'; }
}
EOC
exec nginx -g 'daemon off;'
