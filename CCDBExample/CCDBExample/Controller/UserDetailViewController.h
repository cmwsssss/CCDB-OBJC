//
//  UserDetailViewController.h
//  CCDBExample
//
//  Created by cmw on 2021/12/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN NSString *const NotificationUserDidLike;

@class UserModel;

@interface UserDetailViewController : UIViewController

- (instancetype)initWithUser:(UserModel *)user;

@end

NS_ASSUME_NONNULL_END
