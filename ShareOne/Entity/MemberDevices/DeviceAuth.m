//
//  DeviceAuth.m
//  ShareOne
//
//  Created by Qazi Naveed on 25/10/2016.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "DeviceAuth.h"

@implementation DeviceAuth

+(NSMutableArray *)getDeviceAuthArrWithObject :(NSDictionary *)dict{
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    NSArray *contentArr = dict[@"Authorizations"];
    
    [contentArr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        DeviceAuth *objDeviceAuth = [[DeviceAuth alloc] initWithDictionary:obj];
        [arr addObject:objDeviceAuth];
    }];
    return arr;
}


-(id) initWithDictionary:(NSDictionary *)dict{
    
    DeviceAuth *obj = [[DeviceAuth alloc] init];
    
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
    
    return obj;

}
@end
