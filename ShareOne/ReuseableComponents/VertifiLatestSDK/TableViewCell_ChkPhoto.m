//
//  TableViewCell_ChkPhoto.m
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


#import "TableViewCell_ChkPhoto.h"

@implementation TableViewCell_ChkPhoto

@synthesize label;
@synthesize thumb;
@synthesize spinner;

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
    {
        schema = [UISchema sharedInstance];

        // TableViewCell
        [self setAccessoryType:UITableViewCellAccessoryNone];
        [self setEditingAccessoryType:UITableViewCellAccessoryNone];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        [self setBackgroundColor:schema.colorWhite];
        
        //[self.contentView setBackgroundColor:schema.colorLightGray];
        
        // label
        self.label = [[UILabel alloc] init];
        [label setTranslatesAutoresizingMaskIntoConstraints:NO];
        [label setFont:schema.fontBody];
        [label setTextColor:schema.colorLightGray];
        [self.contentView addSubview:label];
  
        // imageView (thumb)
        self.thumb = [[UIImageView alloc] init];
        [thumb setTranslatesAutoresizingMaskIntoConstraints:NO];
        thumb.contentMode = UIViewContentModeScaleAspectFit;
        thumb.userInteractionEnabled = YES;
        [thumb setBackgroundColor:schema.colorClear];
        thumb.layer.borderWidth = 1.0f;
        thumb.layer.borderColor = schema.colorLightGray.CGColor;
        [self.contentView addSubview:thumb];
        
        // Activity indicator
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner setTranslatesAutoresizingMaskIntoConstraints:NO];
        spinner.hidesWhenStopped = YES;
        [self.contentView addSubview:spinner];
        
        // aspect ratio constraint on thumb
        NSLayoutConstraint *aspectRatioConstraint = [NSLayoutConstraint constraintWithItem:thumb attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:thumb attribute:NSLayoutAttributeHeight multiplier:2.2f constant:0];
        aspectRatioConstraint.priority = UILayoutPriorityDefaultHigh;
        [thumb addConstraint:aspectRatioConstraint];

        // create constraints programmatically
        constraints = [[NSMutableArray alloc] init];
        [self updateConstraints];
        
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
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (self.selectionStyle == UITableViewCellSelectionStyleNone)
        return;
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}


//---------------------------------------------------------------------------------------------------------------
// updateConstraints
//
// sets auto-layout constraints
//---------------------------------------------------------------------------------------------------------------

- (void) updateConstraints
{
    [super updateConstraints];
    
    UIView *contentView = self.contentView;
    
    // remove existing constraints
    [contentView removeConstraints:constraints];
    [constraints removeAllObjects];
    
    // spinner
    [constraints addObject:[NSLayoutConstraint constraintWithItem:spinner attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0]];
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[spinner]-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(spinner)]];
    
    // label
    [constraints addObjectsFromArray:@[
                                       [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:thumb attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0],
                                       [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:thumb attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0],
                                       [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:40],
                                       ]];
    
    // thumb
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[thumb]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(thumb)]];

    // thumb margins set based on size class
    int nMargin = [UIApplication sharedApplication].keyWindow.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact ? 15 : [UIScreen mainScreen].bounds.size.width * 0.1;
    [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-%d-[thumb]-%d-|", nMargin, nMargin] options:0 metrics:nil views:NSDictionaryOfVariableBindings(thumb)]];
    
    [self.contentView addConstraints:constraints];
}

@end
