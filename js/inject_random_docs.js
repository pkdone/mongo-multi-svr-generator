//
// Don't run this script directly - it will be invoked by a .sh script
//

print('-Injecting into collection ' + dbname + '.' + colctnname + ' including shard key field ' + shardkey)

db = db.getSiblingDB(dbname)

// Use this to later take modulo to get groups of values in each shard key value
const shard_key_divisor = 8

// Create possible colour values
const colours = ['red', 'blue', 'green'];
const colour_divisor = colours.length;

for (let i = 0; i < quantity; i++) {
    let doc = {}
    doc[shardkey] = i % shard_key_divisor
    doc.randValue = Math.random()
    doc.favColour = colours[i % colour_divisor];
    doc.message = "Hello from the document which has the a value: " + doc.randValue;
    db[colctnname].insert(doc)
}

print('-Injected ' + quantity + ' docs where shard key had range of ' + shard_key_divisor + ' values')
