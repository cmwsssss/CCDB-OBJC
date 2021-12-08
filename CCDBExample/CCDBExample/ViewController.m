//
//  ViewController.m
//  CCDBExample
//
//  Created by cmw on 2021/12/7.
//

#import "ViewController.h"
#import "UserListViewController.h"
#import "UserModel.h"
@interface CellDataSource : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) void (^clickHandler)(void);



@end

@implementation CellDataSource

- (instancetype)initWithTitle:(NSString *)title clickHandler:(void (^)(void))clickHandler {
    self = [super init];
    if (self) {
        self.title = title;
        self.clickHandler = clickHandler;
    }
    
    return self;
}

@end

@interface ViewController ()

@property (nonatomic, strong) NSArray <CellDataSource *> *datas;

@end

@implementation ViewController

- (NSArray <CellDataSource *> *)datas {
    if (!_datas) {
        __weak typeof(self) weakSelf = self;
        _datas = @[
            [[CellDataSource alloc] initWithTitle:@"Users 0-15" clickHandler:^{
                [weakSelf onShowUserListViewController:UserListType15];
            }],
            [[CellDataSource alloc] initWithTitle:@"Users 15-30" clickHandler:^{
                [weakSelf onShowUserListViewController:UserListType30];
            }],
            [[CellDataSource alloc] initWithTitle:@"Users all" clickHandler:^{
                [weakSelf onShowUserListViewController:UserListTypeAll];
            }],
            [[CellDataSource alloc] initWithTitle:@"100000次写入" clickHandler:^{
                [weakSelf onWriteTest];
            }],
            [[CellDataSource alloc] initWithTitle:@"读取所有数据" clickHandler:^{
                [weakSelf onLoadAllTest];
            }],
            [[CellDataSource alloc] initWithTitle:@"主键读取所有数据" clickHandler:^{
                [weakSelf onLoadPrimaryPropertyTest];
            }]
            
        ];
    }
    return _datas;
}

- (void)showTimeAlert:(NSTimeInterval)timeInterval {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"SpentTime" message:[NSString stringWithFormat:@"%fs",timeInterval] preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)onWriteTest {
    NSDate *date = [NSDate date];
    for (int i = 0; i < 100000; i++) {
        UserModel *model = [[UserModel alloc] init];
        model.userId = i+100000;
        model.username = [NSString stringWithFormat:@"username-%ld", i];
        [model replaceIntoDB];
    }
    [self showTimeAlert:-[date timeIntervalSinceNow]];
}

- (void)onLoadAllTest {
    NSDate *date = [NSDate date];
    [UserModel loadAllDataWithAsc:NO];
    [self showTimeAlert:-[date timeIntervalSinceNow]];
}

- (void)onLoadPrimaryPropertyTest {
    NSDate *date = [NSDate date];
    for (int i = 100; i < 100100; i++) {
        UserModel *model = [[UserModel alloc] initWithPrimaryProperty:@(i)];
    }
    [self showTimeAlert:-[date timeIntervalSinceNow]];
}

- (void)onShowUserListViewController:(UserListType)type {
    UserListViewController *vc = [[UserListViewController alloc] initWithType:type];
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.datas.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UITableViewCell.description];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = self.datas[indexPath.row].title;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.datas[indexPath.row].clickHandler) {
        self.datas[indexPath.row].clickHandler();
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Main";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:UITableViewCell.description];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
}


@end
