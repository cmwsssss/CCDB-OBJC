//
//  UIView+Frame.h
//  CCDBExample
//
//  Created by cmw on 2021/12/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Frame)

@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat x, centerX;
@property (nonatomic, assign) CGFloat y, centerY;
@property (nonatomic, assign, readonly) CGPoint boundsCenter;
@property (nonatomic, assign, readonly) CGPoint visibleCenter;

@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat bottom;
@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat right;

@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGPoint origin;


- (CGFloat)minX;

- (CGFloat)midX;

- (CGFloat)maxX;

- (CGFloat)minY;

- (CGFloat)midY;

- (CGFloat)maxY;

@end

NS_ASSUME_NONNULL_END
