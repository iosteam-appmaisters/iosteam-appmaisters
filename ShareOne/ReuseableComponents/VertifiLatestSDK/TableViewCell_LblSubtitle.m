//
//  TableViewCell_LblSubtitle.m
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


#import "TableViewCell_LblSubtitle.h"

@implementation TableViewCell_LblSubtitle
@synthesize label;
@synthesize labelSubtitle;

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
    {
        schema = [UISchema sharedInstance];
        
        // TableViewCell
        [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [self setEditingAccessoryType:UITableViewCellAccessoryNone];
        [self setSelectionStyle:UITableViewCellSelectionStyleDefault];
        
        // label
        self.label = [[UILabel alloc] init];
        [label setTranslatesAutoresizingMaskIntoConstraints:NO];
        [label setTextColor:schema.colorDarkText];
        [label setHighlightedTextColor:schema.colorBlack];
        [label setFont:schema.fontBody];
        [label setTextAlignment:NSTextAlignmentLeft];
        [label setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];     // resist compression
        [self.contentView addSubview:label];
        
        // labelSubtitle
        self.labelSubtitle = [[UILabel alloc] init];
        [labelSubtitle setTranslatesAutoresizingMaskIntoConstraints:NO];
        [labelSubtitle setTextColor:schema.colorLightGray];
        [labelSubtitle setHighlightedTextColor:schema.colorBlack];
        [labelSubtitle setFont:schema.fontCaption2];
        [labelSubtitle setTextAlignment:NSTextAlignmentLeft];
        [labelSubtitle setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];     // resist compression
        [self.contentView addSubview:labelSubtitle];
        
        // create constraints programmatically
        
        NSMutableArray *constraints = [[NSMutableArray alloc] init];
        UIView *contentView = self.contentView;
        
        // subtitle labels horizontal alignment
        [constraints addObject:[NSLayoutConstraint constraintWithItem:labelSubtitle attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:label attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0]];
        
        // vertical/horizontal
        [constraints addObject:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:0 multiplier:1.0f constant:43.0f]];
        
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-%.0f-[label]-%.0f-[labelSubtitle]-%.0f-|",schema.fontBody.lineHeight/2,schema.fontBody.lineHeight/5,schema.fontBody.lineHeight/2]
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:NSDictionaryOfVariableBindings(label,labelSubtitle)]];
        
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-15-[label]-20-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label)]];
        
        [self.contentView addConstraints:constraints];
    }
    
    return (self);
}

//---------------------------------------------------------------------------------------------------------------
// setDefaults
//
//---------------------------------------------------------------------------------------------------------------

- (void) setDefaults
{
    [label setFont:schema.fontBody];
    [labelSubtitle setFont:schema.fontCaption2];
    return;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (self.selectionStyle == UITableViewCellSelectionStyleNone)
        return;
    
    [super setSelected:selected animated:animated];
}

//---------------------------------------------------------------------------------------------------------------
// updateConstraints
//
//---------------------------------------------------------------------------------------------------------------

- (void) updateConstraints
{
    [super updateConstraints];
}

@end
