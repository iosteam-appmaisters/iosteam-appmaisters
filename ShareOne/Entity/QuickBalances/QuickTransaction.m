//
//  QuickTransaction.m
//  ShareOne
//
//  Created by Qazi Naveed on 11/3/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "QuickTransaction.h"

@implementation QuickTransaction

-(id) initWithDictionary:(NSDictionary *)dict{
    
    self = [super init];{
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;

}

+(NSMutableArray *)getQTObjects:(NSDictionary *)dict{
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    NSArray *contentArr = dict[@"Transactions"];
    
    [contentArr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        QuickTransaction *objQuickTransaction = [[QuickTransaction alloc] initWithDictionary:obj];
        [arr addObject:objQuickTransaction];
        
    }];
    return arr;

}

@end
