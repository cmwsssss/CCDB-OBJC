//
//  CCModel+Bitmap.h
//  CCModelDemo
//
//  Created by cmw on 2021/7/2.
//

#import "CCModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (CC_Bitmap)

/**
 @brief CCModelPropertyDataType bitmap of properties
 @discussion
 Using bitmaps to represent data types will be faster when indexing
 */
- (NSString *)cc_dataTypeBitmap;
+ (void)setCC_dataTypeBitmap:(NSString *)bitmap;

/**
 @brief CCModelPropertyType bitmap of properties
 @discussion
 Using bitmaps to represent property types will be faster when indexing
 */
- (NSString *)cc_propertyTypeBitmap;
+ (void)setCC_propertyTypeBitmap:(NSString *)bitmap;

@end

NS_ASSUME_NONNULL_END
