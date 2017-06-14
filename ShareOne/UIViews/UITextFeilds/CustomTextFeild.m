//
//  CustomTextFeild.m
//  ShareOne
//
//  Created by Qazi Naveed on 2/24/17.
//  Copyright © 2017 Ali Akbar. All rights reserved.
//

#import "CustomTextFeild.h"
#import "Configuration.h"
#import "UIColor+HexColor.h"
#import "ShareOneUtility.h"


@implementation CustomTextFeild

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
    
    StyleValuesObject *obj = [Configuration getStyleValueContent];
    UIColor *color = [UIColor colorWithHexString:obj.buttoncolortop];
    [self setTextColor:color];
    [self setTintColor:color];
    
}

@end
