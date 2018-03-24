//
//  UIScrollView+TYSnapshot.h
//  UITableViewSnapshotTest
//
//  Created by Tony on 2016/7/11.
//  Copyright © 2016年 com.9188. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TYSnapshotMainScreenBounds [UIScreen mainScreen].bounds

@interface UIScrollView (TYSnapshot)

/**
 *  获取最终拼接完成的图片
 *
 *  @param scrollView 需要滑动的scrollView
 *
 *  @return 最终获取的图片
 *  
    保存截取图片的方法，再viewController里面调用如下代码
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
 *
 */
+(UIImage *)getSnapshotImage:(UIScrollView *)scrollView;

@end
