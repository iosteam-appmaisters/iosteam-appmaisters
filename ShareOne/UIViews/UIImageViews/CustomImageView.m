//
//  CustomImageView.m
//  ShareOne
//
//  Created by Qazi Naveed on 2/22/17.
//  Copyright © 2017 Ali Akbar. All rights reserved.
//

#import "CustomImageView.h"
#import "Configuration.h"
#import "UIColor+HexColor.h"
#import "ShareOneUtility.h"


@implementation CustomImageView

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
    Configuration *config = [ShareOneUtility getConfigurationFile];
    UIImage * image = [self image];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self setImage:image];
    [self setTintColor:[UIColor colorWithHexString:config.buttonColor]];
    
}


@end
