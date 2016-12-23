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

+(void)postMemberDevices:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(NSObject *user))block failureBlock:(void(^)(NSError* error))failBlock;

+(void)putMemberDevices:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(NSObject *user))block failureBlock:(void(^)(NSError* error))failBlock;

+(void)getMemberDevices:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(NSObject *user))block failureBlock:(void(^)(NSError* error))failBlock;

+(void)deleteMemberDevice:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(NSObject *user))block failureBlock:(void(^)(NSError* error))failBlock;

+(NSMutableArray *)getMemberDevices :(NSDictionary *)dict;



@end
