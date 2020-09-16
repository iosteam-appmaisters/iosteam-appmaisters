//
//  OnDotServices.h
//  ShareOne
//
//  Created by Ahmed Baloch on 16/09/2020.
//  Copyright © 2020 Ali Akbar. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AppServiceModel.h"
#import "Services.h"
#import "ShareOneUtility.h"


@interface OnDotServices : NSObject

+(void)getRegisterToOnDot:(NSDictionary*)param delegate:(id)delegate url:(NSString *)BaseUrlOnDot AndLoadingMessage:(NSString *)message completionBlock:(void(^)(NSObject *user,BOOL succes))block failureBlock:(void(^)(NSError* error))failBlock;

@end


