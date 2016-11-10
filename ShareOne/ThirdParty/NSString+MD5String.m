//
//  NSString+MD5String.m
//  ShareOne
//
//  Created by Qazi Naveed on 11/9/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "NSString+MD5String.h"

@implementation NSString (MD5String)

-(NSData*) hexToBytes {
    NSMutableData* data = [NSMutableData data];
    int idx;
    for (idx = 0; idx+2 <= self.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [self substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}
@end
