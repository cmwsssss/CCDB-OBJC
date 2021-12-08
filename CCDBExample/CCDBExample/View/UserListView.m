//
//  UserListView.m
//  CCDBExample
//
//  Created by cmw on 2021/12/8.
//

#import "UserListView.h"



@implementation UserListView

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_tableView];
    }
    return _tableView;
}

- (void)layoutSubviews {
    self.tableView.frame = self.bounds;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
