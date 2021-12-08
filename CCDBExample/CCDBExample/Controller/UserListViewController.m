//
//  UserListViewController.m
//  CCDBExample
//
//  Created by cmw on 2021/12/8.
//

#import "UserListViewController.h"
#import "UserListView.h"
#import "UserListTableViewCell.h"
#import "UserDetailViewController.h"

@interface UserListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UserListView *view;
@property (nonatomic, assign) UserListType type;
@property (nonatomic, strong) NSMutableArray <UserModel *> *users;
@end

@implementation UserListViewController

- (instancetype)initWithType:(UserListType)type {
    self = [super init];
    if (self) {
        self.type = type;
    }
    return self;
}

- (void)loadView {
    self.view = [[UserListView alloc] init];
}

- (void)parseRemoteData:(NSArray *)response {
    [self.users removeAllObjects];
    [UserModel removeAllWithContainerId:self.type];
    [response enumerateObjectsUsingBlock:^(NSDictionary  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.users addObject:[[UserModel alloc] initWithJSONDictionary:obj containerId:self.type]];
    }];
    [self.view.tableView reloadData];
}

- (void)loadRemoteData {
    NSMutableArray *response = [[NSMutableArray alloc] init];
    NSInteger start = 0;
    NSInteger end = 30;
    switch (self.type) {
        case UserListType15:
            end = 15;
            break;
        case UserListType30:
            start = 15;
            end = 30;
            break;
        case UserListTypeAll:
            end = 30;
            break;
        default:
            break;
    }
    for (NSInteger i = start; i < end; i++) {
        NSDictionary *userJson = @{
            @"userId" : @(i),
            @"username" : [NSString stringWithFormat:@"user-%ld", i],
            @"avatar" : [NSString stringWithFormat:@"Image-%ld", i],
            @"about" : @{
                @"headline" : [NSString stringWithFormat:@"headline-%ld", i]
            },
            @"info" : @{
                @"age" : @(i+18),
                @"address" : [NSString stringWithFormat:@"address-%ld", i],
                @"about" : [NSString stringWithFormat:@"about-%ld", i]
            }
        };
        [response addObject:userJson];
    }
    [self parseRemoteData:response];
    
}

- (void)loadData {
    self.title = @"Loading";
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.title = @"User list";
        [self loadRemoteData];
    });
    [self loadDataFromDB];
}

- (void)configTableView {
    self.view.tableView.delegate = self;
    self.view.tableView.dataSource = self;
    [self.view.tableView registerClass:[UserListTableViewCell class] forCellReuseIdentifier:UserListTableViewCell.description];
    [self.view.tableView reloadData];
}

- (void)loadDataFromDB {
    self.users = [UserModel loadAllDataWithAsc:NO containerId:self.type];
    [self.view.tableView reloadData];
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadDataFromDB) name:NotificationUserDidLike object:nil];
}

- (void)onShowUserDetail:(UserModel *)user {
    UserDetailViewController *vc = [[UserDetailViewController alloc] initWithUser:user];
    user.info.viewCount++;
    [user replaceIntoDB];
    [self.view.tableView reloadData];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadData];
    [self configTableView];
    [self addNotification];
    // Do any additional setup after loading the view.
}

#pragma mark --TableView delegate & dataSource--

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.users.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UserListTableViewCell.description];
    [cell fillCellWithData:self.users[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self onShowUserDetail:self.users[indexPath.row]];
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

