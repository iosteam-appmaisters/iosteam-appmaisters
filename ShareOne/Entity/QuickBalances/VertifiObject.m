//
//  VertifiObject.m
//  ShareOne
//
//  Created by Qazi Naveed on 11/9/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "VertifiObject.h"

@implementation VertifiObject

+(NSArray *)parseAllDepositsWithObject:(NSArray *)array{
    NSMutableArray *depositObjectsArr = [[NSMutableArray alloc] init];
    [array enumerateObjectsUsingBlock:^(NSDictionary  *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
       VertifiDepositObject *objVertifiDepositObject = [VertifiDepositObject parseDeposit:obj];
        [depositObjectsArr addObject:objVertifiDepositObject];
    }];
    
    return [NSArray arrayWithArray:depositObjectsArr];
}

@end
