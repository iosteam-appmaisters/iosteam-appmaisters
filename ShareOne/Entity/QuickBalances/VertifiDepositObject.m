//
//  VertifiDepositObject.m
//  ShareOne
//
//  Created by Qazi Naveed on 11/25/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "VertifiDepositObject.h"

@implementation VertifiDepositObject


-(id) initWithDictionary:(NSDictionary *)dict{
    
    
    VertifiDepositObject *obj = [[VertifiDepositObject alloc] init];
    self = [super init];{
        
        for (NSString* key in dict) {
            id value = [dict objectForKey:key];
            
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
    
    //        [self setValuesForKeysWithDictionary:locationDict];
    
    return obj;

}
+(VertifiDepositObject *)parseDeposit:(NSDictionary *)dict{
 
    VertifiDepositObject *obj = [[VertifiDepositObject alloc] initWithDictionary:dict];
    return obj;
}

@end
