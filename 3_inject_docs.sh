#!/bin/sh
. ./localenv

printf "\n"
printf "~~Running document injection script\n"
${MONGO_BIN_DIR}/mongo --port "${ROUTERS_PORT_PREFIX}0" --eval "var dbname='${DB_TO_SHARD}', colctnname='${COLCTN_TO_SHARD}', shardkey='${SHARD_KEY}', quantity='${QTY_DOCS_TO_INJECT}'" js/inject_random_docs.js
printf "\n"

