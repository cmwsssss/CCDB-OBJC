//
//  CCBackgroundDBManager.h
//  CCModelDemo
//
//  Created by cmw on 2021/7/5.
//

#import <Foundation/Foundation.h>
@class CCModel;
NS_ASSUME_NONNULL_BEGIN

@interface CCDBUpdateManager : NSObject

+ (instancetype)sharedInstance;
- (void)addModel:(CCModel *)model;

@end

NS_ASSUME_NONNULL_END
