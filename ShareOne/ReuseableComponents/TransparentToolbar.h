//
//  TransparentToolbar.h
//  VMBPad
//
//  Created by Vertifi Software on 12/15/10.
//  Copyright 2010 Vertifi Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TransparentToolbar : UIToolbar 
{
}

- (void)drawRect:(CGRect)rect;
- (UIBarButtonItem *)buttonWithTag:(int)tag;
- (void)enableButtonWithTag:(int)tag enable:(BOOL)enabled;

@end
