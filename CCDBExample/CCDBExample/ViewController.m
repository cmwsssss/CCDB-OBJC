//
//  ViewController.m
//  CCDBExample
//
//  Created by cmw on 2021/12/7.
//

#import "ViewController.h"
#import "UserListViewController.h"
#import "UserModel.h"
#import "SpeedTestModel.h"
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
            [[CellDataSource alloc] initWithTitle:@"Insert 10000 data" clickHandler:^{
                [weakSelf onWriteTest];
            }],
            [[CellDataSource alloc] initWithTitle:@"Insert 100000 data" clickHandler:^{
                [weakSelf onWriteTest100000];
            }],
            [[CellDataSource alloc] initWithTitle:@"Quert all data" clickHandler:^{
                [weakSelf onLoadAllTest];
            }],
            [[CellDataSource alloc] initWithTitle:@"Get 10000 data" clickHandler:^{
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

- (void)onWriteTest100000 {
    NSDate *date = [NSDate date];
    for (int i = 0; i < 100000; i++) {
        SpeedTestModel *model = [[SpeedTestModel alloc] init];
        model.compareId = i;
        [model replaceIntoDB];
    }
    [self showTimeAlert:-[date timeIntervalSinceNow]];
}

- (void)onWriteTest {
    NSDate *date = [NSDate date];
    for (int i = 0; i < 10000; i++) {
        SpeedTestModel *model = [[SpeedTestModel alloc] init];
        model.compareId = i;
        [model replaceIntoDB];
    }
    [self showTimeAlert:-[date timeIntervalSinceNow]];
}

- (void)onLoadAllTest {
    NSDate *date = [NSDate date];
    [SpeedTestModel loadAllDataWithAsc:NO];
    [self showTimeAlert:-[date timeIntervalSinceNow]];
}

- (void)onLoadPrimaryPropertyTest {
    NSDate *date = [NSDate date];
    for (int i = 0; i < 10000; i++) {
        SpeedTestModel *model = [[SpeedTestModel alloc] initWithPrimaryProperty:@(i)];
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
