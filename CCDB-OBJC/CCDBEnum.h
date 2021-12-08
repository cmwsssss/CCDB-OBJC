//
//  CCDBEnum.h
//  CCModelDemo
//
//  Created by cmw on 2021/7/8.
//

#ifndef CCDBEnum_h
#define CCDBEnum_h

typedef NS_ENUM(NSUInteger, CCModelPropertyDataType) {
    CCModelPropertyDataTypeBool = 1,
    CCModelPropertyDataTypeString,
    CCModelPropertyDataTypeInt,
    CCModelPropertyDataTypeFloat,
    CCModelPropertyDataTypeLong,
    CCModelPropertyDataTypeRaw
};

typedef NS_ENUM(NSUInteger, CCModelPropertyType) {
    CCModelPropertyTypeDefault = 1,
    CCModelPropertyTypeModel,
    CCModelPropertyTypeJSON,
    CCModelPropertyTypeCustom,
    CCModelPropertyTypeSavingProtocol,
};

#endif /* CCDBEnum_h */
