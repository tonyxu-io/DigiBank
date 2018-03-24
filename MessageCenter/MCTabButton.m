//
//  MCTabButton.m
//  MessageCenter
//
//  Created by Rookie on 12/12/2016.
//  Copyright © 2016 moxtra. All rights reserved.
//

#import "MCTabButton.h"
#import <Masonry.h>

@interface MCTabButton ()

@property (nonatomic, strong) NSArray<UIView *> *separators;

@property (nonatomic, strong) UIImageView *badge;

@end

@implementation MCTabButton

- (instancetype)initWithTitle:(NSString *)title imageName:(NSString *)imageName {
    if (self = [super init]) {
        [self setTitle:title forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont systemFontOfSize:11];
        [self setTitleColor:MCColorFontDarkGray forState:UIControlStateNormal];
        [self setTitleColor:MCColorFontBlack forState:UIControlStateSelected];
        UIImage *image = [[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self setImage:image forState:UIControlStateNormal];
        
        CGSize titleSize = [title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]} context:nil].size;
        [self setTitleEdgeInsets:UIEdgeInsetsMake(0, -image.size.width, -image.size.height-2, 0)];
        [self setImageEdgeInsets:UIEdgeInsetsMake(-titleSize.height, 0, 0, -titleSize.width)];
        
        self.badge = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab_badge"]];
        [self addSubview:self.badge];
        [self.badge mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.imageView);
            make.left.equalTo(self.imageView.mas_right).offset(3);
        }];
        
        self.badge.hidden = YES;
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    [self updateAppearance];
}

- (void)setShowBadge:(BOOL)showBadge {
    _showBadge = showBadge;
    self.badge.hidden = !showBadge;
}

- (void)updateAppearance {
    self.backgroundColor = self.isSelected ? [UIColor whiteColor] : MCColorBackground;
    self.imageView.tintColor = self.isSelected ? MCColorFontBlack : MCColorFontDarkGray;
    
    for (UIView *separator in self.separators) {
        separator.hidden = self.isSelected;
    }
}

@end
