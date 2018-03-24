//
//  UIImage+TYSnapshot.h.m
//  UITableViewSnapshotTest
//
//  Created by Tony on 2016/7/11.
//  Copyright © 2016年 com.9188. All rights reserved.
//

#import "UIImage+TYSnapshot.h"

@implementation UIImage (ImagesArr)

#pragma mark 拼接快照
+ (UIImage *)getImageFromImagesArray:(NSArray *)imagesArr
{
    UIImage *image;
    CGSize imageTotalSize = [self getImageTotalSizeFromImagesArray:imagesArr];
    UIGraphicsBeginImageContextWithOptions(imageTotalSize, NO, 0.f);
    
    //拼接图片
    int imageOffset = 0;
    for (UIImage *images in imagesArr) {
        [images drawAtPoint:CGPointMake(0, imageOffset)];
        imageOffset += images.size.height;
    }
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark 获取全部图片拼接后size
+ (CGSize)getImageTotalSizeFromImagesArray:(NSArray *)imagesArr
{
    CGSize totalSize = CGSizeZero;
    for (UIImage *image in imagesArr) {
        CGSize imageSize = [image size];
        totalSize.height += imageSize.height;
        totalSize.width = MAX(totalSize.width, imageSize.width);
    }
    return totalSize;
}

@end
