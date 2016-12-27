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
#import "SuffixInfo.h"



@interface ShareOneUtility : UtilitiesHelper{
}

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

+(void)saveUserObjectToLocalObjects:(User *)user;
+(NSArray *)getUserObjectsFromLocalObjects;


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

//+(NSString *)getMacForVertifi;

+(NSString *)getMacForVertifiForSuffix:(SuffixInfo *)objSuffixInfo;


+(NSString *)getUUID;

+(NSString *)getSessionnKey;

+(NSString *)getMemberValue;

+(NSString *)getAccountValue;

+(NSString *)getSecretKey;

+(NSString *)getMemberEmail;

+(NSString *)getMemberName;
    



+(void)savedSufficInfoLocally:(NSDictionary *)dict;

+(NSDictionary *)getSuffixInfoSavesLocally;


+(NSString *)getSectionTitleByCode:(NSString *)code;

+(NSString *)getAESEncryptedContexIDInBase64:(NSString *)contexID;
+(NSString *)getAESRandomIVForSSON;

+ (NSString *)encodeToBase64String:(UIImage *)image;

+(NSString *)getAccountTypeWithSuffix:(SuffixInfo *)objSuffixInfo;


+(NSString *)getDeviceType;

+(NSString *)getAccountValueWithSuffix:(SuffixInfo *)suffix;


+(NSDictionary *)getAESObjectWithGeneratedIV:(NSString *)contexID;

+(NSDictionary *)encryptionByFBEncryptorAESWithContextID:(NSString *)contextID;

+(NSString *)getTitleOfMobileDeposit;

+(NSString *)decodeBase64ToStirng:(NSString *)encodedString;

+(void )getSavedObjectOfCurrentLoginUser:(User *)user;

+(void)saveDeviceToken:(NSString *)token;

+(NSString *)getDeiviceToken;

+(NSString *)getDeviceNotifToken;

+(void)saveMenuItemObjectForTouchIDAuthentication:(NSDictionary *)dict;

+(NSDictionary *)getMenuItemForTouchIDAuthentication;



@end
