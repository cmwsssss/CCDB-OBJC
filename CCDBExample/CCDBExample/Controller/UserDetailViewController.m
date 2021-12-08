//
//  UserDetailViewController.m
//  CCDBExample
//
//  Created by cmw on 2021/12/8.
//

#import "UserDetailViewController.h"
#import "UserDetailView.h"

NSString *const NotificationUserDidLike = @"NotificationUserDidLike";

@interface UserDetailViewController ()

@property (nonatomic, strong) UserDetailView *view;
@property (nonatomic, strong) UserModel *user;
@end

@implementation UserDetailViewController

- (instancetype)initWithUser:(UserModel *)user {
    self = [super init];
    if (self) {
        self.user = user;
    }
    return self;
}

- (void)loadView {
    self.view = [[UserDetailView alloc] init];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.user = self.user;
    __weak typeof(self) weakSelf = self;
    weakSelf.view.clickLike = ^{
        [weakSelf onClickLike];
    };
    // Do any additional setup after loading the view.
}

- (void)onClickLike {
    self.user.info.liked = !self.user.info.liked;
    [self.user replaceIntoDB];
    self.view.user = self.user;
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationUserDidLike object:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
