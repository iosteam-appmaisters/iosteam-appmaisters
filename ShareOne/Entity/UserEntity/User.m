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
#import "ConstantsShareOne.h"



@implementation User

#define UserIDKey @"UserIDKey"
#define UserEmailKey @"UserEmailKey"
#define UserUsernameKey @"UserUsernameKey"
#define UserUserAddressKey @"UserUserAddressKey"
#define UserUserPhoneNoKey @"UserUserPhoneNoKey"

#define UserUserImage @"UserUserImage"
#define UserUserCountryName @"UserUserCountryName"
#define UserUserCityName @"UserUserCityName"
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

+(void)getUserWithParam:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(id user))block failureBlock:(void(^)(NSError* error))failBlock{
    
    NSString *signature =[ShareOneUtility getAuthHeaderWithRequestType:RequestType_POST];
    NSLog(@"param logeed in : %@",param);
    [ShareOneUtility savaLogedInSignature:signature];
    
    
    [[AppServiceModel sharedClient] postRequestWithAuthHeader:signature AndParam:param progressMessage:nil  urlString:[NSString stringWithFormat:@"%@/%@",[ShareOneUtility getBaseUrl],KWEB_SERVICE_LOGIN] delegate:delegate completionBlock:^(NSObject *response) {
        
        User* user;
        if([response isKindOfClass:[NSDictionary class]]){

            NSDictionary * responseDic = @{@"Suffixes":[(NSDictionary*)response valueForKey:@"Suffixes"]};
            
            NSArray *suffixArr = [SuffixInfo getSuffixArrayWithObject:responseDic];
            [ShareOneUtility savedSuffixInfo:responseDic];
            [[SharedUser sharedManager] setSuffixInfoArr:suffixArr];
            
//            [ShareOneUtility setStatusOfPasswordChanged:NO];
            user = [[User alloc]initWithDictionary:(NSDictionary *)response];
            user.UserName=[param valueForKey:@"account"];
            if([user.Requirements count]==0)
                user.Password=[param valueForKey:@"password"];
            
            [[NSUserDefaults standardUserDefaults]setBool:TRUE forKey:SHOULD_SSO];
            [[NSUserDefaults standardUserDefaults]synchronize];
            
            [[SharedUser sharedManager] setUserObject:user];
            //[ShareOneUtility saveUserObject:user];
            
            [ShareOneUtility saveUserObjectToLocalObjects:user];
            
            if ([[NSUserDefaults standardUserDefaults]boolForKey:OVERRIDE_TOUCH_ID]){
                [[NSUserDefaults standardUserDefaults]setBool:NO forKey:OVERRIDE_TOUCH_ID];
                [[NSUserDefaults standardUserDefaults]synchronize];
                
                [ShareOneUtility saveSettingsWithStatus:NO AndKey:TOUCH_ID_SETTINGS];
            }
            block(user);
            
            //[ShareOneUtility setPreferencesOnLaunch];
        }
       else if([response isKindOfClass:[NSString class]]){
           
           NSString *responseString = (NSString *)response;
            block(responseString);
        }
        else
            block(nil);

    } failureBlock:^(NSError *error) {
        failBlock(error);
    }];

}


+(void)signOutUser:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(BOOL  sucess))block failureBlock:(void(^)(NSError* error))failBlock{
    
    NSString *signature =[ShareOneUtility getAuthHeaderWithRequestType:RequestType_GET];
    
    [[AppServiceModel sharedClient] getMethod:signature AndParam:nil progressMessage:nil urlString:[NSString stringWithFormat:@"%@/%@/%@",[ShareOneUtility getBaseUrl],KWEB_SERVICE_SIGN_OUT,[[[SharedUser sharedManager] userObject] Contextid]] delegate:delegate completionBlock:^(NSObject *response) {
        
        if([response isKindOfClass:[NSDictionary class]])
            block(TRUE);
        else
            block(FALSE);
        
    } failureBlock:^(NSError *error) {}];
}

+(void)keepAlive:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(BOOL  sucess))block failureBlock:(void(^)(NSError* error))failBlock{
    
    NSString *signature =[ShareOneUtility getAuthHeaderWithRequestType:RequestType_GET];
    
    [[AppServiceModel sharedClient] getMethod:signature AndParam:nil progressMessage:nil urlString:[NSString stringWithFormat:@"%@/%@/%@",[ShareOneUtility getBaseUrl],kKEEP_ALIVE,[[[SharedUser sharedManager] userObject] Contextid]] delegate:nil completionBlock:^(NSObject *response) {
        
        if([response isKindOfClass:[NSDictionary class]]){
            block(TRUE);
        }
        else {
            block(FALSE);
        }
        
    } failureBlock:^(NSError *error) {}];
}

