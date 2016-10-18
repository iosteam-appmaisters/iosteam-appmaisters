//
//  CashDeposit.m
//  ShareOne
//
//  Created by Qazi Naveed on 10/10/2016.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//
#import "SharedUser.h"
#import "CashDeposit.h"

@implementation CashDeposit
+(void)getRegisterToVirtifi:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(NSObject *user))block failureBlock:(void(^)(NSError* error))failBlock{

    [[AppServiceModel sharedClient] postRequestWithAuthHeader:nil AndParam:param progressMessage:nil urlString:kDEPOSIT_MONEY_REGISTER delegate:delegate completionBlock:^(NSObject *response) {
        
    } failureBlock:^(NSError *error) {
        
    }];
}

@end
