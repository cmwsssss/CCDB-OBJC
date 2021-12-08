//
//  UserDetailView.h
//  CCDBExample
//
//  Created by cmw on 2021/12/8.
//

#import <UIKit/UIKit.h>
#import "UserModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface UserDetailView : UIView

@property (nonatomic, strong) void (^clickLike)(void);
@property (nonatomic, strong) UserModel *user;

@end

NS_ASSUME_NONNULL_END
