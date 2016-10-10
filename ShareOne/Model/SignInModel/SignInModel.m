//
//  SignInModel.m
//  LivePolling
//
//  Created by Aliakber Hussain on 18/06/2013.
//  Copyright (c) 2013 Aliakber Hussain. All rights reserved.
//

#import "SignInModel.h"
#import "AppDelegate.h"
#import "AppServiceModel.h"
#import "SignInModuleConstants.h"
#import "UtilitiesHelper.h"
#import "Services.h"

static SignInModel *signInSingleton = nil;

@implementation SignInModel

//+(void)updateUserWithParam:(NSDictionary*)param delegate:(id)delegate image:(NSData*)imageData serviceUrl:(NSString*)serviceUrl completionBlock:(void(^)(NSString* message))block failureBlock:(void(^)(NSError* error))failBlock{
//    
//    [[AppServiceModel sharedClient]postImageRequestWithParameters:param progressMessage:@"Updating..." urlString:serviceUrl delegate:delegate completionBlock:^(NSObject *response) {
//        id object=[[AppServiceModel sharedClient] getParseDataForUserModule:(NSDictionary*)response];
//        
//        if(object){
//            NSDictionary *userDicionary = [object objectAtIndex:0];
//            [SignInModel saveUserInformation:userDicionary];
//            block(@"User updated successfully!");
//        }
//        
//    } failureBlock:^(NSError *error) {
//        
//    }];
//    
//}
//+(void)loginOrRegisterUserWithParam:(NSDictionary*)param serviceUrl:(NSString*)serviceUrl progressMessage:(NSString*)progressMessage delegate:(id)delegate completionBlock:(void(^)(User* user))block failureBlock:(void(^)(NSError* error))failBlock{
//    
//    [[AppServiceModel sharedClient]postImageRequestWithParameters:param progressMessage:progressMessage urlString:serviceUrl delegate:delegate completionBlock:^(NSObject *response) {
//        
//        id object=[[AppServiceModel sharedClient] getParseDataForUserModule:(NSDictionary*)response];
//        if(object){
//            [SignInModel saveUserInformation:[object objectAtIndex:0]];
//            block([SignInModel getUserData]);
//        }
//        else{
//            NSDictionary* dict=(NSDictionary*)response;
//            [[UtilitiesHelper shareUtitlities]showAlertWithMessage:[dict objectForKey:@"message"] title:@"" delegate:delegate];
//            //            block([SignInModel getUserData]);
//            failBlock(object);
//            
//        }
//    } failureBlock:^(NSError *error) {
//        failBlock(error);
//    }];
//}
//
//+(void)forgotPasswordWithParam:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(User* user))block failureBlock:(void(^)(NSError* error))failBlock{
//    
//    [[AppServiceModel sharedClient]postImageRequestWithParameters:param progressMessage:@"Waiting..." urlString:KWEB_SERVICE_FORGOT_PASSWORD delegate:delegate completionBlock:^(NSObject *response) {
//        
//        id object=[[AppServiceModel sharedClient] getParseDataForUserModule:(NSDictionary*)response];
//        if(object){
//            block(object);
//        }
//        else{
//            NSDictionary* dict=(NSDictionary*)response;
//            [[UtilitiesHelper shareUtitlities]showAlertWithMessage:[dict objectForKey:@"message"] title:@"" delegate:delegate];
//            failBlock(object);
//            
//        }
//    } failureBlock:^(NSError *error) {
//        failBlock(error);
//    }];
//    
//}
//
//+(void)saveDistanceWithParam:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(User* user))block failureBlock:(void(^)(NSError* error))failBlock{
//    
//    [[AppServiceModel sharedClient]postImageRequestWithParameters:param progressMessage:@"Updating..." urlString:KWEB_SERVICE_EDIT_DISTANCE_RANGE delegate:delegate completionBlock:^(NSObject *response) {
//        
//        id object=[[AppServiceModel sharedClient] getParseDataForUserModule:(NSDictionary*)response];
//        if(object){
//            block(object);
//        }
//        else{
//            NSDictionary* dict=(NSDictionary*)response;
//            [[UtilitiesHelper shareUtitlities]showAlertWithMessage:[dict objectForKey:@"message"] title:@"" delegate:delegate];
//            failBlock(object);
//            
//        }
//    } failureBlock:^(NSError *error) {
//        failBlock(error);
//    }];
//}
//
//+(void)saveLocationithParam:(NSDictionary*)param  delegate:(id)delegate completionBlock:(void(^)(User* user))block failureBlock:(void(^)(NSError* error))failBlock{
//    
//    [[AppServiceModel sharedClient]postImageRequestWithParameters:param progressMessage:nil urlString:KWEB_SERVICE_UPDATE_USER_LOCATION delegate:delegate completionBlock:^(NSObject *response) {
//        
//        id object=[[AppServiceModel sharedClient] getParseDataForUserModule:(NSDictionary*)response];
//        if(object){
//            block(object);
//        }
//        else{
//            NSDictionary* dict=(NSDictionary*)response;
//            [[UtilitiesHelper shareUtitlities]showAlertWithMessage:[dict objectForKey:@"message"] title:@"" delegate:delegate];
//            failBlock(object);
//            
//        }
//    } failureBlock:^(NSError *error) {
//        failBlock(error);
//    }];
//}
//
//+(void)updateData:(NSDictionary*)param serviceUrl:(NSString*)serviceUrl progressMessage:(NSString*)progressMessage delegate:(id)delegate completionBlock:(void(^)(User* user))block failureBlock:(void(^)(NSError* error))failBlock{
//    
//    [[AppServiceModel sharedClient]postImageRequestWithParameters:param progressMessage:progressMessage urlString:serviceUrl delegate:delegate completionBlock:^(NSObject *response) {
//        
//        id object=[[AppServiceModel sharedClient] getParseDataForUserModule:(NSDictionary*)response];
//        if(object){
//            block(object);
//        }
//        else{
//            NSDictionary* dict=(NSDictionary*)response;
//            [[UtilitiesHelper shareUtitlities]showAlertWithMessage:[dict objectForKey:@"message"] title:@"" delegate:delegate];
//            failBlock(object);
//            
//        }
//    } failureBlock:^(NSError *error) {
//        failBlock(error);
//    }];
//}


