//
//  UserInfoModel.h
//  CCDBExample
//
//  Created by cmw on 2021/12/7.
//

#import <CCDB.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserInfoObject : NSObject <CCDBSaving>

CC_PROPERTY((nonatomic, assign), NSInteger, age)
CC_PROPERTY((nonatomic, assign), NSInteger, viewCount)
CC_PROPERTY((nonatomic, assign), BOOL, liked)
CC_PROPERTY((nonatomic, strong), NSString *, address)
CC_PROPERTY_JSON((nonatomic, strong), NSString *, about, about);

@end

NS_ASSUME_NONNULL_END
