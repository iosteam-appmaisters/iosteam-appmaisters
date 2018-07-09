//
//  ToastMessage.m
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

#import "ToastMessage.h"
#import "VIPSampleAppDelegate.h"
#import "UISchema.h"

@implementation ToastMessage

+ (void)toastWithViewController:(UIViewController *)viewController message:(NSString *)message duration:(CGFloat)duration
{
    UIView *viewToast = [[UIView alloc] init];
    
    UISchema *schema = [UISchema sharedInstance];
    viewToast.backgroundColor = schema.colorToastBackground;
    viewToast.alpha = 0.0f;
    [viewToast setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    // label
    UILabel *label = [[UILabel alloc] init];
    [label setTranslatesAutoresizingMaskIntoConstraints:NO];
    [label setFont:schema.fontFootnote];
    [label setTextColor:schema.colorToastText];
    [label setBackgroundColor:schema.colorClear];
    label.textAlignment = NSTextAlignmentCenter;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    [label setText:message];
    [label addConstraints:@[
                            [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:0 multiplier:1.0f constant:20]
                            ]];
    [viewToast addSubview:label];
    
    // calculate size of rendered text to determine height of view
    CGSize szMaxLabel = CGSizeMake (viewController.view.frame.size.width - 16,999);
    CGRect rectLabelSize = [message boundingRectWithSize:szMaxLabel options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: label.font} context:nil];
    CGFloat h = rectLabelSize.size.height + 16;
    
    // array for constraints
    NSMutableArray *constraints = [[NSMutableArray alloc] init];
    
    // constraints on viewToast
    [constraints addObject:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:viewToast attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:viewToast attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0f constant:h]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[label]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label)]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:viewToast attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:0 multiplier:1.0f constant:MAX(viewController.view.frame.size.width,viewController.view.frame.size.height)]];
    [viewToast addConstraints:constraints];
    
    [viewController.view addSubview:viewToast];                     // viewController.view <-- viewToast

    
    CGFloat topOffset = 0;
    if ([viewController.view isKindOfClass:[UITableView class]])    // UITableView?
        topOffset = ((UITableView *)viewController.view).contentOffset.y;
    else if ([viewController.view isKindOfClass:[UIScrollView class]])
        topOffset = ((UIScrollView *)viewController.view).contentOffset.y;

    NSLog(@"Toast %@ parent %@ view %@ topOffset %f",viewController, viewController.parentViewController, viewController.view, topOffset);

    if ([[viewController parentViewController] isKindOfClass:[VIPNavigationController class]])
    {

        UINavigationController *navController = (UINavigationController *)[viewController parentViewController];
        //if (navController.navigationBar.translucent)                // translucent navbar?
        {
            topOffset += navController.navigationBar.frame.size.height;
            
            // add status bar height if in full-screen presentation
            if ((navController.modalPresentationStyle == UIModalPresentationFullScreen) && (navController.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassRegular))
                topOffset += [UIApplication sharedApplication].statusBarFrame.size.height;
        }
    }


    NSLog(@"Toast %@ topOffset %f",viewController, topOffset);

    // constraints on viewController.view
    NSLayoutConstraint *constraintTop = [NSLayoutConstraint constraintWithItem:viewToast attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:viewController.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:-h + topOffset];
    NSLayoutConstraint *constraintLeading = [NSLayoutConstraint constraintWithItem:viewToast attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:viewController.view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0];
    constraintLeading.priority = UILayoutPriorityDefaultLow;
    NSLayoutConstraint *constraintTrailing = [NSLayoutConstraint constraintWithItem:viewToast attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:viewController.view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:0];
    constraintTrailing.priority = UILayoutPriorityDefaultLow;
    
    [viewController.view addConstraints:@[
                                          constraintTop,
                                          constraintLeading,
                                          constraintTrailing,
                                          [NSLayoutConstraint constraintWithItem:viewToast attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:viewController.view attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0]
                                          ]];
    
    [viewController.view layoutIfNeeded];
    
    [UIView animateWithDuration:0.4f delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        viewToast.alpha = 1.0f;
        constraintTop.constant += h;
        [viewController.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.4f delay:duration options:UIViewAnimationOptionCurveEaseOut animations:^{
            
            viewToast.alpha = 0.0f;
            constraintTop.constant -= viewToast.frame.size.height;
            
            [viewToast.superview layoutIfNeeded];
            
        } completion:^(BOOL finished) {
            
            [viewToast removeFromSuperview];
            
        }];
        
    }];
}

@end