+(void)postContextIDForSSOWithDelegate:(id)delegate withTabName:(NSString *)url completionBlock:(void(^)(NSMutableURLRequest *  request))block failureBlock:(void(^)(NSError* error))failBlock{
    
    NSString *contexID = [[[SharedUser sharedManager] userObject] Contextid];
    
//    NSString *signature =[ShareOneUtility getAuthHeaderWithRequestType:RequestType_GET];

    NSDictionary *object = [ShareOneUtility encryptionByFBEncryptorAESWithContextID:contexID];
    
    NSString *encrytedID = [[object valueForKey:@"EncryptedContextID"] URLEncodedString_ch];
    NSString *randomIV = [[object valueForKey:@"EncryptionIV"] URLEncodedString_ch];
    NSString *redirect_path = [url URLEncodedString_ch] ;

//    NSDictionary * dict = [NSDictionary dictionaryWithObjectsAndKeys:encrytedID ,@"EncryptedContextID",randomIV ,@"EncryptionIV",redirect_path  ,@"RedirectPath", nil];
    NSString *siteurl = [NSString stringWithFormat:@"%@/%@?",[Configuration getSSOBaseUrl],KSINGLE_SIGN_ON];
    
    NSString *enquiryurl = [NSString stringWithFormat:@"%@EncryptedContextID=%@&EncryptionIV=%@&RedirectPath=%@",siteurl,encrytedID,randomIV,redirect_path];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:enquiryurl]];
    NSLog(@"ULR : %@",request.URL.absoluteString);


    block([request mutableCopy]);
}


+(void)getUserPasswordExpiredUrlDelegate:(id)delegate completionBlock:(void(^)(id  response))block failureBlock:(void(^)(NSError* error))failBlock{

    NSString *signature =[ShareOneUtility getAuthHeaderWithRequestType:RequestType_GET];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    
//    NSString *siteurl = [NSString stringWithFormat:@"%@/%@?",[Configuration getSSOBaseUrl],KSINGLE_SIGN_ON];
    

    NSMutableURLRequest *req = [[AppServiceModel sharedClient] getRequestForSSOWithAuthHeader:signature AndParam:nil progressMessage:nil urlString:[NSString stringWithFormat:@"%@/%@",[Configuration getSSOBaseUrl],KSINGLE_SIGN_ON] delegate:delegate completionBlock:^(NSObject *response) {
        
        
        block(response);
    } failureBlock:^(NSError *error) {
        
    }];
    
    
    block(req);

}
+(void)userPinReset:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(id  response))block failureBlock:(void(^)(NSError* error))failBlock{
    
    [[AppServiceModel sharedClient] putRequestWithAuthHeader:[ShareOneUtility getAuthHeaderWithRequestType:RequestType_PUT] AndParam:param progressMessage:@"Please wait..." urlString:[NSString stringWithFormat:@"%@/%@",[ShareOneUtility getBaseUrl],KPIN_RESET] delegate:delegate completionBlock:^(NSObject *response) {
        
        block(response);
    } failureBlock:^(NSError *error) {
        
    }];

}

+(void)userAccountName:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(id  response))block failureBlock:(void(^)(NSError* error))failBlock{
    
    [[AppServiceModel sharedClient] putRequestWithAuthHeader:[ShareOneUtility getAuthHeaderWithRequestType:RequestType_PUT] AndParam:param progressMessage:@"Please wait..." urlString:[NSString stringWithFormat:@"%@/%@",[ShareOneUtility getBaseUrl],KACCOUNT_NAME] delegate:delegate completionBlock:^(NSObject *response) {
        
        block(response);
    } failureBlock:^(NSError *error) {
        
    }];
    
}



+(void)setUserName:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(id  response))block failureBlock:(void(^)(NSError* error))failBlock{
    
    NSString *signature =[ShareOneUtility getAuthHeaderWithRequestType:RequestType_POST];

    
    [[AppServiceModel sharedClient] postRequestWithAuthHeader:signature AndParam:param progressMessage:nil  urlString:[NSString stringWithFormat:@"%@/%@",[ShareOneUtility getBaseUrl],KSET_ACCOUNT_NAME] delegate:delegate completionBlock:^(NSObject *response) {
        block(response);
        
    } failureBlock:^(NSError *error) {
        failBlock(error);
    }];


}

-(id) initWithDictionary:(NSDictionary *)userProfileDict{
    User *obj = [[User alloc] init];
    self = [super init];{
        
        
        [self parseUserInfoOnLoginWithObject:obj AndParsingDict:userProfileDict];
        NSDictionary *masterDict = userProfileDict[@"Master"];
        NSDictionary *getVersionNumberDic = userProfileDict[@"IOSLoginPrompt"];
        
        [[NSUserDefaults standardUserDefaults] setObject:getVersionNumberDic forKey:AFTER_LOGIN_VERSION_NUMBER];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self parseUserInfoOnLoginWithObject:obj AndParsingDict:masterDict];
        
    }
    
    return obj;
}

