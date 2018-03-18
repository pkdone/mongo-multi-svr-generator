//
// Don't run this script directly - it will be invoked by an .sh script
//

print('-Initialising ' + numReplicas + " config replicas for config server replica set on " + host)

config = {_id: "csrs", members:[], settings: {electionTimeoutMillis: 2000}}

for (var replica = 0; replica < numReplicas; replica++) {
    config.members.push({_id: replica, host: host+":"+portPrefix+replica})
}

//printjson(config);
rs.initiate(config)    

