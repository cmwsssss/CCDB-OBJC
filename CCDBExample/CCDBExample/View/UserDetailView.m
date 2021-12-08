//
//  UserDetailView.m
//  CCDBExample
//
//  Created by cmw on 2021/12/8.
//

#import "UserDetailView.h"

@interface UserDetailView ()

@property (nonatomic, strong) UILabel *labelUsername;
@property (nonatomic, strong) UILabel *labelAge;
@property (nonatomic, strong) UILabel *labelHeadline;
@property (nonatomic, strong) UILabel *labelAddress;
@property (nonatomic, strong) UILabel *labelAbout;
@property (nonatomic, strong) UIImageView *imageViewAvatar;
@property (nonatomic, strong) UIButton *buttonLike;

@end

@implementation UserDetailView

- (UILabel *)labelUsername {
    if (!_labelUsername) {
        _labelUsername = [[UILabel alloc] init];
        [self addSubview:_labelUsername];
    }
    return _labelUsername;
}

- (UILabel *)labelAge {
    if (!_labelAge) {
        _labelAge = [[UILabel alloc] init];
        [self addSubview:_labelAge];
    }
    return _labelAge;
}

- (UILabel *)labelHeadline {
    if (!_labelHeadline) {
        _labelHeadline = [[UILabel alloc] init];
        [self addSubview:_labelHeadline];
    }
    return _labelHeadline;
}

- (UILabel *)labelAddress {
    if (!_labelAddress) {
        _labelAddress = [[UILabel alloc] init];
        [self addSubview:_labelAddress];
    }
    return _labelAddress;
}

- (UILabel *)labelAbout {
    if (!_labelAbout) {
        _labelAbout = [[UILabel alloc] init];
        [self addSubview:_labelAbout];
    }
    return _labelAbout;
}

- (UIImageView *)imageViewAvatar {
    if (!_imageViewAvatar) {
        _imageViewAvatar = [[UIImageView alloc] init];
        _imageViewAvatar.contentMode = UIViewContentModeScaleAspectFill;
        _imageViewAvatar.clipsToBounds = YES;
        [self addSubview:_imageViewAvatar];
    }
    return _imageViewAvatar;
}

- (UIButton *)buttonLike {
    if (!_buttonLike) {
        _buttonLike = [[UIButton alloc] init];
        [_buttonLike setTitleColor:[UIColor systemBlueColor] forState:UIControlStateNormal];
        [_buttonLike addTarget:self action:@selector(onClickLike) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_buttonLike];
    }
    return _buttonLike;
}

- (void)onClickLike {
    if (self.clickLike) {
        self.clickLike();
    }
}

- (void)setUser:(UserModel *)user {
    _user = user;
    self.labelUsername.text = user.username;
    [self.labelUsername sizeToFit];
    
    self.labelHeadline.text = user.headline;
    [self.labelHeadline sizeToFit];

    self.labelAbout.text = user.info.about;
    [self.labelAbout sizeToFit];

    self.labelAge.text = [NSString stringWithFormat:@"Age: %ld", user.info.age];
    [self.labelAge sizeToFit];

    self.labelAddress.text = user.info.address;
    [self.labelAddress sizeToFit];

    self.imageViewAvatar.image = [UIImage imageNamed:user.avatar];
    if (!user.info.liked) {
        [self.buttonLike setTitle:@"Like" forState:UIControlStateNormal];
    } else {
        [self.buttonLike setTitle:@"Unlike" forState:UIControlStateNormal];
    }
}

- (void)layoutSubviews {
    self.backgroundColor = [UIColor whiteColor];
    self.imageViewAvatar.frame = CGRectMake(10, 100, self.width - 20, self.width - 20);
    self.labelUsername.center = CGPointMake(10 + self.labelUsername.width / 2, self.imageViewAvatar.maxY + 10 + self.labelUsername.height / 2);
    self.labelAge.center = CGPointMake(10 + self.labelAge.width / 2, self.labelUsername.maxY + 10 + self.labelAge.height / 2);
    self.labelHeadline.center = CGPointMake(10 + self.labelHeadline.width / 2, self.labelAge.maxY + 10 + self.labelHeadline.height / 2);
    self.labelAddress.center = CGPointMake(10 + self.labelAddress.width / 2, self.labelHeadline.maxY + 10 + self.labelAddress.height / 2);
    self.labelAbout.center = CGPointMake(10 + self.labelAbout.width / 2, self.labelAddress.maxY + 10 + self.labelAbout.height / 2);
    self.buttonLike.frame = CGRectMake(10, self.labelAbout.maxY + 20, self.width - 20, 46);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
