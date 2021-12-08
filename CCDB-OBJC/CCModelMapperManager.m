//
//  CCModelMapperManager.m
//  CCModelDemo
//
//  Created by cmw on 2021/7/2.
//

#import "CCModelMapperManager.h"
#import <objc/message.h>
#import "NSObject+Bitmap.h"
#import "CCModelUtils.h"
#import "NSObject+CC_JSON.h"
#import "CCModel+ExtractData.h"
@implementation CCJSONModelMapper

- (NSMutableDictionary <NSString *, NSString *> *)dicJSONToProperty {
    if (!_dicJSONToProperty) {
        _dicJSONToProperty = [[NSMutableDictionary alloc] init];
    }
    return _dicJSONToProperty;
}

- (NSMutableDictionary <NSString *, NSNumber *> *)dicJSONPrimaryKey {
    if (!_dicJSONPrimaryKey) {
        _dicJSONPrimaryKey = [[NSMutableDictionary alloc] init];
    }
    return _dicJSONPrimaryKey;
}

- (NSMutableDictionary <NSString *, NSString *> *)dicPropertyToJSON {
    if (!_dicPropertyToJSON) {
        _dicPropertyToJSON = [[NSMutableDictionary alloc] init];
    }
    return _dicPropertyToJSON;
}

@end

@implementation CCPropertyMapper

- (NSMutableArray <NSString *> *)arrayDBPropertyName {
    if (!_arrayDBPropertyName) {
        _arrayDBPropertyName = [[NSMutableArray alloc] init];
    }
    return _arrayDBPropertyName;
}

- (NSMutableDictionary *)dicPropertyType {
    if (!_dicPropertyType) {
        _dicPropertyType = [[NSMutableDictionary alloc] init];
    }
    return _dicPropertyType;
}

@end

@implementation CCModelMapperManager

static CCModelMapperManager *s_instance;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_instance = [[CCModelMapperManager alloc] init];
    });
    return s_instance;
}

- (NSMutableDictionary <NSString *, CCJSONModelMapper*> *)dicJSONMapper {
    if (!_dicJSONMapper) {
        _dicJSONMapper = [[NSMutableDictionary alloc] init];
    }
    return _dicJSONMapper;
}

- (NSMutableDictionary <NSString *, CCPropertyMapper*> *)dicPropertyMapper {
    if (!_dicPropertyMapper) {
        _dicPropertyMapper = [[NSMutableDictionary alloc] init];
    }
    return _dicPropertyMapper;
}

NSInvocation *createInvocation(id target, SEL sel) {
    
    NSString *hash = [NSString stringWithFormat:@"%ld",[target hash]];
    NSString *newSel = [hash stringByAppendingString:NSStringFromSelector(sel)];
    
    NSMethodSignature *sign = [target methodSignatureForSelector:sel_getUid(newSel.UTF8String)];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sign];
    invocation.target = target;
    invocation.selector = sel_getUid(newSel.UTF8String);
    return invocation;
}

static id extractDataMethodWithParams(CCModel *target, SEL sel, ...) {
    
    NSString *propertyName = [NSString stringWithCString:sel_getName(sel) encoding:NSUTF8StringEncoding];
    if (![target valueForKey:[NSString stringWithFormat:@"_%@", propertyName]]) {
        CCPropertyMapper *propertyMapper = [[CCModelMapperManager sharedInstance].dicPropertyMapper objectForKey:NSStringFromClass([target class])];
        [propertyMapper.arrayDBPropertyName enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isEqualToString:propertyName]) {
                [target extractDataWithProperty:propertyName type:(int)(target.cc_propertyTypeBitmap.UTF8String[idx])];
                *stop = YES;
            }
        }];
    }
    
    NSString *ivarName = [NSString stringWithFormat:@"_%s", sel_getName(sel)];
    return [target valueForKey:ivarName];
}

- (void)initializeAllMappers {
    unsigned int count;
    Class *classList = objc_copyClassList(&count);
    
    for (int i = 0; i < count; i++) {
        Class class = classList[i];
        if(strcmp("CCModel", class_getName(class_getSuperclass(class)))== 0) {
            [self initializeMapperWithClass:class];
        }
        unsigned int protocolCount;
        Protocol * __unsafe_unretained *protocols = class_copyProtocolList(class, &protocolCount);
        for (int j = 0; j < protocolCount; j++) {
            Protocol *protocol = protocols[j];
            const char *protocolName = protocol_getName(protocol);
            if(strcmp("CCDBSaving", protocolName) == 0) {
                [self initializeMapperWithClass:class];
            }
        }
    }
    free(classList);
}

