//
//  MCTodoListCell.m
//  MessageCenter
//
//  Created by wubright on 2016/12/5.
//  Copyright © 2016年 moxtra. All rights reserved.
//

#import "MCTodoListCell.h"
#import <Masonry.h>

@interface MCTodoListCell ()

@property (nonatomic, strong) UIButton *checkButton;
@property (nonatomic, strong) UILabel *chatItemLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIButton *flagButton;
@property (nonatomic, strong) UIImageView *avatar;

@end

@implementation MCTodoListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.backgroundColor = [UIColor whiteColor];
        self.separatorInset = UIEdgeInsetsMake(0, 12, 0, 12);

        self.checkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *openImage = [[UIImage imageNamed:@"checkbox_uncheck"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage *closeImage = [UIImage imageNamed:@"checkbox_check"];
        self.checkButton.tintColor = MCColorFontBlack;
        [self.checkButton setImage:openImage forState:UIControlStateNormal];
        [self.checkButton setImage:closeImage forState:UIControlStateSelected];
        self.checkButton.imageView.contentMode = UIViewContentModeCenter;
        [self.checkButton addTarget:self action:@selector(handleComplete) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.checkButton];
        
        self.titleLabel = [UILabel new];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        self.titleLabel.numberOfLines = 1;
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.titleLabel.textColor = [UIColor darkGrayColor];
        [self.contentView addSubview:self.titleLabel];
        
        self.dateLabel = [UILabel new];
        self.dateLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:self.dateLabel];
        
        self.flagButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *unflagImage = [[UIImage imageNamed:@"ChatSDKResource.bundle/todo_priority"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage *flagImage = [[UIImage imageNamed:@"ChatSDKResource.bundle/todo_priority_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self.flagButton setImage:unflagImage forState:UIControlStateNormal];
        [self.flagButton setImage:flagImage forState:UIControlStateSelected];
        [self.flagButton.imageView setContentMode:UIViewContentModeCenter];
        [self.flagButton addTarget:self action:@selector(handleSetFlag) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.flagButton];
        
        self.avatar = [[UIImageView alloc] init];
        self.avatar.backgroundColor = [UIColor clearColor];
        self.avatar.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:self.avatar];

        [self.checkButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.mas_equalTo(0);
            make.width.mas_equalTo(openImage.size.width + 15 * 2);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(10);
            make.left.equalTo(self.checkButton.mas_right).offset(15);
            make.right.equalTo(self.avatar.mas_left).offset(-15);
        }];
        
        [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom);
            make.left.right.equalTo(self.titleLabel);
            make.height.equalTo(self.titleLabel);
            make.bottom.mas_equalTo(-10);
        }];
        
        [self.flagButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.right.mas_equalTo(0);
            make.width.mas_equalTo(flagImage.size.width + 15 * 2);
        }];
        
        [self.avatar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(0);
            make.height.width.mas_equalTo(25);
            make.right.equalTo(self.flagButton.mas_left).offset(-15);
        }];
    }
    return self;
}

#pragma mark - Public Setter

- (void)setTodoItem:(MXTodoItem *)todoItem {
    _todoItem = todoItem;
    
    UIColor *fontColor = self.todoItem.isCompleted ? MCColorFontGray : MCColorFontBlack;
    UIFont *titleFont = [UIFont boldSystemFontOfSize:14];
    UIFont *dateFont = [UIFont systemFontOfSize:12];
    NSInteger strikeThrough = NSUnderlineStyleSingle;
    UIColor *strikeColor = fontColor;
    
    NSMutableDictionary *titleAttr = [NSMutableDictionary dictionaryWithObjectsAndKeys:fontColor, NSForegroundColorAttributeName, titleFont, NSFontAttributeName, nil];
    if (self.todoItem.isCompleted) {
        [titleAttr setValue:@(strikeThrough) forKey:NSStrikethroughStyleAttributeName];
        [titleAttr setValue:strikeColor forKey:NSStrikethroughColorAttributeName];
    }
    self.titleLabel.attributedText = [[NSAttributedString alloc] initWithString:self.todoItem.title attributes:titleAttr];
    
    NSString *dateStr;
    if(self.todoItem.dueTime != nil) {
        if ([self.todoItem.dueTime mc_isSameDay:[NSDate date]]) {
            dateStr = NSLocalizedString(@"Today", @"Today");
        } else {
            dateStr = [NSDate mc_getLocalizedShortDateString:self.todoItem.dueTime];
        }
        
        NSDictionary *dateAttr = @{NSForegroundColorAttributeName: fontColor, NSFontAttributeName: dateFont};
        self.dateLabel.attributedText = [[NSAttributedString alloc] initWithString:dateStr attributes:dateAttr];
        [self.dateLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.height.equalTo(self.titleLabel);
            make.top.equalTo(self.titleLabel.mas_bottom);
            make.bottom.mas_equalTo(-10);
        }];
    } else {
        [self.dateLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.titleLabel);
            make.top.equalTo(self.titleLabel.mas_bottom);
            make.bottom.mas_equalTo(-10);
            make.height.mas_equalTo(0);
        }];
    }
    
    self.flagButton.selected = self.todoItem.flag;
    self.checkButton.selected = self.todoItem.isCompleted;
    
    if (self.todoItem.isCompleted) {
        self.flagButton.tintColor = fontColor;
    } else {
        self.flagButton.tintColor = self.flagButton.isSelected ? MCColorMain : fontColor;
    }
    
    if (!self.todoItem.assignee)
    {
        self.avatar.image = nil;
    }
    else
    {
        [[MCMessageCenterInstance sharedInstance] getRoundedAvatarWithUser:self.todoItem.assignee completionHandler:^(UIImage *avatar, NSError *error) {
            if (error) {
                [[MCMessageCenterViewController sharedInstance] mc_simpleAlertError:error];
            } else if (avatar) {
                self.avatar.image = avatar;
                
                if (self.todoItem.isCompleted) {
                    self.avatar.alpha = 0.3;
                } else {
                    self.avatar.alpha = 1;
                }
            } else {
                self.avatar.image = nil;
            }
        }];
    }
    
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
}

#pragma mark - Widgets Action

- (void)handleComplete {
    MXChatSession *chatModel = [[MXChatSession alloc] initWithChat:self.todoItem.chat];
    [chatModel markTodo:self.todoItem completed:!self.todoItem.isCompleted withCompletionHandler:^(NSError * _Nullable error) {
        if (error) {
            [[MCMessageCenterViewController sharedInstance] mc_simpleAlertError:error];
        }
    }];
}

- (void)handleSetFlag {
    MXChatSession *chatModel = [[MXChatSession alloc] initWithChat:self.todoItem.chat];
    [chatModel markTodo:self.todoItem flag:!self.todoItem.flag completionHandler:^(NSError * _Nullable error) {
        if (error) {
            [[MCMessageCenterViewController sharedInstance] mc_simpleAlertError:error];
        }
    }];
}

@end
