//
//  PlainCustomLabel.m
//  ShareOne
//
//  Created by Qazi Naveed on 2/23/17.
//  Copyright © 2017 Ali Akbar. All rights reserved.
//

#import "PlainCustomLabel.h"
#import "Configuration.h"
#import "UIColor+HexColor.h"
#import "ShareOneUtility.h"


@implementation PlainCustomLabel

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
    [self setTextColor:[UIColor colorWithHexString:config.staticTextColor]];
}


@end
