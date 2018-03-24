//
//  MCAccountController.m
//  MessageCenter
//
//  Created by wubright on 2016/12/15.
//  Copyright © 2016年 moxtra. All rights reserved.
//

#import "MCStatementController.h"
#import "MCSaveToChatController.h"
#import "UIView+MCPdfConvert.h"

#import <Masonry.h>

@interface MCStatementController ()

@property(nonatomic, readwrite, strong)UIWebView *previewView;

@end

@implementation MCStatementController

- (id)init
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = MCColorBackground;
    self.navigationItem.title = @"Statement";

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"import_button"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] style:UIBarButtonItemStylePlain
                                                                             target:self action:@selector(importAction:)];
    
    self.previewView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.previewView];
    [self.previewView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.previewView setScalesPageToFit:YES];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"portfolio-statement" ofType:@"pdf"];
    NSURL *targetURL = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:targetURL];
    [self.previewView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)importAction:(id)sender
{
    MCSaveToChatController *saveToChatController = [[MCSaveToChatController alloc] initWithPDFFile:[self.previewView MCPdfContentOfView] snapShot:[self.previewView MCImageContentOfView]];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:saveToChatController];
    navigationController.navigationBar.barStyle = UIBarStyleBlack;
    navigationController.navigationBar.barTintColor = MCColorMain;
    navigationController.navigationBar.tintColor = [UIColor whiteColor];
    navigationController.navigationBar.translucent = NO;
    navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    [navigationController.navigationBar setBackgroundImage:[UIImage new] forBarPosition:UIBarPositionTop barMetrics:UIBarMetricsDefault];
    [navigationController.navigationBar setShadowImage:[UIImage new]];
    
    [self presentViewController:navigationController animated:YES completion:nil];
}

@end
