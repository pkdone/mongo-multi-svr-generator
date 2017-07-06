#!/bin/sh
# See tuturial "Deploy a Sharded Cluster": https://docs.mongodb.com/manual/tutorial/deploy-shard-cluster/
# Note: Running servers with following params which you may want to remove:  --smallfiles --oplogSize 50 
. ./localenv

OUTFILE=${ROOT_DIR}/summary.txt
printf "\n"
printf "\nCOMMANDS\n~~~~~~~~\n" > ${OUTFILE}
configHostPortList=""
shardReplicaSetsURIList=""
summary=""

# Start each of the Config Server Replica Set mongod servers to support sharding
for config in `seq 0 ${MAX_CONFIG}`; do
    printf "~~Starting: Config server ${config}\n"
    port="${CONFIGS_PORT_PREFIX}${config}"
    printf "Config server ${config}:\n" >> ${OUTFILE}
    echo "${MONGO_BIN_DIR}/mongod --configsvr --replSet csrs --logpath \"${ROOT_DIR}/config/config${config}/logs/cfg${config}.log\" --dbpath \"${ROOT_DIR}/config/config${config}/data\" --port ${port} --fork --smallfiles --oplogSize 50" >> ${OUTFILE}
    ${MONGO_BIN_DIR}/mongod --configsvr --replSet csrs --logpath "${ROOT_DIR}/config/config${config}/logs/cfg${config}.log" --dbpath "${ROOT_DIR}/config/config${config}/data" --port ${port} --fork --smallfiles --oplogSize 50 
    configHostPortList="${configHostPortList}${HOST}:${port},"
    summary="${summary}\nmongod\tconfig server ${config}  \tport: ${port}"
    printf "\n"
    printf "\n" >> ${OUTFILE}
done

# Connect to the 1st server in the Config Server Replica Set, via mongo shell and initialise the replica set
printf "~~Initialising config server replica set\n"
${MONGO_BIN_DIR}/mongo --port "${CONFIGS_PORT_PREFIX}0" --eval "var host='${HOST}', portPrefix='${CONFIGS_PORT_PREFIX}', numReplicas='${NUM_CONFIGS}'" js/initiate_csrs.js
printf "\n"

# For each Shard, start set of Replica mongod servers 
for shard in `seq 0 ${MAX_SHARD}`; do
    for replica in `seq 0 ${MAX_REPLICA}`; do
        printf "~~Starting: Shard ${shard} - Replica ${replica}\n"
        port="${SHARDS_PORT_PREFIX}${shard}${replica}"
        printf "Shard ${shard} - Replica ${replica}:\n" >> ${OUTFILE}
        echo "${MONGO_BIN_DIR}/mongod --shardsvr --replSet s${shard} --logpath \"${ROOT_DIR}/shard${shard}/rs${replica}/logs/s${shard}-r${replica}.log\" --dbpath \"${ROOT_DIR}/shard${shard}/rs${replica}/data\" --port ${port} --fork --smallfiles --oplogSize 50" >> ${OUTFILE}
        ${MONGO_BIN_DIR}/mongod --shardsvr --replSet s${shard} --logpath "${ROOT_DIR}/shard${shard}/rs${replica}/logs/s${shard}-r${replica}.log" --dbpath "${ROOT_DIR}/shard${shard}/rs${replica}/data" --port ${port} --fork --smallfiles --oplogSize 50 
        summary="${summary}\nmongod\tshard-replica ${shard}-${replica}\tport: ${port}"
        printf "\n"
        printf "\n" >> ${OUTFILE}

        if [ "${replica}" -eq "0" ]; then
            shardReplicaSetsURIList="${shardReplicaSetsURIList}s${shard}/${HOST}:${port},"
        fi
    done
done

# For each Shard, connect to the 1st Replica server, via mongo shell and initialise the replica set
for shard in `seq 0 ${MAX_SHARD}`; do
    printf "~~Initialising replica set ready for shard ${shard}\n"
    ${MONGO_BIN_DIR}/mongo --port "${SHARDS_PORT_PREFIX}${shard}0" --eval "var host='${HOST}', portPrefix='${SHARDS_PORT_PREFIX}', shard=${shard}, numReplicas='${NUM_REPLICAS_PER_SHARD}'" js/initiate_replicaset.js
    printf "\n"
done

# Trim trailing comma (,) off the comma seperated contructed lists of strings
configHostPortList=${configHostPortList%?}
shardReplicaSetsURIList=${shardReplicaSetsURIList%?}

# Need a little sleep before mongoses
sleep 1

# Start each of the Router mongos servers
for router in `seq 0 ${MAX_ROUTER}`; do
    printf "~~Starting: Router mongos server ${router}\n"
    port="${ROUTERS_PORT_PREFIX}${router}"
    printf "Router mongos server:\n" >> ${OUTFILE}
    echo "${MONGO_BIN_DIR}/mongos --logpath \"${ROOT_DIR}/router/router${router}/logs/rtr${router}.log\" --configdb \"csrs/${configHostPortList}\" --port ${port} --fork" >> ${OUTFILE}
    ${MONGO_BIN_DIR}/mongos --logpath "${ROOT_DIR}/router/router${router}/logs/rtr${router}.log" --configdb "csrs/${configHostPortList}" --port ${port} --fork
    summary="${summary}\nmongos\trouter server ${router}  \tport: ${port}"
    printf "\n"
    printf "\n" >> ${OUTFILE}
done

# Via the first Router mongos, configure sharding with the set of replica sets, via mongo shell and enable sharding for a db.collection
printf "~~Initialising sharding on replica sets using 1st mongos router\n"
#echo "var shardReplicaSetsURI='${shardReplicaSetsURIList}', dbname='${DB_TO_SHARD}', colctnname='${COLCTN_TO_SHARD}', shardkey='${SHARD_KEY}'"
${MONGO_BIN_DIR}/mongo --host "${HOST}" --port "${ROUTERS_PORT_PREFIX}0" --eval "var shardReplicaSetsURI='${shardReplicaSetsURIList}', dbname='${DB_TO_SHARD}', colctnname='${COLCTN_TO_SHARD}', shardkey='${SHARD_KEY}'" js/configure_shards.js
    printf "\n"

# Print summary
printf "\nSUMMARY\n~~~~~~~${summary}\n\n"
printf "SUMMARY\n~~~~~~~${summary}\n\n" >> $OUTFILE
printf "For more detail, inc. server start commands, see file: ${OUTFILE}\n\n"


