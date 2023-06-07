#!/usr/bin/with-contenv sh

if [ -z "$SECRET" ]; then
  SECRET="935ddceb2f6bbbb78363b224099f75c8"
fi

if [ -z "$TLS_DOMAIN" ]; then
  TLS_DOMAIN="www.cloudflare.com"
fi

if [ -z "$MTPROXY_PORT" ]; then
  MTPROXY_PORT=443
fi

SECRET_CMD="-S $SECRET"

mkdir -p /etc/telegram/

curl -s https://core.telegram.org/getProxyConfig -o /etc/telegram/proxy-multi.conf || {
  echo '[F] Cannot download proxy-multi from Telegram servers.'
  exit 2
}
PROXY_CONFIG=/etc/telegram/proxy-multi.conf

curl -s https://core.telegram.org/getProxySecret -o /etc/telegram/proxy-secret || {
  echo '[F] Cannot download proxy-secret from Telegram servers.'
  exit 2
}
PROXY_SECRET=/etc/telegram/proxy-secret


IP="$(curl -s -4 "https://api.ipify.org")"

if [[ -z "$IP" ]]; then
  echo "[F] Cannot determine external IP address."
  exit 3
fi

INTERNAL_IP="$(ip -4 route get 8.8.8.8 | grep '^8\.8\.8\.8\s' | grep -Po 'src\s+\d+\.\d+\.\d+\.\d+' | awk '{print $2}')"
if [[ -z "$INTERNAL_IP" ]]; then
  echo "[F] Cannot determine internal IP address."
  exit 4
fi

# save link to a file

echo "[*]   External IP: $IP"
echo "[*]   Make sure to fix the links in case you run the proxy on a different port."
echo
echo '[+] Starting proxy...'
sleep 1

HEX_DOMAIN=$(printf "%s" "$TLS_DOMAIN" | xxd -pu)
HEX_DOMAIN="$(echo $HEX_DOMAIN | tr '[A-Z]' '[a-z]')"
TG_LINK="tg://proxy?server=$IP&port=$MTPROXY_PORT&secret=ee$SECRET$HEX_DOMAIN"
# echo $TG_LINK with green color
echo -e "\n===============================================\n"
echo -e "\e[32m$TG_LINK\033[0m"
echo -e "\n===============================================\n"

/usr/bin/mtproto-proxy -p 8888 --http-stats -H 443 -C 60000 -D $TLS_DOMAIN --aes-pwd $PROXY_SECRET  -u root $PROXY_CONFIG --allow-skip-dh --nat-info "$INTERNAL_IP:$IP" $SECRET_CMD
