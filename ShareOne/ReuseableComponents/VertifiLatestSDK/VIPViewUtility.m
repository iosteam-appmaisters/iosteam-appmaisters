//
//  VMBViewUtility.m
//  VIPSample
//
//  Created by Vertifi Software, LLC
//
//-------------------------------------------------------------------------------------------------------------------------------------------------
// License:
//
// Copyright (c) 2017 Vertifi Software, LLC
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
// USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//--------------------------------------------------------------------------------------------------------------------------------------------------


#import "VIPViewUtility.h"

@implementation VIPViewUtility

+ (UIImage *) imageFooter
{
    if (_imageFooter == nil)
        _imageFooter = [UIImage imageNamed:@"logo"];
    return (_imageFooter);
}

+ (UIView *) getFooterWatermark:(UITableView *)tableView
{
    // set table footer view (watermark)
    UIView *viewFooter = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width,self.imageFooter.size.height)];
    viewFooter.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[self imageFooter]];
    imageView.frame = CGRectMake((int)((tableView.bounds.size.width / 2) - (_imageFooter.size.width / 2)), 0, _imageFooter.size.width, self.imageFooter.size.height);
    imageView.contentMode = UIViewContentModeCenter;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [viewFooter addSubview:imageView];
    
    return (viewFooter);
}

@end
