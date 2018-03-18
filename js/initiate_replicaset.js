//
// Don't run this script directly - it will be invoked by an .sh script
//

print('-Initialising ' + numReplicas + " replicas for shard " + shard + " on " + host)

config = {_id: "s" + shard, members:[], settings: {electionTimeoutMillis: 2000}}

for (var replica = 0; replica < numReplicas; replica++) {
    config.members.push({_id: replica, host: host+":"+portPrefix+shard+replica})
}

//printjson(config);
rs.initiate(config)    

