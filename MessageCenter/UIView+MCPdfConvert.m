//
//  UIView_PdfConvert.h
//  MessageCenter
//
//  Created by jacob on 12/9/16.
//  Copyright © 2016 moxtra. All rights reserved.
//

#import "MCPrintPageRenderer.h"
#import "UIView+MCPdfConvert.h"
#import "UIScrollView+TYSnapshot.h"

@implementation UIView (MCPdfConvert)

+ (NSString *)MCCreateGUID
{
    CFUUIDRef theUUID;
    CFStringRef theString;
    
    theUUID = CFUUIDCreate(NULL);
    
    theString = CFUUIDCreateString(NULL, theUUID);
    
    NSString *unique = [NSString stringWithString:(__bridge id)theString];
    
    CFRelease(theString); CFRelease(theUUID); // Cleanup
    
    return unique;
}

/**
 convert current view's content to pdf

 @return path of pdf
 */
- (NSString * __nullable)MCPdfContentOfView;
{
    UIImage *image = nil;
    if( [self isKindOfClass:[UIWebView class]] )
    {
        UIWebView *webView = (UIWebView *)self;
        float pdfWidth = 0;
        float pdfHeight = 0;
        if( CGRectGetHeight(self.bounds) > webView.scrollView.contentSize.height )
        {
            pdfWidth = webView.scrollView.contentSize.width;
            pdfHeight = webView.scrollView.contentSize.height;
        }
        else
        {
            pdfWidth = CGRectGetWidth(self.bounds);
            pdfHeight = CGRectGetHeight(self.bounds);
        }
        
        MCPrintPageRenderer *myRenderer = [[MCPrintPageRenderer alloc] init];
        UIViewPrintFormatter *viewFormatter = [self viewPrintFormatter];
        [myRenderer addPrintFormatter:viewFormatter startingAtPageAtIndex:0];
        
        NSData *pdfData = [myRenderer convertViewToPDFWithWidth: pdfWidth saveHeight:pdfHeight];
        NSString* tempFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[UIView MCCreateGUID] stringByAppendingPathExtension:@"pdf"]];
        [pdfData writeToFile:tempFilePath atomically:YES];
        return tempFilePath;
    }
    else if( [self isKindOfClass:[UIScrollView class]] )
    {
        UIScrollView *scrollView = (UIScrollView *)self;
        image = [UIScrollView getSnapshotImage:scrollView];
    }
    else
    {
        CGRect rect = [self bounds];
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [self.layer renderInContext:context];
        image  = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
    }
    
    if( image )
    {
        NSString* tempFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[UIView MCCreateGUID] stringByAppendingPathExtension:@"pdf"]];
        UIGraphicsBeginPDFContextToFile(tempFilePath, CGRectMake(0, 0, image.size.width, image.size.height), nil);
        UIGraphicsBeginPDFPage();
        [image drawAtPoint:CGPointZero];
        UIGraphicsEndPDFContext();
        return tempFilePath;
    }
    
    return nil;
}

- (UIImage * __nullable)MCImageContentOfView
{
    UIImage *image = nil;
    if( [self isKindOfClass:[UIScrollView class]] )
    {
        UIScrollView *scrollView = (UIScrollView *)self;
        [scrollView setZoomScale:scrollView.minimumZoomScale animated:NO];
        image = [UIScrollView getSnapshotImage:scrollView];
    }
    else
    {
        if( [self isKindOfClass:[UIWebView class]] )
        {
            [[(UIWebView *)self scrollView] setZoomScale:[(UIWebView *)self scrollView].minimumZoomScale];
        }
        CGRect rect = [self bounds];
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [self.layer renderInContext:context];
        image  = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return image;

}

@end