+ (SignInModel*)signIn{
   	@synchronized(self) {
        if (signInSingleton == nil)
            signInSingleton = [[SignInModel alloc] init];
        
    }
    return signInSingleton;
}

# pragma mark - Check if User data saved in NSUserDefault

+ (BOOL)checkUserData{
    
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    if ([userdefault objectForKey:@"userinfo"])
        return YES;
    else
        return NO;
}

+ (BOOL)checkUserDeviceToken{
    
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    if ([userdefault objectForKey:DEVICE_TOKEN])
        return YES;
    else
        return NO;
}

# pragma mark - Remove User Info from NSUserDefault

+ (void)removeUserData{
    
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    [userdefault removeObjectForKey:@"userinfo"];
    
    [userdefault removeObjectForKey:USER_TYPE];
    [userdefault synchronize];
}

# pragma mark - Get User Info from NSUserDefault

+ (User *)getUserData{
    
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    NSData *archivedObject = [userdefault objectForKey:@"userinfo"];
    User *ui = (User *)[NSKeyedUnarchiver unarchiveObjectWithData:archivedObject];
    return ui;
}

+ (NSString*)getUserDeviceToken{
    
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    return [userdefault valueForKey:DEVICE_TOKEN];
}

+(NSString*)getCountryName{
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    
    //NSLog(@"%@",userdefault);
    //return [userdefault valueForKey:COUNTRY_NAME];
    
    NSDictionary* country=[userdefault valueForKey:COUNTRY_NAME];
    return [country valueForKey:COUNTRY_NAME];
    
}




+(NSString*)getCityName{
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    NSDictionary* city=[userdefault valueForKey:CITY_NAME];
    return [city valueForKey:CITY_NAME];
}

+(NSString*)getStateName{
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    NSDictionary* state=[userdefault valueForKey:STATE_NAME];
    return [state valueForKey:STATE_NAME];
}

+(NSNumber*)getCountryID{
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    NSDictionary* country=[userdefault valueForKey:COUNTRY_NAME];
    return [country valueForKey:PLACE_ID];
}
+(NSNumber*)getCityID{
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    NSDictionary* city=[userdefault valueForKey:CITY_NAME];
    return [city valueForKey:PLACE_ID];
}
+(NSNumber*)getStateID{
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    NSDictionary* state=[userdefault valueForKey:STATE_NAME];
    return [state valueForKey:PLACE_ID];
}


+(BOOL)isUserADriver{
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    NSNumber* userType=[userdefault valueForKey:USER_TYPE];
    return [userType boolValue];
}




# pragma mark - Save User Info in NSUserDefault

