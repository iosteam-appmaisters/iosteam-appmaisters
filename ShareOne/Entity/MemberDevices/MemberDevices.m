//
//  MemberDevices.m
//  ShareOne
//
//  Created by Qazi Naveed on 14/10/2016.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "MemberDevices.h"
#import "AppServiceModel.h"
#import "Services.h"
#import "ShareOneUtility.h"
#import "SharedUser.h"
#import "DeviceAuth.h"


@implementation MemberDevices

+(void)postMemberDevices:(NSDictionary*)param message:(NSString*)progressMessage delegate:(id)delegate completionBlock:(void(^)(NSObject *user))block failureBlock:(void(^)(NSError* error))failBlock{
    
    [[AppServiceModel sharedClient] postRequestWithAuthHeader:[ShareOneUtility getAuthHeaderWithRequestType:RequestType_POST] AndParam:param progressMessage:progressMessage  urlString:[NSString stringWithFormat:@"%@/%@",[ShareOneUtility getBaseUrl],KMEMBER_DEVICES] delegate:delegate completionBlock:^(NSObject *response) {
        block(response);
        
    } failureBlock:^(NSError *error) {
        failBlock(error);
    }];
}


+(void)putMemberDevices:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(NSObject *user))block failureBlock:(void(^)(NSError* error))failBlock{
    
    [[AppServiceModel sharedClient] putRequestWithAuthHeader:[ShareOneUtility getAuthHeaderWithRequestType:RequestType_PUT] AndParam:param progressMessage:@"Please wait..." urlString:[NSString stringWithFormat:@"%@/%@",[ShareOneUtility getBaseUrl],KMEMBER_DEVICES] delegate:delegate completionBlock:^(NSObject *response) {
        block(response);
    } failureBlock:^(NSError *error) {
        failBlock(error);
    }];
}

+(void)getMemberDevices:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(NSObject *user))block failureBlock:(void(^)(NSError* error))failBlock{
    
    NSString *signature =[ShareOneUtility getAuthHeaderWithRequestType:RequestType_GET];
    
    [[AppServiceModel sharedClient] getMethod:signature AndParam:param progressMessage:@"Please wait..." urlString:[NSString stringWithFormat:@"%@/%@/%@",[ShareOneUtility getBaseUrl],KMEMBER_DEVICES,[[[SharedUser sharedManager] userObject] Contextid]] delegate:delegate completionBlock:^(NSObject *response) {
        block(response);
    } failureBlock:^(NSError *error) {
        failBlock(error);
    }];

}


+(void)deleteMemberDevice:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(NSObject *user))block failureBlock:(void(^)(NSError* error))failBlock{
    
    NSString *context = [[[SharedUser sharedManager] userObject] Contextid];
    NSString *deviceID = [param valueForKey:@"ID"];

    [[AppServiceModel sharedClient] deleteRequestWithAuthHeader:[ShareOneUtility getAuthHeaderWithRequestType:RequestType_DELETE] AndParam:nil progressMessage:@"Please wait..." urlString:[NSString stringWithFormat:@"%@/%@/%@/%@",[ShareOneUtility getBaseUrl],KMEMBER_DEVICES,context,deviceID] delegate:delegate completionBlock:^(NSObject *response) {
        block(response);
    } failureBlock:^(NSError *error) {
        failBlock(error);
    }];

}

-(id) initWithDictionary:(NSDictionary *)dict{
    MemberDevices *obj = [[MemberDevices alloc] init];
    
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

+(void)getCurrentMemberDeviceObject :(NSDictionary *)dict
                     completionBlock:(void(^)(MemberDevices *memberDevice))successBlock
                        failureBlock:(void(^)(NSError* error))failBlock {
    
    NSArray *contentArr = dict[@"MemberDevices"];
    
    [contentArr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        MemberDevices *objMemberDevices = [[MemberDevices alloc] initWithDictionary:obj];
        
        if ([objMemberDevices.Fingerprint isEqualToString:[ShareOneUtility getUUID]]){
            successBlock(objMemberDevices);
        }
        
    }];
    
}

+(void)iterateMemberDevices :(NSDictionary *)dict
                     completionBlock:(void(^)(BOOL status, MemberDevices *memberDevice))successBlock
                        failureBlock:(void(^)(NSError* error))failBlock {
    
    NSArray *contentArr = dict[@"MemberDevices"];
    
    NSLog(@"%@",contentArr);
    
    BOOL value = NO;
    MemberDevices *objMemberDevices = nil;
    
    for (int i = 0; i < contentArr.count; i++) {
        
        NSDictionary * obj = contentArr[i];
        
        objMemberDevices = [[MemberDevices alloc] initWithDictionary:obj];
        
        if ([objMemberDevices.Fingerprint isEqualToString:[ShareOneUtility getUUID]]){
            value = YES;
            break;
        }
        
    }
    if (value) {
        successBlock(YES, objMemberDevices);
    }
    else {
        successBlock(NO,nil);
    }
  
}



@end
