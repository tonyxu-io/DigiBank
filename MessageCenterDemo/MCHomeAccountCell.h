//
//  MCHomeAccountCell.h
//  MessageCenter
//
//  Created by wubright on 2016/12/15.
//  Copyright © 2016年 moxtra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCHomeAccountCell : UITableViewCell

@property(nonatomic, readwrite, strong)UIImageView *indicatorView;
@property(nonatomic, readwrite, strong)UILabel *cardTypeLabel;
@property(nonatomic, readwrite, strong)UILabel *cardAccountLabel;
@property(nonatomic, readwrite, strong)UILabel *cardAmountLabel;

@end
