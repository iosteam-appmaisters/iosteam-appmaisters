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
#import "NSString+MD5String.h"




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
//    NSLog(@"signature logeed in : %@",signature);
    [ShareOneUtility savaLogedInSignature:signature];
    
    [[AppServiceModel sharedClient] putRequestWithAuthHeader:signature AndParam:param progressMessage:@"Please Wait..." urlString:[NSString stringWithFormat:@"%@/%@",KWEB_SERVICE_BASE_URL,KWEB_SERVICE_MEMBER_VALIDATE] delegate:delegate completionBlock:^(NSObject *response) {
        
        User* user = [[User alloc]initWithDictionary:(NSDictionary *)response];
        user.UserName=[param valueForKey:@"account"];
        user.Password=[param valueForKey:@"password"];

        [[SharedUser sharedManager] setUserObject:user];
        //[ShareOneUtility saveUserObject:user];
        
        
        [ShareOneUtility saveUserObjectToLocalObjects:user];
        
        //[ShareOneUtility setPreferencesOnLaunch];

        block(user);
        
    } failureBlock:^(NSError *error) {}];
}


+(void)signOutUser:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(BOOL  sucess))block failureBlock:(void(^)(NSError* error))failBlock{
    
    NSString *signature =[ShareOneUtility getAuthHeaderWithRequestType:RequestType_GET];
    
    [[AppServiceModel sharedClient] getMethod:signature AndParam:nil progressMessage:@"Please Wait..." urlString:[NSString stringWithFormat:@"%@/%@/%@",KWEB_SERVICE_BASE_URL,KWEB_SERVICE_SIGN_OUT,[[[SharedUser sharedManager] userObject] ContextID]] delegate:delegate completionBlock:^(NSObject *response) {

        block(TRUE);
        
    } failureBlock:^(NSError *error) {}];
}

+(void)keepAlive:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(BOOL  sucess))block failureBlock:(void(^)(NSError* error))failBlock{
    
    NSString *signature =[ShareOneUtility getAuthHeaderWithRequestType:RequestType_GET];
    
    [[AppServiceModel sharedClient] getMethod:signature AndParam:nil progressMessage:nil urlString:[NSString stringWithFormat:@"%@/%@/%@",KWEB_SERVICE_BASE_URL,kKEEP_ALIVE,[[[SharedUser sharedManager] userObject] ContextID]] delegate:nil completionBlock:^(NSObject *response) {
        
        if([response isKindOfClass:[NSDictionary class]])
            block(TRUE);
        else
            block(FALSE);
        
    } failureBlock:^(NSError *error) {}];
}

+(void)postContextIDForSSOWithDelegate:(id)delegate withTabName:(NSString *)url completionBlock:(void(^)(id  response))block failureBlock:(void(^)(NSError* error))failBlock{
    
    NSString *contexID = [[[SharedUser sharedManager] userObject] ContextID];
    
    NSString *signature =[ShareOneUtility getAuthHeaderWithRequestType:RequestType_GET];

    NSDictionary *object = [ShareOneUtility encryptionByFBEncryptorAESWithContextID:contexID];
    
    NSString *encrytedID = [[object valueForKey:@"EncryptedContextID"] URLEncodedString_ch];
    NSString *randomIV = [[object valueForKey:@"EncryptionIV"] URLEncodedString_ch];
    NSString *redirect_path = [url URLEncodedString_ch] ;

    NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:encrytedID ,@"EncryptedContextID",randomIV ,@"EncryptionIV",redirect_path  ,@"RedirectPath", nil];
    
    NSString *siteurl = [NSString stringWithFormat:@"%@/%@?",KWEB_SERVICE_BASE_URL_SSO,KSINGLE_SIGN_ON];
    NSString *enquiryurl = [NSString stringWithFormat:@"%@EncryptedContextID=%@&EncryptionIV=%@&RedirectPath=%@",siteurl,encrytedID,randomIV,redirect_path];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:enquiryurl]];
//    NSLog(@"ULR : %@",request.URL.absoluteString);


    block(request);

    return;
   NSMutableURLRequest *req = [[AppServiceModel sharedClient] getRequestForSSOWithAuthHeader:nil AndParam:dict progressMessage:nil urlString:[NSString stringWithFormat:@"%@/%@",KWEB_SERVICE_BASE_URL_SSO,KSINGLE_SIGN_ON] delegate:delegate completionBlock:^(NSObject *response) {
       
       
        block(response);
    } failureBlock:^(NSError *error) {
        
    }];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

    block(req);
    
    NSLog(@"req.URL : %@",req.URL.absoluteString);
    
    return;
    [[AppServiceModel sharedClient] postRequestForSSOWithAuthHeader:signature AndParam:dict progressMessage:nil urlString:[NSString stringWithFormat:@"%@/%@",KWEB_SERVICE_BASE_URL_SSO,KSINGLE_SIGN_ON] delegate:delegate completionBlock:^(NSObject *response) {
        block(response);
        
    } failureBlock:^(NSError *error) {
        
    }];
}


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
        self.isPushNotifOpen = [decoder decodeBoolForKey:@"isPushNotifOpen"];
        self.isShowOffersOpen = [decoder decodeBoolForKey:@"isShowOffersOpen"];
        self.isQBOpen = [decoder decodeBoolForKey:@"isQBOpen"];
        self.isTouchIDOpen = [decoder decodeBoolForKey:@"isTouchIDOpen"];
        self.hasUserAcceptedVertifiAgremant = [decoder decodeBoolForKey:@"hasUserAcceptedVertifiAgremant"];
        self.hasUserUpdatedNotificationSettings = [decoder decodeBoolForKey:@"hasUserUpdatedNotificationSettings"];
        self.hasUserUpdatedTouchIDSettings = [decoder decodeBoolForKey:@"hasUserUpdatedTouchIDSettings"];

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
    [encoder encodeBool:self.isPushNotifOpen forKey:@"isPushNotifOpen"];
    [encoder encodeBool:self.isShowOffersOpen forKey:@"isShowOffersOpen"];
    [encoder encodeBool:self.isQBOpen forKey:@"isQBOpen"];
    [encoder encodeBool:self.isTouchIDOpen forKey:@"isTouchIDOpen"];
    [encoder encodeBool:self.hasUserAcceptedVertifiAgremant forKey:@"hasUserAcceptedVertifiAgremant"];
    [encoder encodeBool:self.hasUserUpdatedNotificationSettings forKey:@"hasUserUpdatedNotificationSettings"];
    [encoder encodeBool:self.hasUserUpdatedTouchIDSettings forKey:@"hasUserUpdatedTouchIDSettings"];

}
@end
