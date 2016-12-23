//
//  SuffixInfo.m
//  ShareOne
//
//  Created by Qazi Naveed on 17/10/2016.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "SuffixInfo.h"
#import "AppServiceModel.h"
#import "Services.h"
#import "ShareOneUtility.h"
#import "SharedUser.h"


@implementation SuffixInfo

+(void)getSuffixInfo:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(NSObject *user))block failureBlock:(void(^)(NSError* error))failBlock{
    
    NSString *signature =[ShareOneUtility getAuthHeaderWithRequestType:RequestType_GET];
    
    [[AppServiceModel sharedClient] getMethod:signature AndParam:param progressMessage:nil urlString:[NSString stringWithFormat:@"%@/%@/%@",KWEB_SERVICE_BASE_URL,KSUFFIX_INFO,[[[SharedUser sharedManager] userObject] Contextid]] delegate:delegate completionBlock:^(NSObject *response) {
        
        
    } failureBlock:^(NSError *error) {}];
}


+(void)postSuffixInfo:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(NSObject *user))block failureBlock:(void(^)(NSError* error))failBlock{
    
    NSString *signature =[ShareOneUtility getAuthHeaderWithRequestType:RequestType_POST];

    [[AppServiceModel sharedClient] postRequestWithAuthHeader:signature AndParam:param progressMessage:nil urlString:[NSString stringWithFormat:@"%@/%@",KWEB_SERVICE_BASE_URL,kSUFFIZ_PREPHERENCES] delegate:delegate completionBlock:^(NSObject *response) {
        
    } failureBlock:^(NSError *error) {
        
    }];
}

-(id) initWithDictionary:(NSDictionary *)dict{
    
    SuffixInfo *obj = [[SuffixInfo alloc] init];

    self = [super init];{
        

        for (NSString* key in dict) {
            id value = [dict objectForKey:key];
            
            SEL selector = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", [[key substringToIndex:1] uppercaseString], [[key substringFromIndex:1] lowercaseString]]);
//                    NSLog(@"Selector Name: %@ Value :%@",NSStringFromSelector(selector),value);
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


+(NSMutableArray *)getSuffixArrayWithObject:(NSDictionary *)dict{
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    NSArray *contentArr = dict[@"Suffixes"];
    
    [contentArr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSMutableDictionary *mutDic = [(NSMutableDictionary *)obj mutableCopy];
//        [mutDic removeObjectForKey:@"TaxInfo"];
        SuffixInfo *objSuffixInfo = [[SuffixInfo alloc] initWithDictionary:mutDic];
        [arr addObject:objSuffixInfo];
        
    }];
    return arr;
}

@end