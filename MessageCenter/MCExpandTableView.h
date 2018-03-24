//
//  MCExpandTableView.h
//  MCExpandTableView
//
//  Created by Moxtra on 2017/3/23.
//  Copyright © 2017年 Moxtra. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MCExpandTableViewDelegate;

#pragma mark - MCExpandModel

/**
 An object used to cooperate with MCExpandTableView as data
 */
@interface MCExpandModel : NSObject

/**
 Use to identify MCExpandModel
 */
@property (nonatomic, copy) NSString *identifier;

/**
 Child nodes, expanded when father's expand property is YES
 */
@property (nonatomic, strong) NSArray <MCExpandModel *> *subModel;

/**
 Father node
 */
@property (nonatomic, weak) MCExpandModel *fatherModel;

/**
 A boolean value to flag whether the model needs to expand the child nodes
 */
@property (nonatomic, assign) BOOL expand;

/**
 A bool value to decide whether the model can respond to expand or fold, default is YES.
 */
@property (nonatomic, assign) BOOL interactionEnabled;

/**
 Determine whether the models in same level can expand at the same time
 */
@property (nonatomic, assign) BOOL sameLevelExclusion;

/**
 Use to storage your own custom object in MCExpandModel.
 */
@property (nonatomic, strong) id object;

/**
 Create a MCExpandModel binded with your own object.

 @param object Your own object
 @param identifier MCExpandModel's identifier
 @return MCExpandModel
 */
+ (instancetype)expandModelWithObject:(id)object identifier:(NSString *)identifier;

/**
 Add another MCExpandModel to its subModel.

 @param model MCExpandModel you want to add
 */
- (void)addSubModel:(MCExpandModel *)model;

/**
 Delete a subModel.
 
 @param model MCExpandModel you want to delete
 */
- (void)deleteSubModel:(MCExpandModel *)model;

@end

#pragma mark - MCExpandTableView

/**
 A tableView supported expand or fold
 */
@interface MCExpandTableView : UITableView

/**
 MCExpandTableView's data
 */
@property (nonatomic, strong) NSArray<MCExpandModel*> *expandModels;

/**
 The object that acts as delegate of the MCExpandTableView
 */
@property (nonatomic, weak) id<MCExpandTableViewDelegate> expandDelegate;

/**
 The default is NO, indicate that in the implementation of internal tableView method 'didSelectRowAtIndex:' after the expandDelegate method implemented, tableview will automatic update(expand or fold).
 If you set manualHandleUpdate to YES, the time of update tableview is on you call.
 */
@property (nonatomic, assign) BOOL manualHandleUpdate;

/**
 Use this method to clear data
 */
- (void)clearData;

/**
 Use this method to update data
 */
- (void)updateData;

/**
 Update a specifc indexPath

 @param indexPath The indexPath need to update
 */
- (void)updateTableViewWithTargetIndex:(NSIndexPath *)indexPath;

@end

#pragma mark - MCExpandTableViewDelegate

/**
 This represents the display and behaviour of the cells in MCExpandTableView.
 */
@protocol MCExpandTableViewDelegate <NSObject>

@optional

/**
 Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
 
 Highly suggest that you should implement this proxy method,otherwise it will use UITableViewCell to display model's identifier default.
 For further use,see demo please.
 @param tableView MCExpandTableView
 @param model The MCExpandModel you want to display.You should establish an association between your own custom cell and MCExpandModel.
 @return You custom cell.
 */
- (UITableViewCell *)mcExpandTableView:(MCExpandTableView *)tableView
                          cellForModel:(MCExpandModel *)model;

/**
 Called after the user selected the cell.

 In normal case, you don't have to change MCExpandModel's expand property after selected. MCExpandTableView will automatically solve this. But if you have some more complex needs，manager MCExpandModel's expand property by yourself
 
 @param tableView MCExpandTableView
 @param indexPath Selected IndexPath
 @param model Selected MCExpandModel
 */
- (void)mcExpandTableView:(MCExpandTableView *)tableView
     didSelectedIndexPath:(NSIndexPath *)indexPath
              expandModel:(MCExpandModel *)model;

/**
 Row height.Default is 44.

 @param tableView MCExpandTableView
 @param indexPath The indexPath you want to specify a height
 @param model The MCExpandModel you want to specify a height
 @return Height value 
 */
- (CGFloat)mcExpandTableView:(MCExpandTableView *)tableView
     heightForRowAtIndexPath:(NSIndexPath *)indexPath
                 expandModel:(MCExpandModel *)model;

/**
 Head view in section

 @param tableView MCExpandTableView
 @param section The section you want to specify a header
 @return UIView
 */
- (UIView *)mcExpandTableView:(MCExpandTableView *)tableView
       viewForHeaderInSection:(NSInteger)section;

/**
 Title for section
 
 @param tableView MCExpandTableView
 @param section The section you want to specify a title
 @return NSString
 */
- (NSString *)mcExpandTableView:(MCExpandTableView *)tableView
       titleForHeaderInSection:(NSInteger)section;
@end
