//
//  MCCheckBox.m
//  DigiBank
//
//  Created by Moxtra on 2017/4/7.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import "MCCheckBox.h"

@interface MCCheckBox()

@property (nonatomic, strong) CAShapeLayer *borderLayer;
@property (nonatomic, strong) CAShapeLayer *markLayer;

@end

static const CGFloat kBorderInsets = 2.f;

@implementation MCCheckBox

#pragma mark - LifeCycle

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
        [self setupUserInterface];
    }
    return self;
}

#pragma mark - UserInterface

- (void)setupUserInterface
{
    //Set border layer
    CGRect roundRect = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    CGFloat roundSize = MIN(roundRect.size.width, roundRect.size.height);
    UIBezierPath *borderPath = [UIBezierPath bezierPathWithRoundedRect:roundRect cornerRadius:roundSize/2 - kBorderInsets];
    self.borderLayer = [CAShapeLayer layer];
    self.borderLayer.path = borderPath.CGPath;
    self.borderLayer.lineWidth = 1.f;
    self.borderLayer.fillColor = self.fillColor.CGColor;
    self.borderLayer.strokeColor = [UIColor grayColor].CGColor;
    self.borderLayer.frame = roundRect;
    [self.layer addSublayer:self.borderLayer];
    
    //Set mark layer
    UIBezierPath* checkMarkPath = [UIBezierPath bezierPath];
    [checkMarkPath moveToPoint: CGPointMake(roundSize/3.1578, roundSize/2)];
    [checkMarkPath addLineToPoint: CGPointMake(roundSize/2.0618, roundSize/1.57894)];
    [checkMarkPath addLineToPoint: CGPointMake(roundSize/1.3900, roundSize/3.7272)];
    self.markLayer = [CAShapeLayer layer];
    self.markLayer.path = checkMarkPath.CGPath;
    self.markLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.markLayer.fillColor = [UIColor clearColor].CGColor;
    self.markLayer.frame = roundRect;
    self.markLayer.hidden = YES;
    [self.layer addSublayer:self.markLayer];
}

#pragma mark - Public Setter

- (void)setBorderColor:(UIColor *)borderColor
{
    _borderColor = borderColor;
    self.borderLayer.strokeColor = _borderColor.CGColor;
}

- (void)setMakrColor:(UIColor *)makrColor
{
    _makrColor = makrColor;
    self.markLayer.strokeColor = _makrColor.CGColor;
}

- (void)setCircleBorderWidth:(CGFloat)circleBorderWidth
{
    _circleBorderWidth = circleBorderWidth;
    self.borderLayer.lineWidth = _circleBorderWidth;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    if (selected)
    {
        self.borderLayer.fillColor = self.fillColor.CGColor;
        self.markLayer.hidden = NO;
    }
    else
    {
        self.borderLayer.fillColor = [UIColor clearColor].CGColor;
        self.markLayer.hidden = YES;
    }
}

@end
