//
//  UIColor+HexColor.h
//  ShareOne
//
//  Created by Qazi Naveed on 2/22/17.
//  Copyright © 2017 Ali Akbar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HexColor)

+ (UIColor *)colorWithHexString:(NSString *)hexString;
+ (UIColor *)colorWithHex:(UInt32)col;


@end
