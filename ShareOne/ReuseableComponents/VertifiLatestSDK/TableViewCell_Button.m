//
//  TableViewCell_Button.m
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

#import "TableViewCell_Button.h"
#import "DepositModel.h"

@implementation TableViewCell_Button

@synthesize button;
@synthesize didPress;

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]))
    {
        schema = [UISchema sharedInstance];
        
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        // TableViewCell
        self.accessoryType = UITableViewCellAccessoryNone;
        self.editingAccessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self setBackgroundColor:schema.colorWhite];
        
        // button field
        self.button = [[UIButton alloc] init];
        [button setTranslatesAutoresizingMaskIntoConstraints:NO];
        [button setShowsTouchWhenHighlighted:YES];
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [button.titleLabel setFont:schema.fontBody];
        [self.contentView addSubview:button];
        
        // create constraints programmatically
        NSMutableArray *constraints = [[NSMutableArray alloc] init];
        UIView *contentView = self.contentView;
        
        [constraints addObject:[NSLayoutConstraint constraintWithItem:self.button attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:self.button attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0]];
        
        [constraints addObject:[NSLayoutConstraint constraintWithItem:self.button attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeLeading multiplier:1.0f constant:20]];
        [constraints addObject:[NSLayoutConstraint constraintWithItem:self.button attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeTrailing multiplier:1.0f constant:-20]];
        
        // vertical/horizontal
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-4-[button]-4-|"
                                                                                 options:0
                                                                                 metrics:nil
                                                                                   views:NSDictionaryOfVariableBindings(button)]];
        
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:0 multiplier:1.0f constant:52.0f];
        heightConstraint.priority = 900;
        [constraints addObject:heightConstraint];
        
        [self.contentView addConstraints:constraints];
    }
    
    [self setDefaults];
    
    return (self);
}

- (void) setDefaults
{
    [button.titleLabel setFont:schema.fontBody];

    [button setTitleColor:schema.colorWhite forState:UIControlStateNormal];
    //[button setTitleColor:[schema.colorDarkText colorWithAlphaComponent:0.5f] forState:UIControlStateDisabled];
    [button setTitleColor:schema.colorLightGray forState:UIControlStateDisabled];
    
    [button setBackgroundImage:[TableViewCell_Button imageWithColor:schema.colorTint] forState:UIControlStateNormal];
    [button setBackgroundImage:[TableViewCell_Button imageWithColor:[schema.colorTint colorWithAlphaComponent:0.5f]] forState:UIControlStateDisabled];
    
    return;
}

- (void) buttonPressed:(id)sender
{
    if (didPress)
        didPress(sender);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (self.selectionStyle == UITableViewCellSelectionStyleNone)
        return;
    
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
