//
//  MCExpandTableView.m
//  MCExpandTableView
//
//  Created by Moxtra on 2017/3/23.
//  Copyright © 2017年 Moxtra. All rights reserved.
//

#import "MCExpandTableView.h"

@interface MCExpandModel()
{
    NSUInteger _totalCounts;
}

@property (nonatomic, strong) NSMutableArray <MCExpandModel *> *subModelInternal;

@end

@implementation MCExpandModel

- (instancetype)init
{
    if (self = [super init])
    {
        _totalCounts = 1;
        _interactionEnabled = YES;
    }
    return self;
}

- (NSUInteger)subDataCount
{
    return [self getSubModelCountWithModel:self];
}

- (NSMutableArray<MCExpandModel *> *)subModelInternal
{
    if (_subModelInternal == nil)
    {
        _subModelInternal = [[NSMutableArray alloc] init];
    }
    return _subModelInternal;
}

- (NSArray<MCExpandModel *> *)subModel
{
    return [self.subModelInternal copy];
}

- (void)setSubModel:(NSArray<MCExpandModel *> *)subModel
{
    self.subModelInternal = [[NSMutableArray alloc] initWithArray:subModel];
}

- (NSUInteger)getSubModelCountWithModel:(MCExpandModel *)model
{
    // Traverse all child nodes
    if (model.subModel.count) {
        [model.subModel enumerateObjectsUsingBlock:^(MCExpandModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (model.expand)
            {
                [self getSubModelCountWithModel:obj];
            }
        }];
        if (model.expand)
        {
            _totalCounts += model.subModel.count;
        }
        return _totalCounts;
    } else {
        return 0;
    }
}

+ (instancetype)expandModelWithObject:(id)object identifier:(NSString *)identifier
{
    MCExpandModel *model = [[MCExpandModel alloc] init];
    model.object = object;
    model.identifier = identifier;
    return model;
}

- (void)addSubModel:(MCExpandModel *)model
{
    [self.subModelInternal addObject:model];
    model.fatherModel = self;
}

- (void)deleteSubModel:(MCExpandModel *)model
{
    model.fatherModel = nil;
    [self.subModelInternal removeObject:model];
}

@end

@interface MCExpandTableView() <UITableViewDataSource, UITableViewDelegate>
{
    struct {
        unsigned int cellForModel : 1;
        unsigned int selectedForModel : 1;
        unsigned int heightForModel: 1;
        unsigned int viewForHead:1;
        unsigned int titleForHead:1;
    }_delegateFlag;
}

@property (nonatomic, strong) NSMutableArray *pureData;

@property (nonatomic, strong) MCExpandModel *totalExpandModel;

@property (nonatomic, strong) NSMutableArray <NSIndexPath *> *willFoldPaths;

@property (nonatomic, strong) NSMutableArray <NSIndexPath *> *willExpandPaths;

@end

static CGFloat const kDefaultCellHeight = 44.f;
static NSString *const kMCExpandTableViewDefaultReuseIdentifier = @"kMCExpandTableViewDefaultReuseIdentifier";

@implementation MCExpandTableView

#pragma mark - LifeCycle
- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    if (self = [super initWithFrame:frame style:style])
    {
        // Implement UITableViewDataSource & UITableViewDelegate by self
        self.dataSource = self;
        self.delegate = self;
    }
    return self;
}

#pragma mark - Lazt Init

- (NSMutableArray *)pureData
{
    if (_pureData == nil)
    {
        _pureData = [[NSMutableArray alloc] init];
        [_pureData addObjectsFromArray:self.expandModels];
    }
    return _pureData;
}

-(NSMutableArray<NSIndexPath *> *)willFoldPaths
{
    if (_willFoldPaths == nil)
    {
        _willFoldPaths = [[NSMutableArray alloc] init];
    }
    return _willFoldPaths;
}

- (NSMutableArray<NSIndexPath *> *)willExpandPaths
{
    if (_willExpandPaths == nil)
    {
        _willExpandPaths = [[NSMutableArray alloc] init];
    }
    return _willExpandPaths;
}

#pragma mark - Setter

- (void)setExpandModels:(NSArray<MCExpandModel *> *)expandModels
{
    _expandModels = expandModels;
    [self.pureData removeAllObjects];
    [self.pureData addObjectsFromArray:self.expandModels];
}

- (void)setExpandDelegate:(id<MCExpandTableViewDelegate>)expandDelegate
{
    _expandDelegate = expandDelegate;
    if ([_expandDelegate respondsToSelector:@selector(mcExpandTableView:cellForModel:)])
    {
        _delegateFlag.cellForModel = YES;
    }
    if ([_expandDelegate respondsToSelector:@selector(mcExpandTableView:didSelectedIndexPath:expandModel:)])
    {
        _delegateFlag.selectedForModel = YES;
    }
    if ([_expandDelegate respondsToSelector:@selector(mcExpandTableView:heightForRowAtIndexPath:expandModel:)])
    {
        _delegateFlag.heightForModel = YES;
    }
    if ([_expandDelegate respondsToSelector:@selector(mcExpandTableView:viewForHeaderInSection:)])
    {
        _delegateFlag.viewForHead = YES;
    }
    if ([_expandDelegate respondsToSelector:@selector(mcExpandTableView:titleForHeaderInSection:)])
    {
        _delegateFlag.titleForHead = YES;
    }
}

