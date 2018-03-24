//
//  MCFileListCell.m
//  DigiBank
//
//  Created by Moxtra on 2017/3/30.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import "MCFileListCell.h"

@interface MCFileListCell()

@property (nonatomic, strong) UIImageView *fileIconImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *signStateLabel;
@property (nonatomic, strong) UIButton *actionsButton;

@end

//Layout constants
static CGFloat const kIconImageViewInsetsTop = 12.f;
static CGFloat const kIconImageViewInsetsLeft = 16.f;
static CGFloat const kIconImageViewSize = 30.f;

static CGFloat const kTitleLabelHeight = 18.f;
static CGFloat const kDateLabelHeight = 14.f;
static CGFloat const kSignLabelRightMargin = 8.f;
static CGFloat const kButtonSize = 24.f;
static CGFloat const kButtonInsetsTop = 15.f;

@implementation MCFileListCell

#pragma mark - LifeCycle

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        [self setupUserInterface];
    }
    return self;
}

#pragma mark - UserInterface

- (void)setupUserInterface
{
    self.fileIconImageView = [[UIImageView alloc] init];
    self.fileIconImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.fileIconImageView];
    [self.fileIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(kIconImageViewSize);
        make.top.equalTo(self.contentView).with.offset(kIconImageViewInsetsTop);
        make.left.equalTo(self.contentView).with.offset(kIconImageViewInsetsLeft);
    }];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:15];
    self.titleLabel.textColor = MXBlackColor;
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.fileIconImageView);
        make.height.mas_equalTo(kTitleLabelHeight);
        make.left.equalTo(self.fileIconImageView.mas_right).with.offset(kIconImageViewInsetsTop);
    }];
    
    self.dateLabel = [[UILabel alloc] init];
    self.dateLabel.font = [UIFont systemFontOfSize:12];
    self.dateLabel.textColor = MXGray40Color;
    [self.contentView addSubview:self.dateLabel];
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.titleLabel);
        make.top.equalTo(self.titleLabel.mas_bottom);
        make.height.mas_equalTo(kDateLabelHeight);
    }];
    
    self.actionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.actionsButton.backgroundColor = [UIColor whiteColor];
    [self.actionsButton setImage:[UIImage imageNamed:@"file_action_more"] forState:UIControlStateNormal];
    [self.actionsButton.imageView setContentMode:UIViewContentModeCenter];
    [self.actionsButton addTarget:self action:@selector(actionButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.actionsButton];
    self.actionsButton.hidden = YES;
    [self.actionsButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).with.offset(kButtonInsetsTop);
        make.height.width.mas_equalTo(kButtonSize);
        make.right.equalTo(self.contentView.mas_right).with.offset(- kIconImageViewInsetsTop);
    }];
    
    self.signStateLabel = [[UILabel alloc] init];
    self.signStateLabel.font = [UIFont systemFontOfSize:10];
    self.signStateLabel.textColor = MXGray40Color;
    [self.contentView addSubview:self.signStateLabel];
    [self.signStateLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.signStateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.actionsButton);
        make.height.mas_equalTo(kIconImageViewInsetsTop);
        make.right.equalTo(self.actionsButton.mas_left).with.offset( - kSignLabelRightMargin);
        make.left.greaterThanOrEqualTo(self.titleLabel.mas_right);
    }];
}

#pragma mark - Public Setter

- (void)setSignFileItem:(MXSignFileItem *)signFileItem
{
    _signFileItem = signFileItem;
    self.titleLabel.text = _signFileItem.name;
    
    //Config Date
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"MMM dd,yyyy"];
    NSString *dateString = [dateFormatter stringFromDate:_signFileItem.updatedTime];
    self.dateLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Last Modified %@", @"Last Modified %@"),dateString];

    //Config fileIcon
    self.fileIconImageView.image = [self fileTypeIcon:NO];
    
    switch (_signFileItem.state)
    {
        case MXSignFileItemStateFinished:
            self.signStateLabel.text = NSLocalizedString(@"SIGNED", @"SIGNED");
            break;
        case MXSignFileItemStateInProgress:
            self.signStateLabel.text = @"";
            break;
        case MXSignFileItemStateInvalid:
        case MXSignFileItemStateFailed:
        default:
            self.signStateLabel.text = NSLocalizedString(@"VOID", @"VOID");
            break;
    }
}

