//
//  UserModel.h
//  CCDBExample
//
//  Created by cmw on 2021/12/7.
//

#import <CCDB.h>
#import "UserInfoObject.h"
NS_ASSUME_NONNULL_BEGIN

@interface UserModel : CCModel

CC_PROPERTY_JSON((nonatomic, assign), NSInteger, userId, userId);
CC_PROPERTY_JSON((nonatomic, strong), NSString *, username, username);
CC_PROPERTY_JSON((nonatomic, strong), NSString *, avatar, avatar);
CC_PROPERTY_JSON((nonatomic, strong), NSString *, headline, about__headline);
CC_PROPERTY_TYPE_JSON((nonatomic, assign), UserInfoObject *, info, CCModelPropertyTypeSavingProtocol, info)

@end

NS_ASSUME_NONNULL_END
