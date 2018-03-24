//
//  MCTabBar.m
//  DigiBank
//
//  Created by Moxtra on 2017/3/28.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import "MCTabBar.h"

#pragma mark - MCTabButton

@implementation MCTabBarButton

- (instancetype)init
{
    if (self = [super init])
    {
        //Set font with different state.
        [self setTitleTextAttributes:@{NSForegroundColorAttributeName:MCColorFontDarkGray} forState:UIControlStateNormal];
        [self setTitleTextAttributes:@{NSForegroundColorAttributeName:MCColorFontBlack} forState:UIControlStateSelected];
    }
    return self;
}

@end

#pragma mark - MCTabBar

@interface MCTabBar()<UITabBarDelegate>

@property (nonatomic, copy) void(^handleSelectedItem)(UITabBarItem *item);
@property (nonatomic, strong) NSArray <UIImageView *> *badgeArray;

@end

@implementation MCTabBar

- (instancetype)initWithFrame:(CGRect)frame
           handleSelectedItem:(void(^)(UITabBarItem *item))handler;
{
    if (self = [super initWithFrame:frame])
    {
        [self setBackgroundImage:[UIImage mc_imageWithColor:[UIColor clearColor] andSize:frame.size]];
        self.handleSelectedItem = handler;
        self.delegate = self;
        self.tintColor = MCColorFontBlack;
    }
    return self;
}

- (void)setItems:(NSArray<UITabBarItem *> *)items animated:(BOOL)animated
{
    [super setItems:items animated:animated];
    //Set selected indicator color to white
    [self setSelectionIndicatorImage:[UIImage mc_imageWithColor:MXWhiteColor andSize:CGSizeMake(self.frame.size.width/self.items.count + 2, self.frame.size.height)]];
    [self addSeperatorAndBadge];
}

- (void)addSeperatorAndBadge
{
    //Add extra UI
    NSMutableArray *mutableBadgeArray = [[NSMutableArray alloc] init];
    for (UIButton *button in self.subviews)
    {
        //Add badge
        UIImageView *badge = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab_badge"]];
        badge.frame = CGRectMake(self.bounds.size.width/self.items.count - 25.f, 15, 6.f, 6.f);
        [button addSubview:badge];
        [mutableBadgeArray addObject:badge];
        //Default is hidden
        badge.hidden = YES;
    }
    self.badgeArray = [mutableBadgeArray copy];
    
    UIButton *button = self.subviews[0];
    for (int i = 1; i < self.items.count; i ++) {
        //Add seperator
        UIView *seperator = [[UIView alloc] init];
        seperator.backgroundColor = MXWhiteColor;
        seperator.frame = CGRectMake(i * (self.bounds.size.width/self.items.count), 5, 1, self.bounds.size.height - 10);
        [self insertSubview:seperator belowSubview:button];
    }
}

#pragma mark - Public Method

- (void)setBadgeAtIndex:(NSUInteger)index show:(BOOL)show
{
    if (self.badgeArray.count >= index + 1)
    {
        UIImageView *badge = self.badgeArray[index];
        if (badge)
        {
            badge.hidden = !show;
        }
    }
}

- (void)selectIndex:(NSUInteger)index
{
    if (self.items.count >= index + 1)
    {
        self.selectedItem = self.items[index];
        if (self.handleSelectedItem)
        {
            self.handleSelectedItem(self.items[index]);
        }
    }
}

#pragma mark - UITabBarDelegate

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    if (self.handleSelectedItem)
    {
        self.handleSelectedItem(item);
    }
}

@end
