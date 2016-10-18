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



@implementation MemberDevices

+(void)postMemberDevices:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(NSObject *user))block failureBlock:(void(^)(NSError* error))failBlock{
    
    
    
    [[AppServiceModel sharedClient] postRequestWithAuthHeader:[ShareOneUtility getAuthHeaderWithRequestType:RequestType_POST] AndParam:param progressMessage:@"Please wait..." urlString:[NSString stringWithFormat:@"%@/%@",KWEB_SERVICE_BASE_URL,KMEMBER_DEVICES] delegate:delegate completionBlock:^(NSObject *response) {
        
    } failureBlock:^(NSError *error) {
        
    }];
}


+(void)putMemberDevices:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(NSObject *user))block failureBlock:(void(^)(NSError* error))failBlock{
    
    [[AppServiceModel sharedClient] putRequestWithAuthHeader:[ShareOneUtility getAuthHeaderWithRequestType:RequestType_PUT] AndParam:param progressMessage:@"Please wait..." urlString:[NSString stringWithFormat:@"%@/%@",KWEB_SERVICE_BASE_URL,KMEMBER_DEVICES] delegate:delegate completionBlock:^(NSObject *response) {
        
    } failureBlock:^(NSError *error) {
        
    }];
}

+(void)getMemberDevices:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(NSObject *user))block failureBlock:(void(^)(NSError* error))failBlock{
    
    NSString *signature =[ShareOneUtility getAuthHeaderWithRequestType:RequestType_GET];
    
    [[AppServiceModel sharedClient] getMethod:signature AndParam:param progressMessage:@"Pleas Wait..." urlString:[NSString stringWithFormat:@"%@/%@/%@",KWEB_SERVICE_BASE_URL,KMEMBER_DEVICES,[[[SharedUser sharedManager] userObject] ContextID]] delegate:delegate completionBlock:^(NSObject *response) {
        
        
    } failureBlock:^(NSError *error) {}];

}


+(void)deleteMemberDevice:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(NSObject *user))block failureBlock:(void(^)(NSError* error))failBlock{
    
    NSString *context = [[[SharedUser sharedManager] userObject] ContextID];
    [[AppServiceModel sharedClient] deleteRequestWithAuthHeader:[ShareOneUtility getAuthHeaderWithRequestType:RequestType_DELETE] AndParam:param progressMessage:@"Please wait..." urlString:[NSString stringWithFormat:@"%@/%@/%@/1",KWEB_SERVICE_BASE_URL,KMEMBER_DEVICES,context] delegate:delegate completionBlock:^(NSObject *response) {
        
    } failureBlock:^(NSError *error) {
        
    }];

}


@end
