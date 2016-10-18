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

@implementation QuickBalances

+(void)getAllBalances:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(NSObject *user))block failureBlock:(void(^)(NSError* error))failBlock{
    
    NSString *signature =[ShareOneUtility getAuthHeaderWithRequestType:RequestType_GET];
//    [NSString stringWithFormat:@"%@/%@/Fingerprint/DB26CFD6-141D-4BAE-A34D-495C94763FD6/ServiceType/eft",KWEB_SERVICE_BASE_URL,KQUICK_BALANCES]
    
//    [[[SharedUser sharedManager] userObject]ContextID],@"ContextID"
    
    [[AppServiceModel sharedClient] getMethod:signature AndParam:nil progressMessage:nil urlString:    [NSString stringWithFormat:@"%@/%@/ContextID/%@/DeviceFingerprint/%@/ServiceType/eft",KWEB_SERVICE_BASE_URL,KQUICK_BALANCES,[[[SharedUser sharedManager] userObject]ContextID],[ShareOneUtility getUUID]] delegate:delegate completionBlock:^(NSObject *response) {
        
        
    } failureBlock:^(NSError *error) {}];

}

@end
