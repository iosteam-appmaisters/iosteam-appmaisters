//
//  UIPrintPageRenderer+PrintToPDF.m
//  ShareOne
//
//  Created by Malik Wahaj Ahmed on 20/06/2018.
//  Copyright © 2018 Ali Akbar. All rights reserved.
//

#import "UIPrintPageRenderer+PrintToPDF.h"

@implementation UIPrintPageRenderer (PrintToPDF)
- (NSData*) printToPDF
{
    NSMutableData *pdfData = [NSMutableData data];
    UIGraphicsBeginPDFContextToData( pdfData, self.paperRect, nil );
    [self prepareForDrawingPages: NSMakeRange(0, self.numberOfPages)];
    CGRect bounds = UIGraphicsGetPDFContextBounds();
    for ( int i = 0 ; i < self.numberOfPages ; i++ )
    {
        UIGraphicsBeginPDFPage();
        [self drawPageAtIndex: i inRect: bounds];
    }
    UIGraphicsEndPDFContext();
    return pdfData;
}@end
