//
//  UserListTableViewCell.h
//  CCDBExample
//
//  Created by cmw on 2021/12/8.
//

#import <UIKit/UIKit.h>
#import "UserModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface UserListTableViewCell : UITableViewCell

- (void)fillCellWithData:(UserModel *)data;

@end


NS_ASSUME_NONNULL_END
