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

+(void)postMemberDevices:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(NSObject *user))block failureBlock:(void(^)(NSError* error))failBlock{
    
    [[AppServiceModel sharedClient] postRequestWithAuthHeader:[ShareOneUtility getAuthHeaderWithRequestType:RequestType_POST] AndParam:param progressMessage:nil  urlString:[NSString stringWithFormat:@"%@/%@",KWEB_SERVICE_BASE_URL,KMEMBER_DEVICES] delegate:delegate completionBlock:^(NSObject *response) {
        block(response);
        
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
    
    [[AppServiceModel sharedClient] getMethod:signature AndParam:param progressMessage:@"Please Wait..." urlString:[NSString stringWithFormat:@"%@/%@/%@",KWEB_SERVICE_BASE_URL,KMEMBER_DEVICES,[[[SharedUser sharedManager] userObject] ContextID]] delegate:delegate completionBlock:^(NSObject *response) {
        
        
    } failureBlock:^(NSError *error) {}];

}


+(void)deleteMemberDevice:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(NSObject *user))block failureBlock:(void(^)(NSError* error))failBlock{
    
    NSString *context = [[[SharedUser sharedManager] userObject] ContextID];
    NSString *deviceID = [param valueForKey:@"ID"];
    NSString *deviceFingerPrint = [param valueForKey:@"Fingerprint"];

    [[AppServiceModel sharedClient] deleteRequestWithAuthHeader:[ShareOneUtility getAuthHeaderWithRequestType:RequestType_DELETE] AndParam:nil progressMessage:@"Please wait..." urlString:[NSString stringWithFormat:@"%@/%@/%@/%@",KWEB_SERVICE_BASE_URL,KMEMBER_DEVICES,context,deviceFingerPrint] delegate:delegate completionBlock:^(NSObject *response) {
        
    } failureBlock:^(NSError *error) {
        
    }];

}

-(id) initWithDictionary:(NSDictionary *)dict{
    self = [super init];{
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

+(NSMutableArray *)getMemberDevices :(NSDictionary *)dict{
    
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    NSArray *contentArr = dict[@"MemberDevices"];
    
    [contentArr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        MemberDevices *objMemberDevices = [[MemberDevices alloc] initWithDictionary:obj];
        
        objMemberDevices.Authorizations= [DeviceAuth getDeviceAuthArrWithObject:obj];
        
        [arr addObject:objMemberDevices];
        
        
    }];
    return arr;

}



@end
