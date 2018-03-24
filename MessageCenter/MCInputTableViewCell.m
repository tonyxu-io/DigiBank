//
//  MCInputTableViewCell.m
//  DigiBank
//
//  Created by Moxtra on 2017/4/19.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import "MCInputTableViewCell.h"

@implementation MCInputTableViewCell

@synthesize text = _text;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self configTextFiled];
    }
    return self;
}

- (void)configTextFiled
{
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(15.0f, 0.0f,self.frame.size.width - 25.0f, self.frame.size.height)];
    textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    textField.textAlignment = NSTextAlignmentLeft;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    textField.font = [UIFont systemFontOfSize:15];
    textField.returnKeyType = UIReturnKeyDone;
    textField.textColor = [UIColor blackColor];
    self.textField = textField;
    [self.contentView addSubview:textField];
    [self setEditable:YES];
}

#pragma mark - PublicSetter

- (void)setText:(NSString *)text
{
    _text = text;
    self.textField.text = _text;
}

- (NSString *)text
{
    return self.textField.text;
}

- (void)setEditable:(BOOL)editable
{
    _editable = editable;
    self.textField.enabled = _editable;
    self.textField.textColor = _editable ? MXBlackColor : MXGray40Color;
}

@end
