//
//  MCCheckBox.h
//  DigiBank
//
//  Created by Moxtra on 2017/4/7.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 A checkbox use to indicate the selection state.
 */
@interface MCCheckBox : UIControl

@property (nonatomic, strong) UIColor *borderColor;            //Default is [UIColor grayColor]
@property (nonatomic, assign) CGFloat circleBorderWidth;       //Default is 1.f
@property (nonatomic, strong) UIColor *fillColor;              //Default is tintColor
@property (nonatomic, strong) UIColor *makrColor;              //Default is white color

@end
