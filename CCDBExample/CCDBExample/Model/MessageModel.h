//
//  MessageModel.h
//  CCDBExample
//
//  Created by cmw on 2021/12/7.
//

#import <CCDB.h>
#import "UserModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface MessageModel : CCModel

CC_PROPERTY((nonatomic, strong), NSString *, messageId);
CC_PROPERTY_JSON((nonatomic, strong), NSString *, title, title);
CC_PROPERTY_JSON((nonatomic, strong), NSString *, content, content);
CC_PROPERTY_TYPE_JSON((nonatomic, strong), UserModel *, user, CCModelPropertyTypeModel, user);

@end

NS_ASSUME_NONNULL_END
