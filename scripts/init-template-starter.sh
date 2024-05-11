#!/usr/bin/env bash

set -eou pipefail

if [ ! -v ISLE_SITE_TEMPLATE_REF ] || [ "$ISLE_SITE_TEMPLATE_REF" = "" ]; then
  ISLE_SITE_TEMPLATE_REF=heads/main
fi

if [ ! -v ISLANDORA_STARTER_REF ] || [ "$ISLANDORA_STARTER_REF" = "" ]; then
  ISLANDORA_STARTER_REF=heads/main
fi

mkdir -p isle-site-template
cd isle-site-template
curl -L "https://github.com/Islandora-Devops/isle-site-template/archive/refs/${ISLE_SITE_TEMPLATE_REF}.tar.gz" \
  | tar -xz --strip-components=1

cp drupal/rootfs/var/www/drupal/assets/patches/default_settings.txt .

curl -L "https://github.com/Islandora-Devops/islandora-starter-site/archive/refs/${ISLANDORA_STARTER_REF}.tar.gz" \
  | tar --strip-components=1 -C drupal/rootfs/var/www/drupal -xz

mv default_settings.txt drupal/rootfs/var/www/drupal/assets/patches/default_settings.txt

./generate-certs.sh
./generate-secrets.sh

docker compose --profile dev up -d


COUNTER=0
while true; do
  HTTP_STATUS=$(curl -w '%{http_code}' -o /dev/null -s https://islandora.dev/)
  if [ "${HTTP_STATUS}" -eq 200 ]; then
    echo "We're live 🚀"
    exit 0
  fi
  echo "Ping returned ${HTTP_STATUS}"
  ((COUNTER++))
  if [ "${COUNTER}" -eq 50 ]; then
    echo "Failed to come online after 4m"
    exit 1
  fi
  sleep 5;
done
