#!/usr/bin/env bash

set -eou pipefail

if [ ! -v ISLE_SITE_TEMPLATE_REF ] || [ "$ISLE_SITE_TEMPLATE_REF" = "" ]; then
  ISLE_SITE_TEMPLATE_REF=heads/main
fi

if [ ! -v ISLANDORA_STARTER_REF ] || [ "$ISLANDORA_STARTER_REF" = "" ]; then
  ISLANDORA_STARTER_REF=heads/main
fi

mkdir -p isle-site-template
pushd "$(pwd)/isle-site-template"

curl -L "https://github.com/Islandora-Devops/isle-site-template/archive/refs/${ISLE_SITE_TEMPLATE_REF}.tar.gz" \
  | tar -xz --strip-components=1
rm -rf .github setup.sh

mv drupal/rootfs/var/www/drupal/assets/patches/default_settings.txt .

curl -L "https://github.com/Islandora-Devops/islandora-starter-site/archive/refs/${ISLANDORA_STARTER_REF}.tar.gz" \
  | tar --strip-components=1 -C drupal/rootfs/var/www/drupal -xz

mv default_settings.txt drupal/rootfs/var/www/drupal/assets/patches/default_settings.txt

rm -rf certs/* secrets/*

readonly CHARACTERS='[A-Za-z0-9]'
readonly LENGTH=32

SALT_FILE=salt
secret=ok
(grep -ao '[A-Za-z0-9_-]' </dev/urandom || true) | head -74 | tr -d '\n' >"${SALT_FILE}"

(grep -ao "${CHARACTERS}" </dev/urandom || true) | head "-${LENGTH}" | tr -d '\n' >"${secret}"

cat "$SALT_FILE"
cat "$secret"

./generate-certs.sh
./generate-secrets.sh

docker compose --profile dev up -d

popd

./scripts/ping.sh
