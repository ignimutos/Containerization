#!/bin/ash
if [ -e /etc/caddy/Caddyfile ]; then
  cat <<EOF >/etc/caddy/Caddyfile
{
  admin off
	log {
		output stdout
		format console {
			time_format wall
			time_local
		}
		level $LOG_LEVEL
	}
  order forward_proxy before file_server
  order forward_proxy before reverse_proxy
}
:443, $DOMAIN {
  tls $EMAIL
  forward_proxy {
    basic_auth $USER $PASS
    hide_ip
    hide_via
    probe_resistance
  }
  reverse_proxy  $REVERSE_SERVER  {
    header_up  Host  {upstream_hostport}
    header_up  X-Forwarded-Host  {host}
  }
}
EOF
fi

caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
