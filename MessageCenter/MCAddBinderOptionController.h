//
//  MXAddBinderOptionController.h
//  MoxtraBinder
//
//  Created by bright wu on 14-12-5.
//
//

#import <UIKit/UIKit.h>

@interface MCAddBinderOptionController : UIViewController

@property(nonatomic, readwrite, strong)UITextField *topicTextField;
@property(nonatomic, readwrite, strong)UIView *splitLineView;
@property(nonatomic, readwrite, strong)UILabel *topicTitleLabel;

@property(nonatomic, readwrite, strong)NSArray *invitedItemsArray;

@end
