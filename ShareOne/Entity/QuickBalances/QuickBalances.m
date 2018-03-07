//
//  QuickBalances.m
//  ShareOne
//
//  Created by Qazi Naveed on 17/10/2016.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "QuickBalances.h"
#import "AppServiceModel.h"
#import "Services.h"
#import "ShareOneUtility.h"
#import "SharedUser.h"
#import "QuickTransaction.h"


@implementation QuickBalances

+(void)getAllBalances:(NSDictionary*)param
             delegate:(id)delegate
      completionBlock:(void(^)(NSArray* qbObjects))block
         failureBlock:(void(^)(NSError* error))failBlock{
    
    NSString *signature =[ShareOneUtility getAuthHeaderWithRequestType:RequestType_GET];
    
    [[AppServiceModel sharedClient] getMethod:signature
                                     AndParam:nil
                              progressMessage:nil
                                    urlString:[NSString stringWithFormat:@"%@/%@/%@",[ShareOneUtility getBaseUrl],KQUICK_BALANCES,[ShareOneUtility getUUID]]
                                     delegate:delegate completionBlock:^(NSObject *response) {

        NSArray *qbObjects = [QuickBalances  getQBObjects:(NSDictionary *)response];
        block(qbObjects);
        
    } failureBlock:^(NSError *error) {
        failBlock(error);
    }];

}


+(void)getAllQuickTransaction:(NSDictionary*)param
                     delegate:(id)delegate
              completionBlock:(void(^)(NSObject *user))block
                 failureBlock:(void(^)(NSError* error))failBlock{
    
    NSString *signature = [ShareOneUtility getAuthHeaderWithRequestType:RequestType_GET];
    
    NSString *url = [NSString stringWithFormat:@"%@/%@/%@/%@/%@",[ShareOneUtility getBaseUrl],KQUICK_TRANSACTION,[ShareOneUtility getUUID],[param objectForKey:@"SuffixID"] ,[ShareOneUtility getNumberOfQuickViewTransactions]];
    
    [[AppServiceModel sharedClient] getMethod:signature AndParam:nil progressMessage:@"Loading..." urlString:url delegate:delegate completionBlock:^(NSObject *response) {
        
        NSArray *qtObjects = [QuickTransaction  getQTObjects:(NSDictionary *)response];
        block((NSArray *)qtObjects);
        
    } failureBlock:^(NSError *error) {
        failBlock(error);
    }];
}

-(id) initWithDictionary:(NSDictionary *)dict{
    
    QuickBalances *obj = [[QuickBalances alloc] init];
    
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

+(NSMutableArray *)getQBObjects:(NSDictionary *)dict{
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    NSArray *contentArr = dict[@"Suffixes"];
    
    [contentArr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        QuickBalances *objSuffixInfo = [[QuickBalances alloc] initWithDictionary:obj];
        [arr addObject:objSuffixInfo];
        
    }];
    return arr;
}



@end
