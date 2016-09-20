//
//  User.h
//  LivePolling
//
//  Created by Aliakber Hussain on 18/06/2013.
//  Copyright (c) 2013 Aliakber Hussain. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

-(id) initWithDictionary:(NSDictionary *)userProfileDict;

@property (nonatomic,strong) NSString *userAddress;
@property (nonatomic,strong) NSString *userPhoneNo;
@property (nonatomic,strong) NSString *userId;
@property (nonatomic,strong) NSString *userName;
@property (nonatomic,strong) NSString *userEmail;
@property (nonatomic,strong) NSString *userSocialMediaId;

@property (nonatomic,strong) NSURL *userImage;
@property (nonatomic,strong) NSURL *userThumbImage;

@property (nonatomic,strong) NSString *userCountryName;
@property (nonatomic,strong) NSString *userCityName;
@property (nonatomic,strong) NSString *userDisplayLocation;

@property (nonatomic,strong) NSString *loginType;
@property (nonatomic,strong) NSString *skypeID;
@property (nonatomic,strong) NSString *dob;
@property (nonatomic,strong) NSString *isPushOn;
@property (nonatomic,strong) NSNumber *distanceRange;
@property (nonatomic,strong) NSString *userStatus;
@property (nonatomic,strong) NSNumber *latitude;
@property (nonatomic,strong) NSNumber *longitude;
@property (nonatomic,strong) NSString *isOnline;

@property (nonatomic,strong) NSNumber *isPictureSaveOn;
@property (nonatomic,strong) NSNumber *amIFollowing;

@property (nonatomic,strong) NSNumber *followersCount;
@property (nonatomic,strong) NSNumber *followingCount;
@property (nonatomic,strong) NSNumber *isFollower;
@property (nonatomic,strong) NSNumber *isFollowing;
@property (nonatomic,strong) NSNumber *isBlocked;
@property (nonatomic,strong) NSNumber *amIBlocked;

@property (nonatomic,strong) NSString *gender;
@property (nonatomic,strong) NSString *race;


@property (nonatomic,strong) NSString *groupId;

+(void)getUserWithParam:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(User* user))block failureBlock:(void(^)(NSError* error))failBlock;

+(void)createOneToOneChatWithParam:(NSDictionary*)param delegate:(id)delegate urlString:(NSString*)urlString completionBlock:(void(^)(id response))block failureBlock:(void(^)(NSError* error))failBlock;

+(void)blockUnblockUserWithParam:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(id response))block failureBlock:(void(^)(NSError* error))failBlock;

+(void)logoutUserUserWithParam:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(id response))block failureBlock:(void(^)(NSError* error))failBlock;

@end