+ (User*)saveUserInformation:(NSDictionary *)result{
    if([self checkUserData]){
        [self removeUserData];
    }
    User *ui = [[User alloc]init];
    
    ui.userImage = [NSURL URLWithString:[result valueForKey:@"photo"]];
    ui.userImage=[UtilitiesHelper getStringFromObject:[result valueForKey:@"email" ]];
//    ui.userId=[result valueForKey:@"id"];
//    ui.userName=[result valueForKey:@"name"];
//    ui.userPhoneNo=[UtilitiesHelper getStringFromObject:[result valueForKey:@"phone"]];
    ui.dob=[result valueForKey:@"age"];
    ui.gender=[result valueForKey:@"gender"];
    ui.race=[result valueForKey:@"race"];
    ui.userStatus=[UtilitiesHelper getEmptyStringFromObjectIfNull:[result valueForKey:@"status_message"]];
    ui.isPushOn=[result valueForKey:@"notification"];
    ui.distanceRange=[NSNumber numberWithDouble:[[UtilitiesHelper getStringFromObject:[result valueForKey:@"distance"]] doubleValue]];
    ui.latitude=[NSNumber numberWithDouble:[[UtilitiesHelper getStringFromObject:[result valueForKey:@"latitude"]] doubleValue]];
    ui.longitude=[NSNumber numberWithDouble:[[UtilitiesHelper getStringFromObject:[result valueForKey:@"longitude"]]doubleValue]];
    ui.isOnline=[UtilitiesHelper getStringFromObject:[result valueForKey:@"presence"]];
    ui.userThumbImage = [NSURL URLWithString:[result valueForKey:@"photo_thumb"]];
    
    
    //    auth-key (abc-123), full_name,phone,email,password,country,city,type(user,driver),platform,device_type(android,ios), device_token
    
    [self saveUserInfo:ui];
    
    //    [self addUserNotificationSetting];
    
    
    return ui;
}



//+(void)addUserNotificationSetting
//{
//    [[AppServiceModel sharedClient]addUpadateUserNotificationSettingWithUserId:[SignInModel getUserData].userId DeviceToken:@"abc" DeviceType:@"ios" MessageNotification:[NSNumber numberWithInt:1] EmailNotification:[NSNumber numberWithInt:1]  completionBlock:^(NSObject *response) {
//        NSLog(@"%@",response);
//
//    } failureBlock:^(NSError *error) {
//
//    }];
//}



//+(void)updateUserLanguage:(NSString*)userLanguage
//{
//    User *ui = [self getUserData];
//    ui.userLanguage = userLanguage;
//    [self saveUserInfo:ui];
//
//}
//
//+(void)updatePromoCode
//{
//    User *ui = [self getUserData];
//    ui.userPromoCode = @"NA";
//    [self saveUserInfo:ui];
//
//}
//
//+(void)saveCurrency:(NSString*)currency
//{
//    User *ui = [self getUserData];
//    ui.userCurrency = currency;
//    [self saveUserInfo:ui];
//}

+ (void)saveUserInfo:(User *)userinfo{
    
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    NSData *archivedObject = [NSKeyedArchiver archivedDataWithRootObject:userinfo];
    [userdefault setObject:archivedObject forKey:@"userinfo"];
    [userdefault synchronize];
}

+(void)saveCountryName:(NSString*)countryName andCountryID:(NSNumber *)countryId{
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    NSDictionary* country=[[NSDictionary alloc] initWithObjectsAndKeys:countryName,COUNTRY_NAME,countryId,PLACE_ID, nil];
    [userdefault setObject:country forKey:COUNTRY_NAME];
    [userdefault synchronize];
}

+(void)saveCityName:(NSString*)cityName andCityID:(NSNumber *)cityId{
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    NSDictionary* city=[[NSDictionary alloc] initWithObjectsAndKeys:cityName,CITY_NAME,cityId,PLACE_ID, nil];
    [userdefault setObject:city forKey:CITY_NAME];
    [userdefault synchronize];
}

+(void)saveStateName:(NSString*)stateName andStateID:(NSNumber *)stateId{
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    NSDictionary* state=[[NSDictionary alloc] initWithObjectsAndKeys:stateName,STATE_NAME,stateId,PLACE_ID, nil];
    [userdefault setObject:state forKey:STATE_NAME];
    [userdefault synchronize];
}

+(void)saveDeviceToken:(NSString*)deviceToken{
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    [userdefault setObject:deviceToken forKey:DEVICE_TOKEN];
    [userdefault synchronize];
}

+(void)saveDriverType:(BOOL)type{
    NSUserDefaults *userdefault = [NSUserDefaults standardUserDefaults];
    [userdefault setObject:[NSNumber numberWithBool:type] forKey:USER_TYPE];
    [userdefault synchronize];
}

+(void)savePushStatus:(BOOL)status{
    User *ui = [self getUserData];
    
    if(status)
        ui.isPushOn = @"on";
    else
        ui.isPushOn = @"off";
    
    [self saveUserInfo:ui];
}

+(void)saveOnlineStatus:(NSString*)status{
    User *ui = [self getUserData];
    ui.isOnline = status;
    [self saveUserInfo:ui];
}


+(void)saveUserStatus:(NSString*)status{
    User *ui = [self getUserData];
    ui.userStatus = status;
    [self saveUserInfo:ui];
}

+(void)saveDistanceRange:(NSNumber*)range{
    User *ui = [self getUserData];
    ui.distanceRange = range;
    [self saveUserInfo:ui];
}

@end
