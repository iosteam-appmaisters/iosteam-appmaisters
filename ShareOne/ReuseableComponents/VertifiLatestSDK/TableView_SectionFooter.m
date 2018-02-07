//
//  TableSectionFooterView.m
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
//

#import "TableView_SectionFooter.h"
#import "UISchema.h"

@implementation TableView_SectionFooter

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

- (instancetype)initWithTableView:(UITableView *)tableView string:(NSAttributedString *)string
{
    self = [super initWithFrame:CGRectZero];
    if (self)
    {
        // Initialization code
        
        UISchema *schema = [UISchema sharedInstance];
        
        // Group/Type
        self.labelGroup = [[UILabel alloc] initWithFrame:CGRectZero];
        
        [labelGroup setTranslatesAutoresizingMaskIntoConstraints:NO];
        labelGroup.numberOfLines = 0;
        labelGroup.font = schema.fontBody;
        labelGroup.textAlignment = NSTextAlignmentLeft;
        [labelGroup setContentHuggingPriority:UILayoutPriorityFittingSizeLevel forAxis:UILayoutConstraintAxisHorizontal];           // fit to available space
        labelGroup.textColor = schema.colorFootnote;
        [labelGroup setAttributedText:string];
        
        [self addSubview:labelGroup];
        
        // auto-layout constraints
        NSMutableArray *constraints = [[NSMutableArray alloc] init];
        
        // view
        [constraints addObject:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:0 multiplier:1.0f constant:32.0f]];

        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-%.0f-[labelGroup]-%.0f-|",schema.fontBody.lineHeight/2,schema.fontBody.lineHeight/2]
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:NSDictionaryOfVariableBindings(labelGroup)]];

        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[labelGroup]-15-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(labelGroup)]];
        
        [self addConstraints:constraints];
        
        
    }
    return self;
}

@end
