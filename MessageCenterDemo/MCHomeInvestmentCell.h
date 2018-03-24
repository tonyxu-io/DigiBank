//
//  MCHomeInvestmentCell.h
//  MessageCenter
//
//  Created by wubright on 2016/12/15.
//  Copyright © 2016年 moxtra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCHomeInvestmentCell : UITableViewCell

@property(nonatomic, readwrite, strong)UILabel *nameLabel;
@property(nonatomic, readwrite, strong)UILabel *accountLabel;
@property(nonatomic, readwrite, strong)UILabel *priceLabel;
@property(nonatomic, readwrite, strong)UILabel *rateLabel;

@end
