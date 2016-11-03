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

+(void)getAllBalances:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(NSObject *user))block failureBlock:(void(^)(NSError* error))failBlock{
    
    NSString *signature =[ShareOneUtility getAuthHeaderWithRequestType:RequestType_GET];
    
    [[AppServiceModel sharedClient] getMethod:signature AndParam:nil progressMessage:nil urlString:    [NSString stringWithFormat:@"%@/%@/%@",KWEB_SERVICE_BASE_URL,KQUICK_BALANCES,[ShareOneUtility getUUID]] delegate:delegate completionBlock:^(NSObject *response) {
        
        NSArray *qbObjects = [QuickBalances  getQBObjects:(NSDictionary *)response];
        [ShareOneUtility savedSufficInfoLocally:(NSDictionary *)response];
        [[SharedUser sharedManager] setQBSectionsArr:qbObjects];

        block(response);
        
    } failureBlock:^(NSError *error) {}];

}


+(void)getAllQuickTransaction:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(NSObject *user))block failureBlock:(void(^)(NSError* error))failBlock{
    
    NSString *signature =[ShareOneUtility getAuthHeaderWithRequestType:RequestType_GET];
    
    NSString *url = [NSString stringWithFormat:@"%@/%@/%@/%@/%@",KWEB_SERVICE_BASE_URL,KQUICK_TRANSACTION,[param valueForKey:@"DeviceFingerprint"],[param objectForKey:@"SuffixID"] ,[param valueForKey:@"NumberOfTransactions"]];
    
    [[AppServiceModel sharedClient] getMethod:signature AndParam:nil progressMessage:@"Loading..." urlString:url delegate:delegate completionBlock:^(NSObject *response) {
        
        NSArray *qtObjects = [QuickTransaction  getQTObjects:(NSDictionary *)response];

        block((NSArray *)qtObjects);
        
    } failureBlock:^(NSError *error) {}];
}

-(id) initWithDictionary:(NSDictionary *)dict{
    
    self = [super init];{
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;

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
