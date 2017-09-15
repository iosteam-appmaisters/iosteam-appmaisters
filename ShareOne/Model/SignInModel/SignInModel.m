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
    ui.dob=[result valueForKey:@"age"];
    ui.Gender=[result valueForKey:@"gender"];
    ui.Race=[result valueForKey:@"race"];
    ui.userStatus=[UtilitiesHelper getEmptyStringFromObjectIfNull:[result valueForKey:@"status_message"]];
    ui.isPushOn=[result valueForKey:@"notification"];
    ui.distanceRange=[NSNumber numberWithDouble:[[UtilitiesHelper getStringFromObject:[result valueForKey:@"distance"]] doubleValue]];
    ui.latitude=[NSNumber numberWithDouble:[[UtilitiesHelper getStringFromObject:[result valueForKey:@"latitude"]] doubleValue]];
    ui.longitude=[NSNumber numberWithDouble:[[UtilitiesHelper getStringFromObject:[result valueForKey:@"longitude"]]doubleValue]];
    ui.isOnline=[UtilitiesHelper getStringFromObject:[result valueForKey:@"presence"]];
    ui.userThumbImage = [NSURL URLWithString:[result valueForKey:@"photo_thumb"]];

    [self saveUserInfo:ui];
    
    return ui;
}

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
