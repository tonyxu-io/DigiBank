//
//  MCInputTableViewCell.h
//  DigiBank
//
//  Created by Moxtra on 2017/4/19.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 A tableViewCell with UITextFiled inside.
 */
@interface MCInputTableViewCell : UITableViewCell

/**
 The UITextFiled
 */
@property (nonatomic, strong) UITextField *textField;
/**
 TextField's text
 */
@property (nonatomic, strong) NSString *text;

/**
 Whether text can be edited, default is YES
 */
@property (nonatomic, assign) BOOL editable;

@end
