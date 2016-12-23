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
    
    QuickTransaction *obj = [[QuickTransaction alloc] init];
    self = [super init];{
        
        for (NSString* key in dict) {
            id value = [dict objectForKey:key];
            
            SEL selector = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", [[key substringToIndex:1] uppercaseString], [[key substringFromIndex:1] lowercaseString]]);
            //            NSLog(@"Selector Name: %@ Value :%@",NSStringFromSelector(selector),value);
            if (value != [NSNull null]) {
                if ([obj respondsToSelector:selector]) {
                    
#       pragma clang diagnostic push
#       pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [obj performSelector:selector withObject:value];
#       pragma clang diagnostic pop
                }
            }
        }
    }
    
    //        [self setValuesForKeysWithDictionary:locationDict];
    
    return obj;

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
