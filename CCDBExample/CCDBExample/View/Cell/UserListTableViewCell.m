//
//  UserListTableViewCell.m
//  CCDBExample
//
//  Created by cmw on 2021/12/8.
//

#import "UserListTableViewCell.h"

@interface UserListTableViewCell ()

@property (nonatomic, strong) UIImageView *imageViewAvatar;
@property (nonatomic, strong) UILabel *labelUsername;
@property (nonatomic, strong) UILabel *labelContent;
@property (nonatomic, strong) UILabel *labelLiked;
@property (nonatomic, strong) UILabel *labelViewCount;

@end

@implementation UserListTableViewCell

- (UIImageView *)imageViewAvatar {
    if (!_imageViewAvatar) {
        _imageViewAvatar = [[UIImageView alloc] init];
        _imageViewAvatar.layer.cornerRadius = 6;
        _imageViewAvatar.clipsToBounds = YES;
        _imageViewAvatar.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_imageViewAvatar];
    }
    return _imageViewAvatar;
}

- (UILabel *)labelUsername {
    if (!_labelUsername) {
        _labelUsername = [[UILabel alloc] init];
        [self.contentView addSubview:_labelUsername];
    }
    return _labelUsername;
}

- (UILabel *)labelContent {
    if (!_labelContent) {
        _labelContent = [[UILabel alloc] init];
        [self.contentView addSubview:_labelContent];
    }
    return _labelContent;
}

- (UILabel *)labelLiked {
    if (!_labelLiked) {
        _labelLiked = [[UILabel alloc] init];
        _labelLiked.text = @"Liked";
        [_labelLiked sizeToFit];
        _labelLiked.hidden = YES;
        [self.contentView addSubview:_labelLiked];
    }
    return _labelLiked;
}

- (UILabel *)labelViewCount {
    if (!_labelViewCount) {
        _labelViewCount = [[UILabel alloc] init];
        [self.contentView addSubview:_labelViewCount];
    }
    return _labelViewCount;
}

- (void)fillCellWithData:(UserModel *)data {
    
    self.imageViewAvatar.image = [UIImage imageNamed:data.avatar];
    
    self.labelUsername.text = data.username;
    [self.labelUsername sizeToFit];
    
    self.labelContent.text = data.headline;
    [self.labelContent sizeToFit];
    
    self.labelViewCount.text = [NSString stringWithFormat:@"viewed : %ld", data.info.viewCount];
    [self.labelViewCount sizeToFit];
    
    self.labelLiked.hidden = !data.info.liked;
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    self.imageViewAvatar.frame = CGRectMake(15, 10, 60, 60);
    self.labelUsername.center = CGPointMake(self.imageViewAvatar.maxX + self.labelUsername.width / 2 + 5, self.imageViewAvatar.centerY - 3 - self.labelUsername.height / 2);
    self.labelContent.center = CGPointMake(self.imageViewAvatar.maxX + self.labelContent.width / 2 + 5, self.imageViewAvatar.centerY + 3 + self.labelContent.height / 2);
    self.labelLiked.center = CGPointMake(self.contentView.width - 10 - self.labelLiked.width / 2, self.labelUsername.centerY);
    self.labelViewCount.center = CGPointMake(self.contentView.width - 10 - self.labelViewCount.width / 2, self.labelContent.centerY);
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