-(void)parseUserInfoOnLoginWithObject:(User *)obj AndParsingDict:(NSDictionary *)userProfileDict{
    
    for (NSString* key in userProfileDict) {
        id value = [userProfileDict objectForKey:key];
        
        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", [[key substringToIndex:1] uppercaseString], [[key substringFromIndex:1] lowercaseString]]);
//        NSLog(@"Selector Name: %@ Value :%@",NSStringFromSelector(selector),value);
        if (value != [NSNull null]) {
            if ([obj respondsToSelector:selector]) {
                
#       pragma clang diagnostic push
#       pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [obj performSelector:selector withObject:value];
#       pragma clang diagnostic pop
            }
        }
    }

}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if(self) {
        self.vertifyEUAContents=[decoder decodeObjectForKey:@"vertifyEUAContents"];
        self.Account=[decoder decodeObjectForKey:@"Account"];
        self.Contextid=[decoder decodeObjectForKey:@"Contextid"];;
        self.Lastlogindate=[decoder decodeObjectForKey:@"Lastlogindate"];
        self.Masterid=[decoder decodeObjectForKey:@"Masterid"];
        self.Postingdate=[decoder decodeObjectForKey:@"Postingdate"];
        self.Systemstate = [decoder decodeObjectForKey:@"Systemstate"];
        self.UserName = [decoder decodeObjectForKey:@"UserName"];
        self.Password = [decoder decodeObjectForKey:@"Password"];
        self.Loginattempts = [decoder decodeObjectForKey:@"Loginattempts"];
        self.isPushNotifOpen = [decoder decodeBoolForKey:@"isPushNotifOpen"];
        self.isShowOffersOpen = [decoder decodeBoolForKey:@"isShowOffersOpen"];
        self.isQBOpen = [decoder decodeBoolForKey:@"isQBOpen"];
        self.isTouchIDOpen = [decoder decodeBoolForKey:@"isTouchIDOpen"];
        self.isReSkinOn=[decoder decodeBoolForKey:@"isReSkinOn"];
        self.hasUserAcceptedVertifiAgremant = [decoder decodeBoolForKey:@"hasUserAcceptedVertifiAgremant"];
        self.hasUserUpdatedNotificationSettings = [decoder decodeBoolForKey:@"hasUserUpdatedNotificationSettings"];
        self.hasUserUpdatedTouchIDSettings = [decoder decodeBoolForKey:@"hasUserUpdatedTouchIDSettings"];
        self.Emailaddress=[decoder decodeObjectForKey:@"Emailaddress"];
        self.Temppassword=[decoder decodeObjectForKey:@"Temppassword"];
        self.Newexpiration=[decoder decodeObjectForKey:@"Newexpiration"];
        
        self.Accountname=[decoder decodeObjectForKey:@"Accountname"];
        self.Name=[decoder decodeObjectForKey:@"Name"];
        self.Email=[decoder decodeObjectForKey:@"Email"];
        self.favouriteContactsArray=[decoder decodeObjectForKey:@"favouriteContactsArray"];
        self.LoginValidation=[decoder decodeObjectForKey:@"LoginValidation"];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    
    [encoder encodeObject: self.vertifyEUAContents forKey:@"vertifyEUAContents"];
    [encoder encodeObject: self.Account forKey:@"Account"];
    [encoder encodeObject: self.Contextid forKey:@"Contextid"];
    [encoder encodeObject: self.Lastlogindate forKey:@"Lastlogindate"];
    [encoder encodeObject: self.Masterid forKey:@"Masterid"];
    [encoder encodeObject: self.Postingdate forKey:@"Postingdate"];
    [encoder encodeObject: self.Systemstate forKey:@"Systemstate"];
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
    [encoder encodeObject: self.Emailaddress forKey:@"Emailaddress"];
    [encoder encodeObject: self.Temppassword forKey:@"Temppassword"];
    [encoder encodeObject: self.Newexpiration forKey:@"Newexpiration"];
    [encoder encodeObject: self.Accountname forKey:@"Accountname"];
    [encoder encodeObject: self.Name forKey:@"Name"];
    [encoder encodeObject: self.Email forKey:@"Email"];
    [encoder encodeObject: self.favouriteContactsArray forKey:@"favouriteContactsArray"];
    [encoder encodeObject: self.LoginValidation forKey:@"LoginValidation"];
    [encoder encodeBool:self.isReSkinOn forKey:@"isReSkinOn"];



}
@end
