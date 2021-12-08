//
//  CCDBDefine.h
//  CCModelDemo
//
//  Created by cmw on 2021/7/6.
//

#ifndef CCDBDefine_h
#define CCDBDefine_h

#define CC_TYPE_STR(type) @#type

#define CC_PROPERTY_TYPE_JSON(policy, classType, propertyName, propertyType, bindJsonKeyPath)\
@property policy classType propertyName;\
@property (nonatomic, strong) CCJSONPathTag *zcc___##propertyName##___##bindJsonKeyPath __attribute__((unavailable("Only a tag for CCDB")));\
@property (nonatomic, strong) CCDBPropertyTag *zcc___##propertyName##___##propertyType __attribute__((unavailable("Only a tag for CCDB")));\

#define CC_PROPERTY_JSON(policy, classType, propertyName, bindJsonKeyPath)\
@property policy classType propertyName;\
@property (nonatomic, strong) CCJSONPathTag *zcc___##propertyName##___##bindJsonKeyPath __attribute__((unavailable("Only a tag for CCDB")));\
@property (nonatomic, strong) CCDBPropertyTag *zcc___##propertyName##___CCModelPropertyTypeDefault __attribute__((unavailable("Only a tag for CCDB")));\

#define CC_PROPERTY_TYPE(policy, classType, propertyName, propertyType)\
@property policy classType propertyName;\
@property (nonatomic, strong) CCDBPropertyTag *zcc___##propertyName##___##propertyType __attribute__((unavailable("Only a tag for CCDB")));\

#define CC_PROPERTY(policy, classType, propertyName)\
@property policy classType propertyName;\
@property (nonatomic, strong) CCDBPropertyTag *zcc___##propertyName##___CCModelPropertyTypeDefault __attribute__((unavailable("Only a tag for CCDB")));\

#define CC_MODEL_PRIMARY_PROPERTY(propertyName)\
+ (void)cc_bindPrimaryProperty {\
    NSString *className = NSStringFromClass([self class]);\
    CCPropertyMapper *propertyMapper = [[CCModelMapperManager sharedInstance].dicPropertyMapper objectForKey:className];\
    propertyMapper.primaryKey = @#propertyName;\
}

#define NOContainerId 0

#endif /* CCDBDefine_h */
