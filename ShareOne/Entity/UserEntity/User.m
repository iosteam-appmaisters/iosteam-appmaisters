//
//  User.m
//  LivePolling
//
//  Created by Aliakber Hussain on 18/06/2013.
//  Copyright (c) 2013 Aliakber Hussain. All rights reserved.
//

#import "User.h"
#import "UtilitiesHelper.h"
#import "AppServiceModel.h"
#import "Services.h"
#import "Validation.h"
#import "ShareOneUtility.h"
#import "SharedUser.h"



@implementation User

#define UserIDKey @"UserIDKey"
#define UserEmailKey @"UserEmailKey"
#define UserUsernameKey @"UserUsernameKey"
#define UserUserAddressKey @"UserUserAddressKey"
#define UserUserPhoneNoKey @"UserUserPhoneNoKey"

#define UserUserImage @"UserUserImage"
#define UserUserCountryName @"UserUserCountryName"
#define UserUserCityName @"UserUserCityName"
#define UserSocialMediaId @"UserSocialMediaId"
#define PushStatus   @"PushStatus"

#define UserLoginType @"UserLoginType"
#define UserSkypeID @"UserSkypeID"
#define UserDOB @"UserDOB"
#define UserIsPushOn @"UserIsPushOn"
#define UserIsPictureSaveOn @"UserIsPictureSaveOn"
#define UserDisplayLocation @"UserDisplayLocation"

#define UserFollowersCount @"UserFollowersCount"
#define UserFollowingCount @"UserFollowingCount"
#define IsFollower @"IsFollower"
#define IsFollowing @"IsFollowing"
#define IsBlocked @"IsBlocked"
#define AMIBlocked @"AMIBlocked"

#define Gender @"Gender"
#define Race @"Race"
#define DistanceRange @"DistanceRange"
#define UserStatus @"UserStatus"
#define Latitude @"Latitude"
#define Longitude @"Longitude"
#define IsOnline @"IsOnline"
#define UserUserThumbImage @"UserUserThumbImage"

-(id) init{
    
    self = [super init];
    if (self) {
        
    }
    return self;
}

+(void)getUserWithParam:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(User* user))block failureBlock:(void(^)(NSError* error))failBlock{
    
    NSString *signature =[ShareOneUtility getAuthHeaderWithRequestType:RequestType_PUT];
    NSLog(@"signature logeed in : %@",signature);
    [ShareOneUtility savaLogedInSignature:signature];
    
    [[AppServiceModel sharedClient] putRequestWithAuthHeader:signature AndParam:param progressMessage:@"Pleas Wait..." urlString:[NSString stringWithFormat:@"%@/%@",KWEB_SERVICE_BASE_URL,KWEB_SERVICE_MEMBER_VALIDATE] delegate:delegate completionBlock:^(NSObject *response) {
        
        User* user = [[User alloc]initWithDictionary:(NSDictionary *)response];
        user.UserName=[param valueForKey:@"account"];
        user.Password=[param valueForKey:@"password"];

        [[SharedUser sharedManager] setUserObject:user];
        [ShareOneUtility saveUserObject:user];
        block(user);
        
    } failureBlock:^(NSError *error) {}];
}


+(void)signOutUser:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(BOOL  sucess))block failureBlock:(void(^)(NSError* error))failBlock{
    
    NSString *signature =[ShareOneUtility getAuthHeaderWithRequestType:RequestType_GET];
    
    [[AppServiceModel sharedClient] getMethod:signature AndParam:nil progressMessage:@"Pleas Wait..." urlString:[NSString stringWithFormat:@"%@/%@/%@",KWEB_SERVICE_BASE_URL,KWEB_SERVICE_SIGN_OUT,[[[SharedUser sharedManager] userObject] ContextID]] delegate:delegate completionBlock:^(NSObject *response) {

        block(TRUE);
        
    } failureBlock:^(NSError *error) {}];
}
//
//+(void)createOneToOneChatWithParam:(NSDictionary*)param delegate:(id)delegate urlString:(NSString*)urlString completionBlock:(void(^)(id response))block failureBlock:(void(^)(NSError* error))failBlock{
//    
//    [[AppServiceModel sharedClient]postImageRequestWithParameters:param progressMessage:@"Posting..." urlString:urlString delegate:delegate completionBlock:^(NSObject *response) {
//        
//        id object=[[AppServiceModel sharedClient] getParseDataForUserModule:(NSDictionary*)response];
//        if(object){
//            block(object);
//        }
//        
//    } failureBlock:^(NSError *error) {
//        
//    }];
//    
//}
//
//+(void)blockUnblockUserWithParam:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(id response))block failureBlock:(void(^)(NSError* error))failBlock{
//    
//    [[AppServiceModel sharedClient]postImageRequestWithParameters:param progressMessage:@"Updating..." urlString:KWEB_SERVICE_BLOCK_USER delegate:delegate completionBlock:^(NSObject *response) {
//        
//        id object=[[AppServiceModel sharedClient] getParseDataForUserModule:(NSDictionary*)response];
//        if(object){
//            block(response);
//        }
//    } failureBlock:^(NSError *error) {
//        
//    }];
//    
//}
//
//
//+(void)logoutUserUserWithParam:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(id response))block failureBlock:(void(^)(NSError* error))failBlock{
//    
//    [[AppServiceModel sharedClient]postImageRequestWithParameters:param progressMessage:@"Waiting..." urlString:KWEB_SERVICE_LOGOUT delegate:delegate completionBlock:^(NSObject *response) {
//        
//        id object=[[AppServiceModel sharedClient] getParseDataForUserModule:(NSDictionary*)response];
//        if(object){
//            block(response);
//        }
//    } failureBlock:^(NSError *error) {
//        
//    }];
//    
//}

-(id) initWithDictionary:(NSDictionary *)userProfileDict{
    self = [super init];{
        [self setValuesForKeysWithDictionary:userProfileDict];
    }
    return self;
}



- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if(self) {
        self.Account=[decoder decodeObjectForKey:@"Account"];
        self.ContextID=[decoder decodeObjectForKey:@"ContextID"];;
        self.LastLoginDate=[decoder decodeObjectForKey:@"LastLoginDate"];
        self.MasterID=[decoder decodeObjectForKey:@"MasterID"];
        self.PostingDate=[decoder decodeObjectForKey:@"PostingDate"];
        self.SystemState = [decoder decodeObjectForKey:@"SystemState"];
        self.UserName = [decoder decodeObjectForKey:@"UserName"];
        self.Password = [decoder decodeObjectForKey:@"Password"];
        self.LoginAttempts = [decoder decodeObjectForKey:@"LoginAttempts"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject: self.Account forKey:@"Account"];
    [encoder encodeObject: self.ContextID forKey:@"ContextID"];
    [encoder encodeObject: self.LastLoginDate forKey:@"LastLoginDate"];
    [encoder encodeObject: self.MasterID forKey:@"MasterID"];
    [encoder encodeObject: self.PostingDate forKey:@"PostingDate"];
    [encoder encodeObject: self.SystemState forKey:@"SystemState"];
    [encoder encodeObject: self.UserName forKey:@"UserName"];
    [encoder encodeObject: self.Password forKey:@"Password"];
    [encoder encodeObject: self.Password forKey:@"LoginAttempts"];
}
@end
