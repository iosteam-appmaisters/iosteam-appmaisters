//
//  Address.m
//  ShareOne
//
//  Created by Qazi Naveed on 12/19/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "Address.h"

@implementation Address

-(id) initWithDictionary:(NSDictionary *)hoursDict{
    
    Address *obj = [[Address alloc] init];
    self = [super init];{
        //        [self setValuesForKeysWithDictionary:hoursDict];
        
        for (NSString* key in hoursDict) {
            id value = [hoursDict objectForKey:key];
            
            SEL selector = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", [[key substringToIndex:1] uppercaseString], [[key substringFromIndex:1] lowercaseString]]);
            NSLog(@"Selector Name: %@ Value :%@",NSStringFromSelector(selector),value);
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
    
    return obj;
    
}


@end
