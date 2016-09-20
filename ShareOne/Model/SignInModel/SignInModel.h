//
//  SignInModel.h
//  LivePolling
//
//  Created by Aliakber Hussain on 18/06/2013.
//  Copyright (c) 2013 Aliakber Hussain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

typedef enum{
    PIN_DROP_MESSAGE,
    EMERGENCY_MESSAGE,
    NORMAL_BROADCAST,
}MessageType;

@interface SignInModel : NSObject

@property(nonatomic)MessageType messageType;

+ (SignInModel*)signIn;
+ (BOOL)checkUserData;
+ (void)removeUserData;
+ (User *)getUserData;
+ (void)saveUserInfo:(User *)userinfo;
+ (User*)saveUserInformation:(NSDictionary *)result;
+(void)saveCountryName:(NSString*)countryName andCountryID:(NSNumber*)countryId;
+(void)saveCityName:(NSString*)cityName andCityID:(NSNumber*)cityId;
+(void)saveStateName:(NSString*)stateName andStateID :(NSNumber*)stateId;
+(void)saveCurrency:(NSString*)currency;
+(void)savePushStatus:(BOOL)status;
+(void)saveOnlineStatus:(NSString*)status;
+(void)saveUserStatus:(NSString*)status;

+ (NSString*)getUserDeviceToken;
+(void)saveDeviceToken:(NSString*)deviceToken;
+ (BOOL)checkUserDeviceToken;
+(NSString*)getCountryName;
+(NSString*)getCityName;
+(NSString*)getStateName;

+(NSString*)getCurrency;
+(NSNumber*)getCountryID;
+(NSNumber*)getCityID;
+(NSNumber*)getStateID;
+(void)saveDistanceRange:(NSNumber*)range;


+(NSString*)getImage;
+(void)updateUserLanguage:(NSString*)userLanguage;


+(void)loginOrRegisterUserWithParam:(NSDictionary*)param serviceUrl:(NSString*)serviceUrl progressMessage:(NSString*)progressMessage delegate:(id)delegate completionBlock:(void(^)(User* user))block failureBlock:(void(^)(NSError* error))failBlock;

+(void)forgotPasswordWithParam:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(User* user))block failureBlock:(void(^)(NSError* error))failBlock;


+(void)updateUserWithParam:(NSDictionary*)param delegate:(id)delegate image:(NSData*)imageData serviceUrl:(NSString*)serviceUrl completionBlock:(void(^)(NSString* message))block failureBlock:(void(^)(NSError* error))failBlock;


+(void)saveDistanceWithParam:(NSDictionary*)param  delegate:(id)delegate completionBlock:(void(^)(User* user))block failureBlock:(void(^)(NSError* error))failBlock;

+(void)saveLocationithParam:(NSDictionary*)param  delegate:(id)delegate completionBlock:(void(^)(User* user))block failureBlock:(void(^)(NSError* error))failBlock;

+(void)updateData:(NSDictionary*)param serviceUrl:(NSString*)serviceUrl progressMessage:(NSString*)progressMessage delegate:(id)delegate completionBlock:(void(^)(User* user))block failureBlock:(void(^)(NSError* error))failBlock;

@end
