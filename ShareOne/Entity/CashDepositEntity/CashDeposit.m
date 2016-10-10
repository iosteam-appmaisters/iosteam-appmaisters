//
//  CashDeposit.m
//  ShareOne
//
//  Created by Qazi Naveed on 10/10/2016.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "CashDeposit.h"

@implementation CashDeposit
+(void)getRegisterToVirtifi:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(NSObject *user))block failureBlock:(void(^)(NSError* error))failBlock{

    [[AppServiceModel sharedClient] postRequestWithParameters:param progressMessage:@"Please Wait" urlString:[NSString stringWithFormat:@""] delegate:delegate completionBlock:^(NSObject *response) {
        block(self);
        
    } failureBlock:^(NSError *error) {
        
    }];
}

@end
