//
//  ShareOneUtility.h
//  ShareOne
//
//  Created by Qazi Naveed on 20/09/2016.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UtilitiesHelper.h"
#import "User.h"



@interface ShareOneUtility : UtilitiesHelper

+ (NSArray *)getSideMenuDataFromPlist;
+ (NSArray *)getDummyDataForQB;
+ (NSMutableArray*)getLocationArray;

+(int)getTimeStamp;


+ (NSString *)createSignatureWithTimeStamp:(int)timestamp andRequestType:(NSString *)request_type havingEncoding:(NSStringEncoding) encoding;

+ (NSString *)getAESRandom4WithSecretKey:(NSString *)secret_key AndPublicKey:(NSString *)public_key;


+ (NSString *)getAuthHeaderWithRequestType:(NSString *)request_type;


+(NSString *)getDistancefromAdresses:(NSString *)source Destination:(NSString *)Destination;

+(NSString *) geoCodeUsingAddress:(NSString *)address;

+ (void)showProgressViewOnView:(UIView *)view;
+ (void)hideProgressViewOnView:(UIView *)view;


+(void)saveUserObject:(User *)user;
+(User *)getUserObject;


+ (void)setUserRememberedStatusWithBool:(BOOL)isRemember;
+ (BOOL)isUserRemembered;


+ (void)setTouhIDStatusWithBool:(BOOL)isRemember;
+ (BOOL)isTouchIDEnabled;

+(void)savaLogedInSignature:(NSString *)signature;
+(NSString *)getSignedINSignature;

+ (BOOL)getSettingsWithKey:(NSString *)key;
+ (void)saveSettingsWithStatus:(BOOL)flag AndKey:(NSString *)key;

+(UIImage *)getImageInLandscapeOrientation:(UIImage *)img;

+ (NSString *) randomStringWithLength: (int) len;


+ (NSString *)generateBoundaryString;

+ (NSData *)createBodyWithBoundary:(NSString *)boundary parameters:(NSDictionary *)parameters;

+(void)setDefaultSettingValues;
+(void)setPreferencesOnLaunch;

+(NSString *)getMacForVertifi;

+(NSString *)getUUID;





@end