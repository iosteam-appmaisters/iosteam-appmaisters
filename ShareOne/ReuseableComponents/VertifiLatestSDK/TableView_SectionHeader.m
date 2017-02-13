//
//  TableView_SectionHeader.m
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
//

#import "TableView_SectionHeader.h"
#import "UISchema.h"

@implementation TableView_SectionHeader

@synthesize labelGroup;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
    }
    return self;
}

- (instancetype)initWithTableView:(UITableView *)tableView section:(NSUInteger)section canWrap:(BOOL)canWrap
{
    self = [super initWithFrame:CGRectMake(0,0,tableView.frame.size.width,32)];
    if (self)
    {
        // Initialization code
        
        NSString *strTitle = [tableView.dataSource tableView:tableView titleForHeaderInSection:section];
        if ([strTitle isEqualToString:@""])
            return (nil);
        
        UISchema *schema = [UISchema sharedInstance];

        // Group/Type
        self.labelGroup = [[UILabel alloc] initWithFrame:CGRectZero];
        
        [labelGroup setTranslatesAutoresizingMaskIntoConstraints:NO];
        labelGroup.numberOfLines = canWrap ? 0 : 1;
        labelGroup.font = schema.fontHeadline;
        labelGroup.textAlignment = NSTextAlignmentLeft;
        if (!canWrap)
            [labelGroup setAdjustsFontSizeToFitWidth:YES];
        
        [labelGroup setContentHuggingPriority:UILayoutPriorityFittingSizeLevel forAxis:UILayoutConstraintAxisHorizontal];           // fit to available space
        [labelGroup setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];   // allow to compress
        
        [labelGroup setBackgroundColor:schema.colorClear];
        labelGroup.textColor = schema.colorDarkText;
        labelGroup.text = strTitle;
        [self addSubview:labelGroup];
        
        // auto-layout constraints
        NSMutableArray *constraints = [[NSMutableArray alloc] init];
        
        // view
        [constraints addObject:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:0 multiplier:1.0f constant:32.0f]];
        
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-%.0f-[labelGroup]-%.0f-|",schema.fontHeadline.lineHeight/2,schema.fontHeadline.lineHeight/2]
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:NSDictionaryOfVariableBindings(labelGroup)]];
        
        [constraints addObjectsFromArray:@[
                                           [NSLayoutConstraint constraintWithItem:labelGroup attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeading multiplier:1.0f constant:15],
                                           ]];
        
        NSLayoutConstraint *ct = [NSLayoutConstraint constraintWithItem:labelGroup attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:-15];
        [ct setPriority:UILayoutPriorityDefaultHigh];
        [constraints addObject:ct];
        
        [self addConstraints:constraints];
    }
    return self;
}

@end