- (void)initializeMapperWithClass:(Class)class {
    NSString *className = NSStringFromClass(class);
        
    SEL primarySel = sel_getUid("cc_bindPrimaryProperty");
    
    CCPropertyMapper *propertyMapper = [[CCPropertyMapper alloc] init];
    [self.dicPropertyMapper setObject:propertyMapper forKey:className];
    
    CCJSONModelMapper *JSONMapper = [[CCJSONModelMapper alloc] init];
    [self.dicJSONMapper setObject:JSONMapper forKey:className];
    
    if ([class respondsToSelector:primarySel]) {
        ((void (*) (id, SEL))objc_msgSend)(class, primarySel);
    }
    unsigned int count;
    objc_property_t *list = class_copyPropertyList(class, &count);
    NSMutableString *dataTypeBitmap = [[NSMutableString alloc] init];
    NSMutableString *propertyTypeBitmap = [[NSMutableString alloc] init];
    for (int i = 0; i < count; i++) {
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(list[i])];
        Class propertyClass = [CCModelUtils loadClassFromProperty:list[i]];
        if ([propertyClass isEqual:[CCDBPropertyTag class]]) {
            NSArray *array = [propertyName componentsSeparatedByString:@"___"];
            NSString *realPropertyName = array[1];
            NSString *realPropertyModelType = array[2];
            NSString *types = [NSString stringWithUTF8String:property_getAttributes(class_getProperty(class, realPropertyName.UTF8String))];
            NSString *type = [types componentsSeparatedByString:@","].firstObject;
                        
            NSString *subBitmap;
            if (![realPropertyModelType isEqualToString:CC_TYPE_STR(CCModelPropertyTypeDefault)]) {
                subBitmap = [NSString stringWithFormat:@"%c", (char)CCModelPropertyDataTypeRaw];
                Method method = class_getInstanceMethod(class, sel_getUid(realPropertyName.UTF8String));
                const char *types = method_getTypeEncoding(method);
                class_replaceMethod(class, sel_getUid(realPropertyName.UTF8String), (IMP)extractDataMethodWithParams, types);
            } else {
                subBitmap = [NSString stringWithFormat:@"%c", (char)[CCModelUtils getDataTypeWithTypeString:type]];
                
            }
            
            NSInteger propertyType = [CCModelUtils getPropertyTypeWithString:realPropertyModelType];
            [propertyMapper.dicPropertyType setObject:@(propertyType) forKey:realPropertyName];
            
            if (![realPropertyName isEqualToString:propertyMapper.primaryKey]) {
                [propertyMapper.arrayDBPropertyName addObject:realPropertyName];
                [dataTypeBitmap appendString:subBitmap];
                [propertyTypeBitmap appendFormat:@"%c", (char)propertyType];
            } else {
                [propertyMapper.arrayDBPropertyName insertObject:realPropertyName atIndex:0];
                [dataTypeBitmap insertString:subBitmap atIndex:0];
                [propertyTypeBitmap insertString:[NSString stringWithFormat:@"%c", (char)propertyType] atIndex:0];
            }
            [JSONMapper.dicPropertyToJSON setObject:realPropertyName forKey:realPropertyName];
        } else if ([propertyClass isEqual:[CCJSONPathTag class]]) {
            NSArray *array = [propertyName componentsSeparatedByString:@"___"];
            NSString *realPropertyName = array[1];
            for (int i = 2; i < array.count; i++) {
                [JSONMapper.dicJSONToProperty setObject:realPropertyName forKey:array[i]];
                if ([realPropertyName isEqualToString:propertyMapper.primaryKey]) {
                    [JSONMapper.dicJSONPrimaryKey setObject:@(1) forKey:array[i]];
                }
                [JSONMapper.dicPropertyToJSON setObject:array[i] forKey:realPropertyName];
            }
        }
    }
    
    [class setCC_dataTypeBitmap:dataTypeBitmap];
    [class setCC_propertyTypeBitmap:propertyTypeBitmap];
        
    free(list);
}

@end