#pragma mark - UITableViewDataSource & Deleagte

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.pureData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegateFlag.cellForModel)
    {
        return [_expandDelegate mcExpandTableView:self cellForModel:self.pureData[indexPath.row]];
    }
    else
    {
        UITableViewCell *cell = [self dequeueReusableCellWithIdentifier:kMCExpandTableViewDefaultReuseIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                          reuseIdentifier:kMCExpandTableViewDefaultReuseIdentifier];
        }
        cell.textLabel.text = [self.pureData[indexPath.row] identifier];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegateFlag.selectedForModel)
    {
        [_expandDelegate mcExpandTableView:self didSelectedIndexPath:indexPath expandModel:self.pureData[indexPath.row]];
    }
    if (!self.manualHandleUpdate)
    {
        [self updateTableViewWithTargetIndex:indexPath];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_delegateFlag.heightForModel)
    {
        return [_expandDelegate mcExpandTableView:self heightForRowAtIndexPath:indexPath expandModel:self.pureData[indexPath.row]];
    }
    else
    {
        return kDefaultCellHeight;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (_delegateFlag.viewForHead)
    {
        return [_expandDelegate mcExpandTableView:self viewForHeaderInSection:section];
    }
    else
    {
        return nil;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (_delegateFlag.titleForHead)
    {
        return [_expandDelegate mcExpandTableView:self titleForHeaderInSection:section];
    }
    else
    {
        return nil;
    }
}

#pragma mark - Private Method

- (void)getWillFoldIndexPathsWithPreviousData:(NSArray <MCExpandModel *>*)data
{
    NSMutableSet *previousSet = [NSMutableSet setWithArray:data];
    NSMutableSet *currentSet = [NSMutableSet setWithArray:self.pureData];
    [previousSet minusSet:currentSet];
    for (MCExpandModel *obj in previousSet)
    {
        NSUInteger index = [data indexOfObject:obj];
        [self.willFoldPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
    }
}

- (void)getWillExpandIndexPathsWithPreviousData:(NSArray <MCExpandModel *>*)data
{
    NSMutableSet *previousSet = [NSMutableSet setWithArray:data];
    NSMutableSet *currentSet = [NSMutableSet setWithArray:self.pureData];
    [currentSet minusSet:previousSet];
    for (MCExpandModel *obj in currentSet)
    {
        NSUInteger index = [self.pureData indexOfObject:obj];
        [self.willExpandPaths addObject:[NSIndexPath indexPathForRow:index inSection:0]];
    }
}

- (NSArray <MCExpandModel *> *)getPureDataWithMetaData:(MCExpandModel *)data {
    if (data.subModel.count) {
        [data.subModel enumerateObjectsUsingBlock:^(MCExpandModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (data.expand)
            {
                [self.pureData addObject:obj];
                [self getPureDataWithMetaData:obj];
            }
        }];
        return self.pureData;
    } else {
        return nil;
    }
}

#pragma mark - Public Method

- (void)updateData
{
    [self.pureData removeAllObjects];
    [self getPureDataWithMetaData:self.totalExpandModel];
    [self reloadData];
}

- (void)clearData
{
    if (self.expandModels)
    {
        self.expandModels = nil;
        self.pureData = nil;
        [self reloadData];
    }
}

- (void)updateTableViewWithTargetIndex:(NSIndexPath *)indexPath
{
    self.totalExpandModel = [[MCExpandModel alloc] init];
    self.totalExpandModel.expand = YES;
    for (MCExpandModel *expandModel in self.expandModels)
    {
        [self.totalExpandModel addSubModel:expandModel];
    }
    
    MCExpandModel *data = self.pureData[indexPath.row];
    if (data.interactionEnabled)
    {
        data.expand = !data.expand;
    }
    if (data.sameLevelExclusion)
    {
        for (MCExpandModel *model in data.fatherModel.subModel)
        {
            if (model != data)
            {
                model.expand = NO;
                model.subModel = nil;
            }
        }
    }
    NSArray *tempPureDataArray = [NSArray arrayWithArray:self.pureData];
    [self.pureData removeAllObjects];
    [self getPureDataWithMetaData:self.totalExpandModel];
    
    
    [self beginUpdates];
    [self getWillExpandIndexPathsWithPreviousData:tempPureDataArray];
    [self insertRowsAtIndexPaths:self.willExpandPaths withRowAnimation:UITableViewRowAnimationTop];
    [self getWillFoldIndexPathsWithPreviousData:tempPureDataArray];
    [self deleteRowsAtIndexPaths:self.willFoldPaths withRowAnimation:UITableViewRowAnimationTop];
    [self endUpdates];
    [self.willExpandPaths removeAllObjects];
    [self.willFoldPaths removeAllObjects];
    [self deselectRowAtIndexPath:indexPath animated:YES];
}

@end
