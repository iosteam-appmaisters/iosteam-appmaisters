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
#import "Configuration.h"


@interface ShareOneUtility : UtilitiesHelper{
}

+ (NSArray *)getSideMenuDataFromPlist;
+ (NSArray *)getDummyDataForQB;
+ (NSMutableArray*)getLocationArray;




+(int)getTimeStamp;


+ (NSString *)createSignatureWithTimeStamp:(int)timestamp andRequestType:(NSString *)request_type havingEncoding:(NSStringEncoding) encoding;

+ (NSString *)getAESRandom4WithSecretKey:(NSString *)secret_key AndPublicKey:(NSString *)public_key;


+ (NSString *)getAuthHeaderWithRequestType:(NSString *)request_type;



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

+(NSString*)getMacWithSuffix:(SuffixInfo*)objSuffixInfo currentTimeStamp:(int)timeStamp;

+(NSString *)getMacForVertifiForSuffix:(SuffixInfo *)objSuffixInfo;


+(NSString *)getUUID;

+(NSString *)getSessionnKey;

+(NSString *)getMemberValue;

+(NSString *)getAccountValue;

//+(NSString *)getSecretKey;

+(NSString *)getMemberEmail;

+(NSString *)getMemberName;
    



+(void)savedQBHeaderInfo:(NSDictionary *)dict;

+(NSDictionary *)getQBHeaderInfo;


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


+(void)savedSuffixInfo:(NSDictionary *)dict;
+(NSDictionary *)getSuffixInfo;


+(void)savedDevicesInfo:(NSDictionary *)dict;
+(NSDictionary *)getDevicesInfo;

+(void)removeCacheControllerName;



+(int)getDayOfWeek;

+(NSString *)getDateInCustomeFormatWithSourceDate:(NSString *)sourceDate andDateFormat:(NSString *)dateFormater;

+ (void)setTerminateState:(BOOL)isTerminated;

+ (BOOL)isTerminated;

+(NSMutableDictionary *)eliminateNullValuesFromDictionary:(NSDictionary *)dict parentDictionaryKey:(NSString *)key;

+(void)showProgressOnLoginViewForReAuthentication:(UIView *)view;

//+ (void)setStatusOfPasswordChanged:(BOOL)isComingFromPasswordChanged;
//
//+ (BOOL)isComingFromPasswordChanged;

+(UIImage *)getImageFromBase64String:(NSString *)base64String;

+(NSDictionary *)makeContactsWithProfileLink:(NSString *)link AndNickName:(NSString *)nickName;

+(NSString *)getFavouriteContactProfileLinkWithObject:(NSDictionary *)dict;
+(NSString *)getFavouriteContactNickNameWithObject:(NSDictionary *)dict;

+(NSMutableArray *)getFavContactsForUser:(User *)user;+(void)saveContactsForUser:(User *)user withArray:(NSMutableArray *)array;

+ (void)setAccesoryViewForTextFeild:(UITextField *)textFeld WithDelegate:(id)delegate AndSelecter:(NSString *)selectorString;

+(void)changeToExistingUser:(User *)user;

+(NSString *)parseCustomErrorObject:(NSString *)customError forKey:(NSString *)key;

+(NSDictionary *)getAccountSummaryObjectFromPlist;

+(NSDictionary *)getMobileDepositObjectFromPlist;
+(NSArray *)getFilterSuffixArray:(NSArray *)sourceSuffixArray;

+(Configuration *)getConfigurationFile;

//+(NSString *)getRequesterValue;
//+(NSString *)getRoutingValue;
+(NSString *)getGoogleMapKey;
+(NSString *)getCoOpID;
+(NSString *)getTestFairyID;
+(NSString *)getBaseUrl;
+(NSString *)getSSOBaseUrl;
+(NSString *)getSSOSecretKey;
+(NSString *)getCreditUnionPublicKey;
+(NSString *)getCreditUnionPrivateKey;
+(NSString *)getSecurityVersion;
+(NSString *)getHMACType;
+(NSString *)getGoogleMapKey_old;

+(BOOL)hasShownTutorialsBefore;
+(NSString*)getApplicationVersion;
+ (void)saveVersionNumber:(NSString *)version;
+(NSString*)getVersionNumber;

+(NSString *)getCustomerId;


+(void)writeDataToPlistFileWithJSON:(NSDictionary *)jsonDict AndFileName:(NSString *)fileName;

+(NSString *)getDocumentsDirectoryPathWithFileName:(NSString *)plistName;

+ (BOOL)shouldCallNSConfigServices;

+ (void)saveDateForNSConfigAPI;

+ (NSString *)getDateForNSConfigAPI;

+ (void)configDataSaved;
+ (NSString *)isConfigDataSaved;
+ (BOOL)isConfigDataNotExistedOrReSkinSettingIsOn;
+ (BOOL)shouldUseProductionEnviroment;
+ (NSString *)getClientApplicationID;
+(NSString*)getNavBarTitle:(NSString*)title;
+(NSString *)checkHTTPComponentInURL:(NSString*)url;
+(NSString*)checkLastSlashInURL:(NSString*)url;

+(void)convertDicToJSON:(NSDictionary*)contentDictionary;
+(NSString*)getNumberOfQuickViewTransactions;
+(NSString*)getTechnicalLogoutMessage;

@end
