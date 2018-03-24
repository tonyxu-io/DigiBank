//
//  MCSaveToChatController.m
//  MessageCenter
//
//  Created by wubright on 2016/12/15.
//  Copyright © 2016年 moxtra. All rights reserved.
//

#import "MCSaveToChatController.h"
#import "MCMessageCenterViewController.h"
#import "MCSaveToChatCell.h"

#import <Masonry.h>
#import <ChatSDK/MXChatSDK.h>

#import "UIScrollView+TYSnapshot.h"


@interface MCSaveToChatController ()<UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate>

@property (nonatomic, weak) MXChatListModel *chatListModel;

@property(nonatomic, readwrite, strong)NSString  *pdfFile;
@property(nonatomic, readwrite, strong)UIWebView *webView;
@property(nonatomic, readwrite, strong)UIImageView *imageView;
@property(nonatomic, readwrite, strong)UIImage *image;
@property(nonatomic, readwrite, strong)UITableView *tableView;

@property(nonatomic, readwrite, strong)NSMutableArray *chatItemsArray;
@property(nonatomic, readwrite, strong)NSMutableArray *selectedChatItemsArray;

@end

@implementation MCSaveToChatController

- (id)initWithPDFFile:(NSString *)pdfFile snapShot:(UIImage *)image;
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.automaticallyAdjustsScrollViewInsets = NO;
        
        self.pdfFile = pdfFile;
        self.image = image;
    }
    
    return self;
}

- (MXChatListModel *)chatListModel
{
    return [MCMessageCenterInstance sharedInstance].chatListModel;
}

- (void)cleanup
{
    if( self.pdfFile.length )
        [[NSFileManager defaultManager] removeItemAtPath:self.pdfFile error:nil];
    self.pdfFile = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = MCColorBackground;
    self.navigationItem.title = @"Save To";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"")
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self action:@selector(cancelAction:)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Send", @"")
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self action:@selector(sendAction:)];
    
    
    self.webView = [UIWebView new];
    self.webView.backgroundColor = [UIColor whiteColor];
    self.webView.scalesPageToFit = YES;
    self.webView.contentMode = UIViewContentModeScaleAspectFit;
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@250.0);
    }];
    [self.webView setHidden:YES];
    
    UIView *backgroundView = [UIView new];
    backgroundView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:backgroundView];
    [backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.webView);
    }];
    
    self.imageView = [UIImageView new];
    self.imageView.backgroundColor = [UIColor whiteColor];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:self.imageView];
    self.imageView.image = self.image;
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.webView).insets(UIEdgeInsetsMake(8.0f, 0.0f, 8.0f, 0.0f));
    }];
    
    UIView *lineView = [UIView new];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.webView.mas_bottom);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.height.equalTo(@0.5f);
    }];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.tableView.clipsToBounds = NO;
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0, 0, 0);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.rowHeight = 50;
    [self.tableView registerClass:[MCSaveToChatCell class] forCellReuseIdentifier:@"MCSaveToChatCell"];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [UIView new];
    [self.view insertSubview:self.tableView atIndex:0];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.webView.mas_bottom);
        make.bottom.equalTo(self.view);
    }];
    
//    NSURL *targetURL = [NSURL fileURLWithPath:self.pdfFile];
//    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
//    [self.webView loadRequest:request];
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings)
                            {
                                MXChat *chat  = evaluatedObject;
                                return !chat.isIndividualChat;
                            }];
    
    self.chatItemsArray = [NSMutableArray arrayWithArray:[self.chatListModel.chats filteredArrayUsingPredicate: predicate]];
    [self.chatItemsArray  sortedArrayUsingComparator:^NSComparisonResult(MXChat *obj1, MXChat *obj2) {
        return [obj2.lastFeedTime compare:obj1.lastFeedTime];
    }];
    
    self.selectedChatItemsArray = [NSMutableArray array];

}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)cancelAction:(id)sender
{
    [self cleanup];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendAction:(id)sender
{
    NSString *fileName = @"statement";
    
    [self.selectedChatItemsArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        MXChat *chat = obj;
        [[MXToolkit sharedInstance] saveFileToChat:chat filePath:self.pdfFile name:fileName completionHandler:nil];
        
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self cleanup];
}

#pragma mark - UIWebViewDelegate

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
        return self.chatItemsArray.count;
    else if(section == 1)
        return 0;
    
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [UILabel new];
    
    NSString *text;
    if (section == 0) {
        text = @"Conversations";
    } else if(section == 1) {
        text = @"Contacts";
    }
    
    label.text = text;
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = MCColorFontBlack;
    UIView *headerView = [UIView new];
    headerView.backgroundColor = MCColorBackground;
    [headerView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(0);
        make.left.mas_equalTo(15);
    }];
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0)
    {
        MCSaveToChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MCSaveToChatCell" forIndexPath:indexPath];
        MXChat *chat = [self.chatItemsArray objectAtIndex:indexPath.row];
        
        cell.textLabel.text = chat.topic;
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        if([self.selectedChatItemsArray containsObject:chat])
            cell.selectImageView.image = [UIImage imageNamed:@"checked_button"];
        else
            cell.selectImageView.image = [UIImage imageNamed:@"uncheck_button"];
        
        return cell;
    }
    else if(indexPath.section == 1)
    {
        return nil;
    }

    return nil;
}


#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MXChat *chat = [self.chatItemsArray objectAtIndex:indexPath.row];

    if([self.selectedChatItemsArray containsObject:chat])
        [self.selectedChatItemsArray removeObject:chat];
    else
        [self.selectedChatItemsArray addObject:chat];
    
    [tableView selectRowAtIndexPath:nil animated:YES scrollPosition:UITableViewScrollPositionNone];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void){
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    });

}


@end
