//
//  MCContactSearchViewController.m
//  DigiBank
//
//  Created by Moxtra on 2017/3/13.
//  Copyright © 2017年 moxtra. All rights reserved.
//

#import "MCContactSearchViewController.h"
#import <Masonry.h>
#import "MCContactCell.h"

@interface MCContactSearchViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@end

static CGFloat const kRowHeight = 54.f;

@implementation MCContactSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self setupTableView];
    // Do any additional setup after loading the view.
}

- (void)setupTableView {
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.estimatedRowHeight = kRowHeight;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)reloadResults {
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource/Delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.contacts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MCContactCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contact"];
    if (cell == nil) {
        cell = [[MCContactCell alloc] initWithReuseIdentifier:@"contact" cellType:MCContactCellTypeCall widgetAction:^(id sender) {
                        NSLog(@"call");
        }];
    }
    MXUserItem *item = self.contacts[indexPath.row];
    cell.contact = item;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    MXContactItem *item = self.contacts[indexPath.row];
//    UIViewController *profileController = [self.contactItems contactProfileControllerWithContact:item];
//    self.listController.navigationController.navigationBarHidden = NO;
//    [self.listController.navigationController pushViewController:profileController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kRowHeight;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
