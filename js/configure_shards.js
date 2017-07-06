//
// Don't run this script directly - it will be invoked by a .sh script
//

// Split URI list up by its comma seperators
var shardArray = shardReplicaSetsURI.split(',');

if (shardArray.length > 0) {
    for(var i = 0; i < shardArray.length; i++) {
        print('-Adding shard ' + shardArray[i]);
        sh.addShard(shardArray[i]);
    }

    sleep(2);
    //sh.status();
    print('-Enabling shard on db ' + dbname)
    sh.enableSharding(dbname);
    db = db.getSiblingDB(dbname);
}

// Build shard key index document
var indexDoc = {};
indexDoc[shardkey] = 1;
//printjson(indexDoc);

print('-Ensuring index exists in ' + dbname+'.'+colctnname + ' for key ' + JSON.stringify(indexDoc));
db[colctnname].ensureIndex(indexDoc);

if (shardArray.length > 0) {
    print('-Enabling shard on ' + dbname+'.'+colctnname + ' for key ' + JSON.stringify(indexDoc));
    sh.shardCollection(dbname+'.'+colctnname, indexDoc);
}

