//
//  NSObject+CC_JSON.h
//  CCModelDemo
//
//  Created by cmw on 2021/7/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (CC_JSON)

- (id)JSONValue;
- (NSString *)JSONString;
- (void)setNonNullValue:(NSObject *)value forKeyPath:(NSString *)keyPath;


@end

NS_ASSUME_NONNULL_END
