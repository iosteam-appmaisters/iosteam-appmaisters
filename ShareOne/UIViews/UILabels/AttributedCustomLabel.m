//
//  AttributedCustomLabel.m
//  ShareOne
//
//  Created by Qazi Naveed on 2/23/17.
//  Copyright © 2017 Ali Akbar. All rights reserved.
//

#import "AttributedCustomLabel.h"
#import "Configuration.h"
#import "UIColor+HexColor.h"
#import "ShareOneUtility.h"


@implementation AttributedCustomLabel

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
    
    NSString *string = self.text ;
    
    NSDictionary *attr = self.attributedText;
    
     NSDictionary *attrs = @{ NSForegroundColorAttributeName : [UIColor greenColor] };
     NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:string attributes:attrs];
    
//    [attrStr attributedSubstringFromRange:<#(NSRange)#>]
     self.attributedText = attrStr;
    
}

@end
