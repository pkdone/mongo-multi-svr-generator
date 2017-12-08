#!/bin/sh
. ./localenv

printf "\n"
printf "~~Killing all mongod & mongos processes on this host (then waiting 5 secs)\n"
killall mongos
killall mongod
sleep 5

printf "~~Removing contents of dir ${ROOT_DIR}\n"
mv env/.gitignore ./_gitignore
rm -rf ${ROOT_DIR}

printf "~~Making directories under ${ROOT_DIR}\n"

# Create Shard mongod server directories (assumes 3 replica sets per shard)
for shard in `seq 0 ${MAX_SHARD}`; do
    for replica in `seq 0 ${MAX_REPLICA}`; do
        mkdir -p $ROOT_DIR/shard${shard}/rs${replica}/data
        mkdir -p $ROOT_DIR/shard${shard}/rs${replica}/logs
    done
done

# Create Config mongod server directories
for config in `seq 0 ${MAX_CONFIG}`; do
    mkdir -p $ROOT_DIR/config/config${config}/data
    mkdir -p $ROOT_DIR/config/config${config}/logs
done

# Create Router mongos server directories
for router in `seq 0 ${MAX_ROUTER}`; do
    mkdir -p $ROOT_DIR/router/router${router}/logs
done

mv _gitignore env/.gitignore
printf "\n"

