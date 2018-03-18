//
// Don't run this script directly - it will be invoked by a .sh script
//

print('-Injecting into collection ' + dbname + '.' + colctnname + ' including shard key field ' + shardkey)

db = db.getSiblingDB(dbname)

// Use this to later take modulo to get groups of values in each shard key value
var divisor = 8

for (var i = 0; i < quantity; i++) {
    var doc = {}
    doc[shardkey] = i % divisor
    doc.randValue = Math.random()
    db[colctnname].insert(doc)
}

print('-Injected ' + quantity + ' docs where shard key had range of ' + divisor + ' values')
