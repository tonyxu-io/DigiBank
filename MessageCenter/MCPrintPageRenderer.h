//
//  MCPrintPageRenderer.h
//  ChatSDK
//
//  Created by jacob on 12/5/16.
//  Copyright © 2016 moxtra. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 A render use to covert a view to PDF
 */
@interface MCPrintPageRenderer : UIPrintPageRenderer

/**
 Covert a view to PDF

 @param pdfWidth The PDF's width
 @param pdfHeight The PDF's height
 @return PDF data
 */
- (NSData *)convertViewToPDFWithWidth:(float)pdfWidth saveHeight:(float)pdfHeight;
@end
