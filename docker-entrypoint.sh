#!/bin/sh

if [ ! -z "$DEBUG" ]; then set -x; fi

mkdir -p /data
rm -f /data/links.txt

INTERNAL_PORT=${INTERNAL_PORT:-443}
EXTERNAL_PORT=${EXTERNAL_PORT:-443}
WORKERS=${WORKERS:-2}
MAX_SPECIAL_CONNECTIONS=${MAX_SPECIAL_CONNECTIONS:-60000}
ENABLE_TLS=${ENABLE_TLS:-true}
TLS_DOMAIN=${TLS_DOMAIN:-www.cloudflare.com}

SECRET_CMD=""
if [ ! -z "$SECRET" ]; then
  echo "[+] Using explicit secret."
elif [ -f /data/secret ]; then
  SECRET="$(cat /data/secret)"
else
  SECRET="$(dd if=/dev/urandom bs=16 count=1 2>/dev/null | od -tx1 | head -n1 | tail -c +9 | tr -d ' ')"
fi

if echo "$SECRET" | grep -qE '^[0-9a-fA-F]{32}(,[0-9a-fA-F]{32}){0,15}$'; then
  SECRET="$(echo "$SECRET" | tr '[:upper:]' '[:lower:]')"
  SECRET_CMD="-S $(echo "$SECRET" | sed 's/,/ -S /g')"
  echo "$SECRET" > /data/secret
else
  echo "[F] Bad secret format."
  exit 1
fi

TAG_CMD=""
if [ ! -z "$TAG" ]; then
  if echo "$TAG" | grep -qE '^[0-9a-fA-F]{32}$'; then
    TAG="$(echo "$TAG" | tr '[:upper:]' '[:lower:]')"
    TAG_CMD="-P $TAG"
  fi
fi

REMOTE_CONFIG=/data/proxy-multi.conf
curl -s https://core.telegram.org/getProxyConfig -o ${REMOTE_CONFIG} || exit 2

REMOTE_SECRET=/data/proxy-secret
curl -s https://core.telegram.org/getProxySecret -o ${REMOTE_SECRET} || exit 5

if [ -z "$EXTERNAL_HOST" ]; then
  EXTERNAL_HOST="$(curl -s -4 "https://digitalresistance.dog/myIp")"
fi

INTERNAL_IP="$(ip -4 route get 8.8.8.8 | grep -Eo 'src\s+[0-9.]+' | awk '{print $2}')"
if [ -z "$INTERNAL_IP" ]; then
  INTERNAL_IP="127.0.0.1"
fi

TLS_CMD=""
echo "========================================" > /data/links.txt
echo "MTProxy Links" >> /data/links.txt
echo "========================================" >> /data/links.txt

I=1
for S in $(echo "$SECRET" | tr ',' ' '); do
  if [ "$ENABLE_TLS" = "true" ] || [ "$ENABLE_TLS" = "1" ]; then
    HEX_DOMAIN=$(printf "%s" "$TLS_DOMAIN" | od -An -tx1 | tr -d ' \n')
    HEX_DOMAIN="$(echo $HEX_DOMAIN | tr '[A-Z]' '[a-z]')"
    LINK="https://t.me/proxy?server=${EXTERNAL_HOST}&port=${EXTERNAL_PORT}&secret=ee${S}${HEX_DOMAIN}"
    TLS_CMD="-D $TLS_DOMAIN"
  else
    LINK="https://t.me/proxy?server=${EXTERNAL_HOST}&port=${EXTERNAL_PORT}&secret=${S}"
  fi
  
  echo "Secret $I: $S" >> /data/links.txt
  echo "Link $I: $LINK" >> /data/links.txt
  I=$((I+1))
done

cat /data/links.txt

exec /mtproxy/mtproto-proxy \
  -p 2398 --http-stats \
  -H $INTERNAL_PORT \
  -M $WORKERS \
  -C $MAX_SPECIAL_CONNECTIONS \
  --allow-skip-dh \
  --aes-pwd ${REMOTE_SECRET} \
  --user root \
  ${REMOTE_CONFIG} \
  --nat-info "$INTERNAL_IP:$EXTERNAL_HOST" \
  $SECRET_CMD \
  $TAG_CMD \
  $TLS_CMD
