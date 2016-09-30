//
//  TransparentToolbar.m
//  VMBPad
//
//  Created by Vertifi Software on 12/15/10.
//  Copyright 2010 Vertifi Software, LLC. All rights reserved.
//

#import "TransparentToolbar.h"


@implementation TransparentToolbar

// drawRect stub, toolbar items will still draw themselves
- (void)drawRect:(CGRect)rect
{
	return;
}

- (UIBarButtonItem *)buttonWithTag:(int)tag
{
    for (id obj in [self items])
    {
        if ([obj isKindOfClass:[UIBarButtonItem class]])
        {
            if ([(UIBarButtonItem *)obj tag] == tag)
                return ((UIBarButtonItem *)obj);
        }
    }
    return (nil);
}

- (void)enableButtonWithTag:(int)tag enable:(BOOL)enabled
{
    for (id obj in [self items])
    {
        if ([obj isKindOfClass:[UIBarButtonItem class]])
        {
            if ([(UIBarButtonItem *)obj tag] == tag)
            {
                ((UIBarButtonItem *)obj).enabled = enabled;
                return;
            }
        }
    }
    return;
}

@end