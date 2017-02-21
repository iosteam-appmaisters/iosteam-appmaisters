//
//  ActivityLabelView.m
//  VIPSample
//
//  Created by Vertifi Software, LLC
//
//-------------------------------------------------------------------------------------------------------------------------------------------------
// License:
//
// Copyright (c) 2016 Vertifi Software, LLC
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


#import "ActivityLabelView.h"
#import	"UISchema.h"

@implementation ActivityLabelView

@synthesize activityIndicator;
@synthesize label;

//---------------------------------------------------------------------
// designated initializer
//---------------------------------------------------------------------

- (instancetype) initWithViewController:(UIViewController *)viewController message:(NSString *)message
{
    if ((self = [super init]) != nil)
    {
        UISchema *schema = [UISchema sharedInstance];
        
        self.backgroundColor = schema.colorToastBackground;
        self.alpha = 0.0f;
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        // container for spinner and label, used as centering view within ActivityLabelView
        UIView *containerView = [[UIView alloc] init];
        [containerView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [containerView setBackgroundColor:schema.colorClear];

        CGFloat labelHeight = ceil(schema.fontFootnote.lineHeight * 1.0f);
        
        // spinner
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [activityIndicator setTranslatesAutoresizingMaskIntoConstraints:NO];
        [activityIndicator setColor:schema.colorToastText];
        activityIndicator.hidesWhenStopped = YES;
        [activityIndicator startAnimating];
        [activityIndicator addConstraints:@[
                                            [NSLayoutConstraint constraintWithItem:activityIndicator attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0f constant:labelHeight],
                                            [NSLayoutConstraint constraintWithItem:activityIndicator attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0f constant:labelHeight]
                                            ]];
        [containerView addSubview:activityIndicator];

        // label
        self.label = [[UILabel alloc] init];
        [label setTranslatesAutoresizingMaskIntoConstraints:NO];
        [label setFont:schema.fontFootnote];
        [label setTextColor:schema.colorToastText];
        [label setBackgroundColor:schema.colorClear];
        label.textAlignment = NSTextAlignmentLeft;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.numberOfLines = 0;
        [label setText:message];
        [label addConstraints:@[
                                [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:0 multiplier:1.0f constant:20]
                                ]];
        [containerView addSubview:label];

        // calculate size of rendered text to determine height of view
        CGSize szMaxLabel = CGSizeMake (viewController.view.frame.size.width - 8 - activityIndicator.frame.size.width,999);
        CGRect rectLabelSize = [message boundingRectWithSize:szMaxLabel options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: label.font} context:nil];
        CGFloat h = MAX(activityIndicator.frame.size.height + 16, rectLabelSize.size.height + 16);

        // array for constraints
        NSMutableArray *constraints = [[NSMutableArray alloc] init];
        
        // constraints on containerView
        [constraints addObject:[NSLayoutConstraint constraintWithItem:activityIndicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:containerView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0f constant:h]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[activityIndicator]-15-[label]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(activityIndicator,label)]];
        [containerView addConstraints:constraints];
        [self addSubview:containerView];                            // self <-- containerView
        
        // constraints on self
        [constraints removeAllObjects];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[containerView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(containerView)]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:containerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:0 multiplier:1.0f constant:MAX(viewController.view.frame.size.width,viewController.view.frame.size.height)]];
        [self addConstraints:constraints];
        
        [viewController.view addSubview:self];                      // viewController.view <-- self

        CGFloat offsetY = 0;
        if ([viewController.view isKindOfClass:[UITableView class]])    // UITableView?
            offsetY = ((UITableView *)viewController.view).contentOffset.y;
        else if ([viewController.view isKindOfClass:[UIScrollView class]])
            offsetY = ((UIScrollView *)viewController.view).contentOffset.y;

        if ([[viewController parentViewController] isKindOfClass:[UINavigationController class]])
        {
            UINavigationController *navController = (UINavigationController *)[viewController parentViewController];
            if (navController.navigationBar.translucent)            // translucent navbar?
            {
                offsetY += navController.navigationBar.frame.size.height;
                
                // add status bar height if in full-screen presentation
                if ((navController.modalPresentationStyle == UIModalPresentationFullScreen) && (navController.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular))
                    offsetY += [UIApplication sharedApplication].statusBarFrame.size.height;
            }
        }
        
        // constraints on viewController.view
        constraintTop = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:viewController.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:-h + offsetY];
        NSLayoutConstraint *constraintLeading = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:viewController.view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0];
        constraintLeading.priority = UILayoutPriorityDefaultLow;
        NSLayoutConstraint *constraintTrailing = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:viewController.view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0];
        constraintTrailing.priority = UILayoutPriorityDefaultLow;
        
        [viewController.view addConstraints:@[
                                              constraintTop,
                                              constraintLeading,
                                              constraintTrailing,
                                              [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:viewController.view attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0]
                                              ]];
        
        [viewController.view layoutIfNeeded];
        
        [UIView animateWithDuration:0.4f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.alpha = 1.0f;
            constraintTop.constant += h;
            [viewController.view layoutIfNeeded];
        } completion:^(BOOL finished) {
        }];
        
    }
    
    return (self);
}

- (void) remove
{
    [UIView animateWithDuration:0.4f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{

        self.alpha = 0.0f;
        constraintTop.constant -= self.frame.size.height;

        [self.superview layoutIfNeeded];

    } completion:^(BOOL finished) {

        [self removeFromSuperview];

    }];
}

@end
