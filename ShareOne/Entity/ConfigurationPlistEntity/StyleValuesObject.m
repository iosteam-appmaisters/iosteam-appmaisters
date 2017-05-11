//
//  StyleValuesObject.m
//  ShareOne
//
//  Created by Qazi Naveed on 5/9/17.
//  Copyright © 2017 Ali Akbar. All rights reserved.
//

#import "StyleValuesObject.h"

@implementation StyleValuesObject

+(StyleValuesObject *)parseStyleValues:(NSArray *)array{
    
    StyleValuesObject *obj = [[StyleValuesObject alloc] init];
    
    
    [array enumerateObjectsUsingBlock:^(NSDictionary *stylesDict, NSUInteger idx, BOOL * _Nonnull stop) {
       
        for (NSString* key in stylesDict) {
            id value_key = [stylesDict objectForKey:key];
            NSString *value = [stylesDict objectForKey:@"Value"];
            
            if([value_key isKindOfClass:[NSString class]] && [value length]>0){
                
                SEL selector = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", [[value_key substringToIndex:1] uppercaseString], [[value_key substringFromIndex:1] lowercaseString]]);
//                NSLog(@"Selector Name: %@ Value :%@",NSStringFromSelector(selector),value);
                if (value_key != [NSNull null]) {
                    if ([obj respondsToSelector:selector]) {
                        
#       pragma clang diagnostic push
#       pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                        [obj performSelector:selector withObject:value];
#       pragma clang diagnostic pop
                        
                    }
                }
            }
            
        }
        
    }];
    return obj;
}

@end
