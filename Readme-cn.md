# What's CCDB
CCDB is a high-performance database framework based on Sqlite3 and Swift, ideal for SwiftUI development
CCDB has an OBJC version , OBJC version is faster , support for dictionary->model mapping , Less code required to use, developers who use OBJC [click here](https://github.com/cmwsssss/CCDB-OBJC)

## Features
****
#### Easy-to-use:
CCDB is very easy to use, Just one line of code to insert, query, delete and update, The programmer does not need to be concerned with any underlying database level operations, such as transactions, database connection pooling, thread safety, etc, CCDB will optimize the API operations at the application level to ensure efficient operation at the database level

#### Efficient:
CCDB is based on the multi-threaded model of sqlite3 and has a separate memory caching mechanism, making its performance better than native sqlite3 in most cases.
