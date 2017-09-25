# Scripts for creating and testing a MongoDB Sharded Cluster on a single Linux host machine/VM

## Introduction

Automates the configuring/running of a quick and dirty, self contained, replicated and sharded MongoDB environment on a local Linux host machine, to help a user explore these features - not to be used for real production environments.

By default, creates an environment containing the following 11 server processes, listening on different local ports:

              --REPLICA-0 mongod
        SHARD0--REPLICA-1 mongod
              --REPLICA-2 mongod

              --REPLICA-0 mongod
        SHARD1--REPLICA-1 mongod
              --REPLICA-2 mongod

              --CONFIG-SVR-1 mongod
        CONFIG--CONFIG-SVR-2 mongod
              --CONFIG-SVR-3 mongod

              --MONGOS-SVR-0 mongos
        ROUTER
              --MONGOS-SVR-1 mongos


## Pre-Requisites

*  Tested on Linux only (Ubuntu 14.04 & 16.04 x86-64 - other Linux variants should be fine). Mac OS X hosts may be ok too, but haven't tested.
*  Requires recent version on MongoDB (eg. 3.2.x or 3.4.x) already installed on the local machine - versions earlier than 3.2 are not supported due to the project's use of the newer feature "Config Server Replica Set".


## Usage Steps

0.  In this root directory, modify file 'localenv' to reflect the local settings required

1.  From the terminal, run the following to delete and re-create the directories to hold Mongo server data files and logs (also kills any mongod/mongos processes that happen to be running on the local machine):

    ```
    $ ./1_rebuild_target_directories.sh
    ```

2.  From the terminal, run the following to configure and start the servers with replication and sharding (this takes a few minutes when first run, if not using "smallfiles", whilst mongod server initialises its data files)

    ```
    $ ./2_start_servers.sh
    ```

3.  **OPTIONAL** From the terminal, run the following to insert lots of small randomly generated documents into the sharded collection, using a small range of values for the shard key

    ```
    $ ./3_inject_docs.sh
    ```

You should now be able to connect to one of the mongos processes, using the Mongo Shell, and run sh.status() to view the status of the cluster.

