//
//  ApiSettingsObject.m
//  ShareOne
//
//  Created by Qazi Naveed on 6/8/17.
//  Copyright © 2017 Ali Akbar. All rights reserved.
//

#import "ApiSettingsObject.h"

@implementation ApiSettingsObject


-(id) initWithDictionary:(NSDictionary *)dict{
    
    self = [super init];{
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

+(ApiSettingsObject *)parseClientSettings:(NSDictionary *)dict{
    
    
    [self setValuesForKeysWithDictionary:dict];

    ApiSettingsObject *obj = [[ApiSettingsObject alloc] init];
    
    for (NSString* key in dict) {
        id value_key = [dict objectForKey:key];
//        NSString *value = [dict objectForKey:@"Data"];
        
        //NSLog(@"%@",stylesDict );
        if([value_key isKindOfClass:[NSString class]] && [value_key length]>0){
            
            SEL selector = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", [[key substringToIndex:1] uppercaseString], [[key substringFromIndex:1] lowercaseString]]);
            NSLog(@"Selector Name: %@ Value :%@",NSStringFromSelector(selector),value_key);
            if (value_key != [NSNull null]) {
                if ([obj respondsToSelector:selector]) {
                    
#       pragma clang diagnostic push
#       pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [obj performSelector:selector withObject:value_key];
#       pragma clang diagnostic pop
                    
                }
            }
        }
        
    }
    
    return obj;
}

@end
