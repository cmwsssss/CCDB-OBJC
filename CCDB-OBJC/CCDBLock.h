//
//  CCDBLock.h
//  Pods-CCDBExample
//
//  Created by cmw on 2022/1/4.
//

#include <pthread.h>

void ccdb_readLock(void);
void ccdb_writeLock(void);
void ccdb_unlock(void);
