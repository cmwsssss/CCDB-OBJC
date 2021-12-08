//
//  CCModel+Bitmap.m
//  CCModelDemo
//
//  Created by cmw on 2021/7/2.
//

#import "NSObject+Bitmap.h"
#import <objc/message.h>
@implementation NSObject (CC_Bitmap)

- (NSString *)cc_dataTypeBitmap {
    return objc_getAssociatedObject([self class], "cc_dataTypeBitmap");

}

+ (void)setCC_dataTypeBitmap:(NSString *)bitmap {
    objc_setAssociatedObject([self class], "cc_dataTypeBitmap", bitmap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)cc_propertyTypeBitmap {
    return objc_getAssociatedObject([self class], "cc_propertyTypeBitmap");
}

+ (void)setCC_propertyTypeBitmap:(NSString *)bitmap {
    objc_setAssociatedObject([self class], "cc_propertyTypeBitmap", bitmap, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