- (void)setActionButtonHide:(BOOL)actionButtonHide
{
    _actionButtonHide = actionButtonHide;
    self.actionsButton.hidden = actionButtonHide;
}

#pragma mark - WidgetsActions

- (void)actionButtonTapped:(UIButton *)sender
{
    if (self.actionButtonTapped)
    {
        self.actionButtonTapped(self.signFileItem);
    }
}

#pragma mark - Helper

- (UIImage *)fileTypeIcon:(BOOL)isLarge;
{
    NSString *extension = [self.signFileItem.name pathExtension].lowercaseString;
    NSString *fileIconName = nil;
    
    //Get icon name according to the extension
    if([extension isEqualToString:@"docx"]||[extension isEqualToString:@"doc"])
        fileIconName = @"file_type_doc";
    else if([extension isEqualToString:@"jpg"]||[extension isEqualToString:@"jepg"])
        fileIconName = @"file_type_jpg";
    else if([extension isEqualToString:@"key"])
        fileIconName = @"file_type_keynote";
    else if([extension isEqualToString:@"wav"]||[extension isEqualToString:@"mp3"]||[extension isEqualToString:@"wma"]
            ||[extension isEqualToString:@"ra"]||[extension isEqualToString:@"midi"]||[extension isEqualToString:@"ogg"]
            ||[extension isEqualToString:@"ape"]||[extension isEqualToString:@"flac"])
        fileIconName = @"file_type_mp3";
    else if([extension isEqualToString:@"mpeg"] ||[extension isEqualToString:@"mpeg"]||[extension isEqualToString:@"avi"]
            ||[extension isEqualToString:@"mov"]||[extension isEqualToString:@"asf"]|| [extension isEqualToString:@"wmv"]
            ||[extension isEqualToString:@"navi"]||[extension isEqualToString:@"3gp"]||[extension isEqualToString:@"ram"]
            ||[extension isEqualToString:@"mkv"]||[extension isEqualToString:@"flv"]||[extension isEqualToString:@"f4v"]
            ||[extension isEqualToString:@"rmvb"])
        fileIconName = @"file_type_mp4";
    else if([extension isEqualToString:@"numbers"])
        fileIconName = @"file_type_numbers";
    else if([extension isEqualToString:@"pages"])
        fileIconName = @"file_type_pages";
    else if([extension isEqualToString:@"pdf"])
        fileIconName = @"file_type_pdf";
    else if([extension isEqualToString:@"png"])
        fileIconName = @"file_type_png";
    else if([extension isEqualToString:@"pptx"]||[extension isEqualToString:@"ppt"])
        fileIconName = @"file_type_ppt";
    else if([extension isEqualToString:@"xlsx"]||[extension isEqualToString:@"xls"])
        fileIconName = @"file_type_xls";
    else if([extension isEqualToString:@"rar"]||[extension isEqualToString:@"zip"]||[extension isEqualToString:@"7z"] || [extension isEqualToString:@"gz"])
        fileIconName = @"file_type_zip";
    else
        fileIconName = @"file_type_default";
    
    if (isLarge)
        fileIconName = [fileIconName stringByAppendingString:@"_large"];
    
    UIImage *resultFileImge = [UIImage imageNamed:fileIconName];
    if(resultFileImge == nil)
        resultFileImge = isLarge?[UIImage imageNamed:@"file_type_default_large"]:[UIImage imageNamed:@"file_type_default"];
    
    return resultFileImge;
}

@end
