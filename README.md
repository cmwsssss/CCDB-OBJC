# CCDB-OBJC
# CCDB-OBJC是什么
CCDB-OBJC是基于Sqlite3和OBJC编写的高性能数据库框架，致力于能够让使用者在应用层面进行最简单，最快速的数据处理操作。

CCDB拥有一个Swift版本，CCDB的Swift版本由于ORM的处理相对复杂，速度会比OC版本差一些，但是CCDB的Swift版本适配了SwiftUI，使用SwiftUI或者使用纯Swift的开发者请[点此查看](https://github.com/cmwsssss/CCDB)

## 基本特性介绍

#### 易用性:
CCDB-OBJC追求的是最简单，最快速的上手使用，不需要任何额外配置代码就可以实现**数据库<->模型<->JSON**的数据映射，只需要一句代码就可以进行增删改查，而且编程者不需要关注任何数据库底层层面的操作，比如事务，数据库连接池，线程安全等等，CCDB会对应用层的API操作进行优化，保证数据库层面的高效运行

#### 高效性:
CCDB-OBJC是基于sqlite3的多线程模型进行工作的，并且其拥有独立的内存缓存机制，使其性能在绝大多数时候表现比原生sqlite3更好，而且CCDB的OC版本采用了懒加载的方式对复杂属性进行加载，因此在复杂模型上的表现非常好

#### Container:
CCDB-OBJC提供了一个列表解决方案Container，可以非常简单的对列表数据进行保存和读取。

#### 单一拷贝性:
CCDB-OBJC生成的对象，在内存里面只会有一份拷贝

## 使用教程

#### 1. 环境要求
CCDB支持 iOS 6 以上

#### 2. 安装
pod 'CCDB-OBJC'

#### 3. 初始化数据库
在使用CCDB相关API之前要先调用初始化方法
```
[CCDB initializeDBWithVersion:@"1.0"];
```
如果数据模型属性有变化，需要升级数据库时，更改verson即可
