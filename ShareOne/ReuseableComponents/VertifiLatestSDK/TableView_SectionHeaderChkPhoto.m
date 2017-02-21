//
//  TableView_SectionHeaderChkPhoto.m
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

#import "TableView_SectionHeaderChkPhoto.h"

@implementation TableView_SectionHeaderChkPhoto

@synthesize labelGroup;
@synthesize labelValue;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
    }
    return self;
}

- (instancetype)initWithTableView:(UITableView *)tableView section:(NSUInteger)section
{
    self = [super initWithFrame:CGRectZero];
    if (self)
    {
        // Initialization code
        schema = [UISchema sharedInstance];

        NSString *strTitle = [tableView.dataSource tableView:tableView titleForHeaderInSection:section];
        if ([strTitle isEqualToString:@""])
            return (nil);
        
        //self.backgroundColor = depositModel.colorLightGray;
        
        // Group/Type
        self.labelGroup = [[UILabel alloc] initWithFrame:CGRectZero];
        
        [labelGroup setTranslatesAutoresizingMaskIntoConstraints:NO];
        labelGroup.numberOfLines = 1;
        labelGroup.font = schema.fontHeadline;
        labelGroup.textAlignment = NSTextAlignmentLeft;
        [labelGroup setContentHuggingPriority:UILayoutPriorityFittingSizeLevel forAxis:UILayoutConstraintAxisHorizontal];               // fit to available space
        [labelGroup setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];        // allow to compress
        
        [labelGroup setBackgroundColor:schema.colorClear];
        [labelGroup setTextColor:schema.colorDarkText];
        labelGroup.text = strTitle;
        [self addSubview:labelGroup];
        
        // Value
        self.labelValue = [[UILabel alloc] initWithFrame:CGRectZero];
        [labelValue setTranslatesAutoresizingMaskIntoConstraints:NO];
        labelValue.numberOfLines = 1;
        labelValue.font = schema.fontCaption1;
        labelValue.textAlignment = NSTextAlignmentRight;
        [labelValue setContentHuggingPriority:UILayoutPriorityFittingSizeLevel forAxis:UILayoutConstraintAxisHorizontal];           // fit to available space
        [labelValue setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];    // resist compression
        
        [labelValue setBackgroundColor:schema.colorClear];
        [labelValue setTextColor:schema.colorDarkText];
        [self addSubview:labelValue];
        
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
                                           [NSLayoutConstraint constraintWithItem:labelValue attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:labelGroup attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:15],
                                           ]];
        
        NSLayoutConstraint *ct = [NSLayoutConstraint constraintWithItem:labelValue attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:-15];
        [ct setPriority:UILayoutPriorityDefaultHigh];
        [constraints addObject:ct];
        
        // baselines
        [constraints addObject:[NSLayoutConstraint constraintWithItem:labelValue attribute:NSLayoutAttributeBaseline relatedBy:NSLayoutRelationEqual toItem:labelGroup attribute:NSLayoutAttributeBaseline multiplier:1.0f constant:0]];
        
        [self addConstraints:constraints];
        
        
    }
    return self;
}

- (void) setDefaults
{
    return;
}

@end
