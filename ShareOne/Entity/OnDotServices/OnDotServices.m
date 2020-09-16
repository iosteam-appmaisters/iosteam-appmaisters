//
//  OnDotServices.m
//  ShareOne
//
//  Created by Ahmed Baloch on 16/09/2020.
//  Copyright © 2020 Ali Akbar. All rights reserved.
//

#import "OnDotServices.h"
#import "XMLDictionary.h"
#import "ShareOneUtility.h"
#import "ConstantsShareOne.h"


@implementation OnDotServices

+(void)getRegisterToOnDot:(NSDictionary*)param delegate:(id)delegate url:(NSString *)BaseUrlOnDot AndLoadingMessage:(NSString *)message completionBlock:(void(^)(NSObject *user,BOOL succes))block failureBlock:(void(^)(NSError* error))failBlock {
    
    [[AppServiceModel sharedClient] putRequestWithAuthHeaderOnDot:nil AndParam:param progressMessage:nil urlString:[NSString stringWithFormat:@"%@apiVersion=v2.0&opId=REGISTER_VALID_USER",BaseUrlOnDot] delegate:delegate completionBlock:^(NSObject *response) {
        
    } failureBlock:^(NSError *error) {
        
    }];
}
@end
