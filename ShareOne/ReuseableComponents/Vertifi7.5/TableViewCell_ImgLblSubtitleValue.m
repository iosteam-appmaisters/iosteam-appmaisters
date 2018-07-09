//
//  TableViewCell_ImgLblSubtitleValue.m
//  VIPSample
//
//  Created by Vertifi Software, LLC
//
//-------------------------------------------------------------------------------------------------------------------------------------------------
// License:
//
// Copyright (c) 2018 Vertifi Software, LLC
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

#import "TableViewCell_ImgLblSubtitleValue.h"

@implementation TableViewCell_ImgLblSubtitleValue

@synthesize imageView;
@synthesize label;
@synthesize labelSubtitle;
@synthesize labelValue;

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
    {
        schema = [UISchema sharedInstance];
        
        // TableViewCell
        [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [self setEditingAccessoryType:UITableViewCellAccessoryNone];
        
        // imageView
        self.imageView = [[UIImageView alloc] init];
        [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.contentView addSubview:imageView];
        
        // label
        self.label = [[UILabel alloc] init];
        [label setTranslatesAutoresizingMaskIntoConstraints:NO];
        [label setTextColor:schema.colorDarkText];
        [label setHighlightedTextColor:schema.colorBlack];
        [label setFont:schema.fontBody];
        [label setTextAlignment:NSTextAlignmentLeft];
        [label setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];     // allow to compress
        [self.contentView addSubview:label];
        
        // labelSubtitle
        self.labelSubtitle = [[UILabel alloc] init];
        [labelSubtitle setTranslatesAutoresizingMaskIntoConstraints:NO];
        [labelSubtitle setTextColor:schema.colorDarkText];
        [labelSubtitle setHighlightedTextColor:schema.colorBlack];
        [labelSubtitle setFont:schema.fontCaption2];
        [labelSubtitle setTextAlignment:NSTextAlignmentLeft];
        [labelSubtitle setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal]; // allow compression
        [self.contentView addSubview:labelSubtitle];
        
        // labelValue
        self.labelValue = [[UILabel alloc] init];
        [labelValue setTranslatesAutoresizingMaskIntoConstraints:NO];
        [labelValue setTextColor:schema.colorDarkText];
        [labelValue setHighlightedTextColor:schema.colorBlack];
        [labelValue setFont:schema.fontBody];
        [labelValue setTextAlignment:NSTextAlignmentRight];
        [labelValue setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];  // resist compression
        [labelValue setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];                // hug the value (added in v7.5)
        [self.contentView addSubview:labelValue];
        
        // create constraints programmatically
        
        [imageView addConstraints:@[
                                    [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0f constant:24],
                                    [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0f constant:24]
                                    ]];
        
        NSMutableArray *constraints = [[NSMutableArray alloc] init];
        UIView *contentView = self.contentView;
        
        // imageView
        [constraints addObject:[NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0]];
        
        // subtitle labels horizontal alignment
        [constraints addObject:[NSLayoutConstraint constraintWithItem:labelSubtitle attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:label attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0]];
        
        // vertical/horizontal
        [constraints addObject:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:0 multiplier:1.0f constant:43.0f]];
        
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-%.0f-[label]-%.0f-[labelSubtitle]-%.0f-|",schema.fontBody.lineHeight/2,schema.fontBody.lineHeight/5,schema.fontBody.lineHeight/2]
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:NSDictionaryOfVariableBindings(label,labelSubtitle)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-%.0f-[labelValue]-%.0f-|",schema.fontBody.lineHeight/2,schema.fontBody.lineHeight/2]
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:NSDictionaryOfVariableBindings(labelValue)]];
        
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-4-[imageView]-4-[label]-20-[labelValue]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(imageView,label,labelValue)]];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[labelSubtitle]-20-[labelValue]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(labelSubtitle,labelValue)]];
        
        
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
    [labelValue setFont:schema.fontBody];

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
    
    // remove existing constraints
    [self.labelSubtitle removeConstraints:self.labelSubtitle.constraints];
    
    // labelSubtitle
    if (labelSubtitle.text.length == 0)
    {
        [labelSubtitle addConstraints:@[
                                              [NSLayoutConstraint constraintWithItem:labelSubtitle attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0f constant:0]
                                              ]];
    }
    else
    {
        [labelSubtitle addConstraints:@[
                                              [NSLayoutConstraint constraintWithItem:labelSubtitle attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:0 multiplier:1.0f constant:labelSubtitle.intrinsicContentSize.height]
                                              ]];
        
    }
}

@end
