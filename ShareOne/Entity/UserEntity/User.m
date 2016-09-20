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
//
//+(void)getUserWithParam:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(User* user))block failureBlock:(void(^)(NSError* error))failBlock{
//    
//    [[AppServiceModel sharedClient]postRequestWithParameters:param progressMessage:@"Fetching..." urlString:KWEB_SERVICE_GET_USER_PROFILE delegate:delegate completionBlock:^(NSObject *response) {
//        
//        id object=[[AppServiceModel sharedClient] getParseDataForUserModule:(NSDictionary*)response];
//        if(object){
//
//            User* user = [[User alloc]initWithDictionary:[object objectAtIndex:0]];
//            block(user);
//            
//        }
//        
//    } failureBlock:^(NSError *error) {
//        
//    }];
//}
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
    self = [super init];
    
    self.userAddress=[userProfileDict valueForKey:@"address"];
    self.userEmail=[userProfileDict valueForKey:@"email"];;
    self.userId=[userProfileDict valueForKey:@"id"];
    self.userName=[userProfileDict valueForKey:@"name"];
    self.userPhoneNo=[UtilitiesHelper getStringFromObject:[userProfileDict valueForKey:@"phone"]];
    
    self.userImage = [NSURL URLWithString:[UtilitiesHelper getStringFromObject:[userProfileDict valueForKey:@"photo"]]];
    self.userCountryName =[UtilitiesHelper getEmptyStringFromObjectIfNull:[userProfileDict valueForKey:@"country"]];
    self.userCityName = [UtilitiesHelper getEmptyStringFromObjectIfNull:[userProfileDict valueForKey:@"city"]];
    self.userAddress=[UtilitiesHelper getEmptyStringFromObjectIfNull:[userProfileDict valueForKey:@"address"]];
    self.userSocialMediaId=[userProfileDict valueForKey:@"social_id"];

    self.loginType=[UtilitiesHelper getStringFromObject:[userProfileDict valueForKey:@"logintype"]];
    self.skypeID=[UtilitiesHelper getStringFromObject:[userProfileDict valueForKey:@"skype_id"]];
    self.dob=[UtilitiesHelper getStringFromObject:[userProfileDict valueForKey:@"age"]];
    self.isPushOn=[UtilitiesHelper getStringFromObject:[userProfileDict valueForKey:@"notification"]];
    self.isPictureSaveOn=[NSNumber numberWithInt:[[userProfileDict valueForKey:@"pictureStatus"] intValue]];
    self.amIFollowing=[NSNumber numberWithInt:[[userProfileDict valueForKey:@"am_i_following"] intValue]];

    self.followersCount=[NSNumber numberWithInt:[[userProfileDict valueForKey:@"total_followers"] intValue]];
    self.followingCount=[NSNumber numberWithInt:[[userProfileDict valueForKey:@"total_following"] intValue]];
    self.isFollower=[NSNumber numberWithInt:[[userProfileDict valueForKey:@"is_follower"] intValue]];
    self.isFollowing=[NSNumber numberWithInt:[[userProfileDict valueForKey:@"is_following"] intValue]];
    self.isBlocked=[NSNumber numberWithInt:[[userProfileDict valueForKey:@"is_blocked"] intValue]];
    self.amIBlocked=[NSNumber numberWithInt:[[userProfileDict valueForKey:@"am_i_blocked"] intValue]];
    self.gender=[UtilitiesHelper getStringFromObject:[userProfileDict valueForKey:@"gender"]];
    self.race=[UtilitiesHelper getStringFromObject:[userProfileDict valueForKey:@"race"]];
    self.userStatus=[UtilitiesHelper getStringFromObject:[userProfileDict valueForKey:@"status_message"]];
    self.latitude=[NSNumber numberWithDouble:[[UtilitiesHelper getStringFromObject:[userProfileDict valueForKey:@"latitude"]] doubleValue]];
    self.longitude=[NSNumber numberWithDouble:[[UtilitiesHelper getStringFromObject:[userProfileDict valueForKey:@"longitude"]] doubleValue]];
    self.isOnline=[UtilitiesHelper getStringFromObject:[userProfileDict valueForKey:@"presence"]];
    self.distanceRange=[NSNumber numberWithDouble:[[userProfileDict valueForKey:@"distance"] doubleValue]];
    self.userThumbImage = [NSURL URLWithString:[UtilitiesHelper getStringFromObject:[userProfileDict valueForKey:@"photo_thumb"]]];
    self.groupId=[UtilitiesHelper getStringFromObject:[userProfileDict valueForKey:@"group_id"]];

    
    NSString* location;
    
    if([Validation isEmpty:self.userCountryName])
        location=@"(Location: NA)";
    else
        location=[NSString stringWithFormat:@"(%@, %@)",self.userCityName,self.userCountryName];
    
    self.userDisplayLocation=location;
    
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if(self) {
        self.userAddress=[decoder decodeObjectForKey:UserUserAddressKey];
        self.userEmail=[decoder decodeObjectForKey:UserEmailKey];;
        self.userId=[decoder decodeObjectForKey:UserIDKey];
        self.userName=[decoder decodeObjectForKey:UserUsernameKey];
        self.userPhoneNo=[decoder decodeObjectForKey:UserUserPhoneNoKey];
       
        self.userImage = [decoder decodeObjectForKey:UserUserImage];
        self.userCountryName =[decoder decodeObjectForKey:UserUserCountryName];
        self.userCityName = [decoder decodeObjectForKey:UserUserCityName];
        self.userSocialMediaId=[decoder decodeObjectForKey:UserSocialMediaId];
        
        self.loginType = [decoder decodeObjectForKey:UserLoginType];
        self.skypeID =[decoder decodeObjectForKey:UserSkypeID];
        self.dob = [decoder decodeObjectForKey:UserDOB];
        self.isPushOn=[decoder decodeObjectForKey:UserIsPushOn];
        self.isPictureSaveOn=[decoder decodeObjectForKey:UserIsPictureSaveOn];
        self.userDisplayLocation=[decoder decodeObjectForKey:UserDisplayLocation];
        self.gender=[decoder decodeObjectForKey:Gender];
        self.race=[decoder decodeObjectForKey:Race];
        self.userStatus=[decoder decodeObjectForKey:UserStatus];
        self.latitude=[decoder decodeObjectForKey:Latitude];
        self.longitude=[decoder decodeObjectForKey:Longitude];
        self.isOnline=[decoder decodeObjectForKey:IsOnline];
        self.distanceRange=[decoder decodeObjectForKey:DistanceRange];
        self.userThumbImage=[decoder decodeObjectForKey:UserUserThumbImage];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject: self.userAddress forKey:UserUserAddressKey];
    [encoder encodeObject: self.userEmail forKey:UserEmailKey];
    [encoder encodeObject: self.userId forKey:UserIDKey];
    [encoder encodeObject: self.userName forKey:UserUsernameKey];
    [encoder encodeObject: self.userPhoneNo forKey:UserUserPhoneNoKey];
    
    [encoder encodeObject: self.userImage forKey:UserUserImage];
    [encoder encodeObject: self.userCountryName forKey:UserUserCountryName];
    [encoder encodeObject: self.userCityName forKey:UserUserCityName];
    [encoder encodeObject: self.userSocialMediaId forKey:UserSocialMediaId];
    
    [encoder encodeObject: self.loginType forKey:UserLoginType];
    [encoder encodeObject: self.skypeID forKey:UserSkypeID];
    [encoder encodeObject: self.dob forKey:UserDOB];
    [encoder encodeObject: self.isPushOn forKey:UserIsPushOn];
    [encoder encodeObject: self.isPictureSaveOn forKey:UserIsPictureSaveOn];
    [encoder encodeObject: self.userDisplayLocation forKey:UserDisplayLocation];
    [encoder encodeObject: self.gender forKey:Gender];
    [encoder encodeObject: self.race forKey:Race];
    [encoder encodeObject: self.userStatus forKey:UserStatus];
    [encoder encodeObject: self.latitude forKey:Latitude];
    [encoder encodeObject: self.longitude forKey:Longitude];
    [encoder encodeObject: self.isOnline forKey:IsOnline];
    [encoder encodeObject: self.distanceRange forKey:DistanceRange];
    [encoder encodeObject: self.userThumbImage forKey:UserUserThumbImage];


}
@end
