//
//  Photo.m
//  ShareOne
//
//  Created by Qazi Naveed on 12/19/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "Photos.h"

@implementation Photos

+(NSMutableArray *) parsePhotos:(NSArray *)photosArr{

    
    NSMutableArray *parsedPhotoArr = [[NSMutableArray alloc] init];
    [photosArr enumerateObjectsUsingBlock:^(NSDictionary *photoDict, NSUInteger idx, BOOL * _Nonnull stop) {
        
        Photos *obj = [[Photos alloc] init];
        
        
        for (NSString* key in photoDict) {
            id value = [photoDict objectForKey:key];
            
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
        [parsedPhotoArr addObject:obj];

    }];
    
    return parsedPhotoArr;
}

@end
