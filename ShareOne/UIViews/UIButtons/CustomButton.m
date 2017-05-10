//
//  CustomButton.m
//  ShareOne
//
//  Created by Qazi Naveed on 2/22/17.
//  Copyright © 2017 Ali Akbar. All rights reserved.
//

#import "CustomButton.h"
#import "Configuration.h"
#import "UIColor+HexColor.h"
#import "ShareOneUtility.h"
#import "StyleValuesObject.h"

@implementation CustomButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}


-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if(self){
        [self initialize];
    }
    return self;
}

- (void)initialize{
//    Configuration *config = [ShareOneUtility getConfigurationFile];
    
    StyleValuesObject *objStyleValuesObject= [Configuration getStyleValueContent];
    UIImage * image = [self backgroundImageForState:UIControlStateNormal];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self setBackgroundImage:image forState:UIControlStateNormal];
    [self setTintColor:[UIColor colorWithHexString:objStyleValuesObject.buttoncolortop]];
    [self setTitleColor:[UIColor colorWithHexString:objStyleValuesObject.buttontextcolor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor colorWithHexString:objStyleValuesObject.buttontextcolor] forState:UIControlStateHighlighted];
    
//    [[self layer] setBorderWidth:1.0];
//    [[self layer] setBorderColor:[UIColor colorWithHexString:objStyleValuesObject.buttoncolorborder].CGColor];

}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    
    StyleValuesObject *objStyleValuesObject= [Configuration getStyleValueContent];

    if (highlighted) {
        [self setTintColor:[UIColor colorWithHexString:objStyleValuesObject.buttoncolorhover]];
    }
    else{
        [self setTintColor:[UIColor colorWithHexString:objStyleValuesObject.buttoncolortop]];
    }
    
}


@end
