//
//  CustomLabel.m
//  ShareOne
//
//  Created by Qazi Naveed on 2/23/17.
//  Copyright © 2017 Ali Akbar. All rights reserved.
//

#import "CustomLabel.h"
#import "Configuration.h"
#import "UIColor+HexColor.h"
#import "ShareOneUtility.h"


@implementation CustomLabel

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
    UIColor *textColor = [UIColor colorWithHexString:config.variableTextColor];
    if(self.attributedText){
     
        NSAttributedString *string = self.attributedText;
        NSDictionary *attrs = @{ NSForegroundColorAttributeName : textColor };
        NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:(NSString *)string attributes:attrs];
        self.attributedText = attrStr;

    }
    else{
     
        [self setTextColor:textColor];

    }
}

@end
