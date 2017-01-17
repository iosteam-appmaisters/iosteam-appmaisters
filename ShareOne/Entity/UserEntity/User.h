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

@property (nonatomic,strong) NSNumber *Account;
@property (nonatomic,strong) NSString *Contextid;
@property (nonatomic,strong) NSString *Lastlogindate;
@property (nonatomic,strong) NSString *Masterid;
@property (nonatomic,strong) NSString *Postingdate;
@property (nonatomic,strong) NSString *Systemstate;
@property (nonatomic,strong) NSString *Loginattempts;
@property (nonatomic,strong) NSString *Accountname;
@property (nonatomic,strong) NSString *Name;
@property (nonatomic,strong) NSString *Email;

@property (nonatomic,strong) NSMutableArray *favouriteContactsArray;



@property (nonatomic) BOOL isQBOpen;
@property (nonatomic) BOOL isShowOffersOpen;
@property (nonatomic) BOOL isTouchIDOpen;
@property (nonatomic) BOOL isPushNotifOpen;
@property (nonatomic) BOOL hasUserAcceptedVertifiAgremant;

@property (nonatomic) BOOL hasUserUpdatedNotificationSettings;
@property (nonatomic) BOOL hasUserUpdatedTouchIDSettings;




@property (nonatomic,strong) NSString *UserName;
@property (nonatomic,strong) NSString *Password;


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
@property (nonatomic,strong) NSString *vertifyEUAContents;


@property (nonatomic,strong) NSNumber *isPictureSaveOn;
@property (nonatomic,strong) NSNumber *amIFollowing;

@property (nonatomic,strong) NSNumber *followersCount;
@property (nonatomic,strong) NSNumber *followingCount;
@property (nonatomic,strong) NSNumber *isFollower;
@property (nonatomic,strong) NSNumber *isFollowing;
@property (nonatomic,strong) NSNumber *isBlocked;
@property (nonatomic,strong) NSNumber *amIBlocked;

@property (nonatomic,strong) NSString *Gender;
@property (nonatomic,strong) NSString *Race;


@property (nonatomic,strong) NSString *Groupid;

@property (nonatomic,strong) NSString *Emailaddress;
@property (nonatomic,strong) NSString *Temppassword;
@property (nonatomic,strong) NSString *Newexpiration;
@property (nonatomic,strong) NSString *Last4;
@property (nonatomic,strong) NSString *zip;

@property (nonatomic,strong) NSArray *Requirements;






+(void)getUserWithParam:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(User* user))block failureBlock:(void(^)(NSError* error))failBlock;

+(void)createOneToOneChatWithParam:(NSDictionary*)param delegate:(id)delegate urlString:(NSString*)urlString completionBlock:(void(^)(id response))block failureBlock:(void(^)(NSError* error))failBlock;

+(void)blockUnblockUserWithParam:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(id response))block failureBlock:(void(^)(NSError* error))failBlock;

+(void)logoutUserUserWithParam:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(id response))block failureBlock:(void(^)(NSError* error))failBlock;


+(void)signOutUser:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(BOOL  sucess))block failureBlock:(void(^)(NSError* error))failBlock;

+(void)keepAlive:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(BOOL  sucess))block failureBlock:(void(^)(NSError* error))failBlock;

+(void)postContextIDForSSOWithDelegate:(id)delegate withTabName:(NSString *)url completionBlock:(void(^)(id  response))block failureBlock:(void(^)(NSError* error))failBlock;

+(void)userPinReset:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(id  response))block failureBlock:(void(^)(NSError* error))failBlock;

+(void)userAccountName:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(id  response))block failureBlock:(void(^)(NSError* error))failBlock;

+(void)setUserName:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(id  response))block failureBlock:(void(^)(NSError* error))failBlock;



@end
