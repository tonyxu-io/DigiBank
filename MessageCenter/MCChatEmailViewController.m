//
//  MCChatEmailViewController.m
//  DigiBank
//
//  Created by Moxtra on 2017/4/18.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import "MCChatEmailViewController.h"

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface MCChatEmailViewController ()<UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong)UITableView *tableView;

@property(nonatomic, strong)MXChat *chat;
@property(nonatomic, strong)NSString *email;

@end

static CGFloat const kFooterViewHeight = 50.f;
static CGFloat const kEmailCellHeight = 60.f;
static CGFloat const kNormalCellHeight = 44.f;

static NSString *const kNormalCellReuseIdentifier = @"kNormalCellReuseIdentifier";

@implementation MCChatEmailViewController

#pragma mark - LifeCycle

- (instancetype)initWithChatItem:(MXChat *)chat emailAdress:(NSString *)email
{
    if (self = [self init])
    {
        _chat = chat;
        _email = email;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.navigationItem.title =  NSLocalizedString(@"Email", @"Email");
    
    [self setupUserInterface];
}

#pragma mark - UserInterface

- (void)setupUserInterface
{
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview: self.tableView];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [UIView new];
}

#pragma mark - UITableViewDataSource/Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kNormalCellReuseIdentifier];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kNormalCellReuseIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.font =  [UIFont systemFontOfSize:15];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    cell.textLabel.numberOfLines = 1;
    if(indexPath.row == 0)
    {
        cell.textLabel.numberOfLines = 3;
        cell.textLabel.text = self.email;
        cell.textLabel.textColor = [UIColor blackColor];
    }
    else if(indexPath.row == 1)
    {
        cell.textLabel.text = NSLocalizedString(@"Add to Contacts", @"Add to Contacts");
        cell.textLabel.textColor = MXBrandingColor;
    }
    else if(indexPath.row == 2)
    {
        cell.textLabel.text = NSLocalizedString(@"Copy to Clipboard", @"Copy to Clipboard");
        cell.textLabel.textColor = MXBrandingColor;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;
{
    return kFooterViewHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    if(indexPath.row == 0)
        return kEmailCellHeight;
    return kNormalCellHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds), 50.0f)];
    footerView.backgroundColor = [UIColor clearColor];
    
    UILabel *footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0.0f, CGRectGetWidth(self.view.bounds) - 20.0f, 50.0f)];
    footerLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    footerLabel.font = [UIFont systemFontOfSize:12];
    footerLabel.textAlignment = NSTextAlignmentCenter;
    footerLabel.textColor = MXGray40Color;
    footerLabel.numberOfLines = 0;
    footerLabel.text = NSLocalizedString(@"You can email notes, photos, and files from your computer or phone right into this chat.", @"You can email notes, photos, and files from your computer or phone right into this chat.");
    [footerView addSubview:footerLabel];
    return footerView;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 1)
    {
        ABRecordRef person = ABPersonCreate();
        ABRecordSetValue(person, kABPersonFirstNameProperty, (__bridge CFStringRef)self.chat.topic, NULL);
        
        ABMutableMultiValueRef emailMultiValue = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        ABMultiValueAddValueAndLabel(emailMultiValue, (__bridge CFStringRef)self.email, kABWorkLabel, NULL);
        ABRecordSetValue(person, kABPersonEmailProperty, emailMultiValue, nil);
        CFRelease(emailMultiValue);
        
        ABUnknownPersonViewController *controller = [[ABUnknownPersonViewController alloc] init];
        controller.displayedPerson = person;
        controller.allowsAddingToAddressBook = YES;
        [self.navigationController pushViewController:controller animated:YES];
        CFRelease(person);
    }
    else if(indexPath.row == 2)
    {
        UIPasteboard *pboard = [UIPasteboard generalPasteboard];
        pboard.string = self.email;
        [self.view.window mc_showMessage:NSLocalizedString(@"Copied Successfully.", @"Copied Successfully.")];
    }
    [tableView selectRowAtIndexPath:nil animated:YES scrollPosition:UITableViewScrollPositionNone];
}

@end
