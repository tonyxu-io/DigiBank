//
//  UIView_PdfConvert.h
//  MessageCenter
//
//  Created by jacob on 12/9/16.
//  Copyright © 2016 moxtra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (MCPdfConvert)

/**
 Convert current view's content to pdf

 @return path of the pdf
 */
- (NSString * __nullable)MCPdfContentOfView;
- (UIImage * __nullable)MCImageContentOfView;

@end
