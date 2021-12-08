//
//  UserListViewController.h
//  CCDBExample
//
//  Created by cmw on 2021/12/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger, UserListType) {
    UserListTypeAll = 1,
    UserListType15 = 2,
    UserListType30 = 3
};

@interface UserListViewController : UIViewController

- (instancetype)initWithType:(UserListType)type;

@end

NS_ASSUME_NONNULL_END
