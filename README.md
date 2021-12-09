# CCDB-OBJC
# CCDB-OBJC是什么
CCDB-OBJC是基于Sqlite3和OBJC编写的高性能数据库框架，致力于能够让使用者在应用层面进行最简单，最快速的数据处理操作。

CCDB拥有一个Swift版本，CCDB的Swift版本由于ORM的处理相对复杂，速度会比OC版本差一些，但是CCDB的Swift版本适配了SwiftUI，使用SwiftUI或者使用纯Swift的开发者请[点此查看](https://github.com/cmwsssss/CCDB)

## 基本特性介绍

### 易用性:
CCDB-OBJC追求的是最简单，最快速的上手使用，不需要任何额外配置代码就可以实现**字典原始数据->模型<->数据库**的数据映射，只需要一句代码就可以进行增删改查，而且编程者不需要关注任何数据库底层层面的操作，比如事务，数据库连接池，线程安全等等，CCDB会对应用层的API操作进行优化，保证数据库层面的高效运行

### 高效性:
CCDB-OBJC是基于sqlite3的多线程模型进行工作的，并且其拥有独立的内存缓存机制，使其性能在绝大多数时候表现比原生sqlite3更好，而且CCDB的OC版本采用了懒加载的方式对复杂属性进行加载，因此在复杂模型上的表现非常好

### Container:
CCDB-OBJC提供了一个列表解决方案Container，可以非常简单的对列表数据进行保存和读取。

### 字典原始数据映射:
CCDB-OBJC能够将字典的原始数据映射到模型之上，不需要任何额外mapper代码，让你的数据处理工作更加轻松


#### 单一拷贝性:
CCDB-OBJC生成的对象，在内存里面只会有一份拷贝

## 使用教程

### 1. 环境要求
CCDB支持 iOS 6 以上

### 2. 安装
pod 'CCDB-OBJC'

### 3. 初始化数据库
在使用CCDB相关API之前要先调用初始化方法
```
[CCDB initializeDBWithVersion:@"1.0"];
```
如果数据模型属性有变化，需要升级数据库时，更改verson即可

### 4.接入

#### 继承

接入CCDB的模型需要继承CCModel类

```
@interface UserModel : CCModel
...
@end
```
#### 属性声明：
CCDB支持的类型有：Int，String，Double，Float，Bool以及实现了CCDBSaving协议的类

CCDB提供了4种属性声明的方式，CCDB只会将通过声明宏声明的属性映射入库

##### 1. CC_PROPERTY
对于CCDB支持的类型属性的常规声明方式
```
/*
CC_PROPERTY(policy, classType, propertyName)
policy 该属性的策略，比如noatomic
classType 该属性的类型，比如NSString *
propertyName 该属性的属性名
*/

@interface UserModel : CCModel

CC_PROPERTY((nonatomic, assign), NSInteger, userId);
CC_PROPERTY((nonatomic, strong), NSString *, username);

@end


```

##### 2. CC_PROPERTY_JSON
如果希望CCDB将数据自动从字典数据映射到模型之上，则需要使用CC_PROPERTY_JSON来声明属性
```
/*
CC_PROPERTY_JSON(policy, classType, propertyName, keyPath)
keyPath 通过keyPath将字典内指定的value映射到模型，keyPath通过双下划线(__)来分隔层级

比如需要将下面数据的age映射到模型内，则keyPath为info__age
{
    "userId" : 1
    "username" : "Francis"
    "info" : {
        "age" : 30
    }
}

*/

@interface UserModel : CCModel

CC_PROPERTY_JSON((nonatomic, assign), NSInteger, userId, userId);
CC_PROPERTY_JSON((nonatomic, strong), NSString *, username, username);
CC_PROPERTY_JSON((nonatomic, assign), NSInteger, age, info__age);
@end

*/
```

##### 3. CC_PROPERTY_TYPE
如果希望将CCDB不支持的类型声明为属性，则需要用CC_PROPERTY_TYPE来进行声明
CCDB的属性类型的枚举如下
```
typedef NS_ENUM(NSUInteger, CCModelPropertyType) {
    //默认类型
    CCModelPropertyTypeDefault = 1,
    //被声明的属性为CCModel的子类
    CCModelPropertyTypeModel,
    //被声明的属性为可序列化的字典或数组
    CCModelPropertyTypeJSON,
    //被声明的属性为自定义的类型
    CCModelPropertyTypeCustom,
    //被声明的属性遵循CCDBSaving协议
    CCModelPropertyTypeSavingProtocol,
};
```

1. CCModelPropertyTypeModel
如果属性类型为CCModel的子类，则需要用该类型声明属性，CCDB在写入时，会一并对子属性进行写入操作，查询时亦然
```
@interface MessageModel : CCModel

CC_PROPERTY((nonatomic, strong), NSString *, messageId);
CC_PROPERTY_TYPE((nonatomic, strong), UserModel *, user, CCModelPropertyTypeModel);

@end
```

2. CCModelPropertyTypeJSON
如果属性类型为可序列化的NSArray和NSDictionary，则CCDB会自动将其序列化为自动字符串并进行写入，并在读取时自动映射为NSArray和NSDictionary数据，**CCDB暂时不支持对字典内部key进行查询操作**
```
@interface MomentModel : CCModel

CC_PROPERTY((nonatomic, strong), NSString *, momentId);
CC_PROPERTY_TYPE((nonatomic, strong), NSArray *, comment, CCModelPropertyTypeJSON);

@end
```

3. CCModelPropertyTypeCustom
如果属性是一个自定义属性，比如自己声明的一个类型并且没有遵循CCDBSaving协议，则需要使用CCModelPropertyTypeCustom来进行属性声明，并在当前类下实现编码和反编码方法
```
@interface MomentModel : CCModel

CC_PROPERTY((nonatomic, strong), NSString *, momentId);
CC_PROPERTY_TYPE((nonatomic, strong), MyModel *, myModel, CCModelPropertyTypeCustom);

@end

@implementation MomentModel
 
 
 - (NSMutableDictionary *)customJSONDictionary {
     NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
     //将数据编码为字典
     [dic setObject:myModel.foo forKey:@"myModel_foo"];
     return dic;
 }

 - (void)updateDataWithCustomJSONDictionary:(NSMutableDictionary *)dic {
     //从字典内解码数据
     self.myModel = [[MyModel alloc] init];
     myModel.foo = [dic objectForKey:@"myModel_foo"];
 }
 
 @end
 
```

4. CCModelPropertyTypeSavingProtocol
对于遵循了CCDBSaving协议的类，则需要使用CCModelPropertyTypeSavingProtocol来声明属性
**遵循CCDBSaving的类不需要主键，其属性的声明方式和CCModel一致，其对象无法单独写入数据库，必须作为CCModel的属性存在**

```
@interface MyObject : NSObject <CCDBSaving>

CC_PROPERTY((nonatomic, strong), NSString *, foo_1)
CC_PROPERTY((nonatomic, strong), NSString *, foo_2)

@end
 
@interface MomentModel : CCModel

CC_PROPERTY((nonatomic, strong), NSString *, momentId);
CC_PROPERTY_TYPE((nonatomic, strong), MyObject *, myObject, CCModelPropertyTypeSavingProtocol);

@end
```

CCDB会自动对MyObject内的属性进行序列化和反序列化，如果需要自定义序列化过程，则需要实现如下方法
**如果实现下面方法，则CCDB自动机制会失效，请确保所有属性被妥善处理**
```
 - (void)cc_updateWithJSONDictionary:(NSDictionary *)dic {
    //读取时交换foo_1和foo_2的数据
    self.foo_1 = [dic objectForKey:@"foo_2"];
    self.foo_2 = [dic objectForKey:@"foo_1"];
 }
 
 - (NSMutableDictionary *)cc_JSONDictionary {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    //将数据编码为字典
    [dic setObject:self.foo_1 forKey:@"foo_1"];
    [dic setObject:self.foo_2 forKey:@"foo_2"];
    return dic;
 }
```
##### 4. CC_PROPERTY_TYPE_JSON
如果希望CCDB将数据自动从字典数据自动到自定义类型上，则需要使用该方法声明属性，keyPath机制在上文有介绍，再此就不赘述。
```
@interface MessageModel : CCModel

CC_PROPERTY((nonatomic, strong), NSString *, messageId);
CC_PROPERTY_TYPE_JSON((nonatomic, strong), UserModel *, user, CCModelPropertyTypeModel, user);

@end
```
