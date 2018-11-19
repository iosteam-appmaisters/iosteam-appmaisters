//
//  MemberDevices.h
//  ShareOne
//
//  Created by Qazi Naveed on 14/10/2016.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppServiceModel.h"
#import "Services.h"
#import "ShareOneUtility.h"


@interface MemberDevices : NSObject

@property (nonatomic,strong) NSString *Fingerprint;
@property (nonatomic,strong) NSNumber *Id;
@property (nonatomic,strong) NSNumber *Providertype;

@property (nonatomic,strong) NSMutableArray *Authorizations;



-(id) initWithDictionary:(NSDictionary *)dict;

+(void)postMemberDevices:(NSDictionary*)param message:(NSString*)progressMessage delegate:(id)delegate completionBlock:(void(^)(NSObject *user))block failureBlock:(void(^)(NSError* error))failBlock;

+(void)putMemberDevices:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(NSObject *user))block failureBlock:(void(^)(NSError* error))failBlock;

+(void)getMemberDevices:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(NSObject *user))block failureBlock:(void(^)(NSError* error))failBlock;

+(void)deleteMemberDevice:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(NSObject *user))block failureBlock:(void(^)(NSError* error))failBlock;

+(void)getCurrentMemberDeviceObject :(NSDictionary *)dict
                     completionBlock:(void(^)(MemberDevices *memberDevice))successBlock
                        failureBlock:(void(^)(NSError* error))failBlock;

+(void)iterateMemberDevices :(NSDictionary *)dict
             completionBlock:(void(^)(BOOL status, MemberDevices *memberDevice))successBlock
                failureBlock:(void(^)(NSError* error))failBlock;

@end
