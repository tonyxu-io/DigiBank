//
//  MCPrintPageRenderer.m
//  ChatSDK
//
//  Created by jacob on 12/5/16.
//  Copyright © 2016 moxtra. All rights reserved.
//

#import "MCPrintPageRenderer.h"

@implementation MCPrintPageRenderer
{
    BOOL _generatingPdf;
}

- (CGRect) paperRect
{
    if (!_generatingPdf)
        return [super paperRect];
    
    return UIGraphicsGetPDFContextBounds();
}

- (CGRect) printableRect
{
    if (!_generatingPdf)
        return [super printableRect];
    
    return CGRectInset( self.paperRect, 0, 0 );
}

- (NSData*)convertViewToPDFWithWidth: (float)pdfWidth saveHeight:(float) pdfHeight
{
    _generatingPdf = YES;
    
    NSMutableData *pdfData = [NSMutableData data];
    
    UIGraphicsBeginPDFContextToData( pdfData, CGRectMake(0, 0, pdfWidth, pdfHeight), nil );
    
    [self prepareForDrawingPages: NSMakeRange(0, 1)];
    
    CGRect bounds = UIGraphicsGetPDFContextBounds();
    
    for ( int i = 0 ; i < self.numberOfPages ; i++ )
    {
        UIGraphicsBeginPDFPage();
        
        [self drawPageAtIndex: i inRect: bounds];
    }
    
    UIGraphicsEndPDFContext();
    
    _generatingPdf = NO;
    
    return pdfData;
}

@end
