//
//  CashDeposit.h
//  ShareOne
//
//  Created by Qazi Naveed on 10/10/2016.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AppServiceModel.h"
#import "Services.h"
#import "ShareOneUtility.h"


@interface CashDeposit : NSObject

+(void)getRegisterToVirtifi:(NSDictionary*)param delegate:(id)delegate url:(NSString *)vertifiUrl AndLoadingMessage:(NSString *)message completionBlock:(void(^)(NSObject *user,BOOL succes))block failureBlock:(void(^)(NSError* error))failBlock;

@end

