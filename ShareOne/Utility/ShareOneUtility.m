//
//  ShareOneUtility.m
//  ShareOne
//
//  Created by Qazi Naveed on 20/09/2016.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//
#import <CommonCrypto/CommonHMAC.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "ShareOneUtility.h"
#import <CoreLocation/CoreLocation.h>
#import <CommonCrypto/CommonDigest.h>

#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>

#include <sys/types.h>
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#import "ShareOneUtility.h"
#import "BBAES.h"
#import "ConstantsShareOne.h"
#import "Services.h"
#import "ConstantsShareOne.h"
#import "SAMKeychain.h"
#import "Location.h"
#import "SharedUser.h"



@import GoogleMaps;
@implementation ShareOneUtility

+ (NSArray *)getSideMenuDataFromPlist{
    
    NSArray *arrPlist = nil;
    
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:PLIST_NAME ofType:FILE_TYPE];
    arrPlist = [NSArray arrayWithContentsOfFile:plistPath];
    return   [self manipulateArray:arrPlist];
;
}

+(NSMutableArray *)manipulateArray:(NSArray *)arr{
    
    NSMutableArray *arrayToreturn = [[NSMutableArray alloc] init];
    [arr enumerateObjectsUsingBlock:^(NSArray *arr, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSMutableArray *subCatArray = [[NSMutableArray alloc] init];
        if([arr isKindOfClass:[NSArray class]]){
            NSMutableDictionary *dict = [arr[0] mutableCopy];
            if([[dict valueForKey:SHOULD_SHOW] boolValue]){
                [arrayToreturn addObject:dict];
                
                NSMutableArray *subCatArr = [dict valueForKey:MAIN_CAT_SUB_CATEGORIES] ;
                if([subCatArr isKindOfClass:[NSArray class]]){
                    
                    [subCatArr enumerateObjectsUsingBlock:^(NSDictionary *subCatDict, NSUInteger idx, BOOL * _Nonnull stop) {
                        
                        if([[subCatDict valueForKey:SHOULD_SHOW] boolValue]){
                            [subCatArray addObject:subCatDict];
                        }
                    }];
                    [dict setValue:subCatArray forKey:MAIN_CAT_SUB_CATEGORIES];
                }
            }
        }
    }];
    return arrayToreturn;
}
+(NSMutableArray*)getLocationArray
{
//    //53.4198855,-2.9808854(Liverpool)
//    53.4184578,-3.0030442
//    53.4201264-2.9916392
//    53.4024066,-2.9844725,
//    53.4039417,-2.9808717,
//    53.4035396,-2.9799329
//    53.4027041,-2.9798886
    NSMutableArray *locationArr=[[NSMutableArray alloc] init];
//    [locationArr addObject:@"53.4198855,-2.9808854"];
//    [locationArr addObject:@"53.4184578,-3.0030442"];
//    [locationArr addObject:@"53.4201264,-2.9916392"];
//    [locationArr addObject:@"53.4024066,-2.9844725"];
//    [locationArr addObject:@"53.4039417,-2.9808717"];
//    [locationArr addObject:@"53.4035396,-2.9799329"];
//    [locationArr addObject:@"53.4027041,-2.9798886"];
//    
    [locationArr addObject:@"-117.575323,34.085305"];

    
    


    return locationArr;
}
+ (NSString *) geoCodeUsingAddress:(NSString *)address
{
    double latitude1 = 0, longitude1 = 0;
    
    NSString *esc_addr =  [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true", esc_addr]]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:60.0];
    
    NSURLResponse *response = NULL;
    NSError *requestError = NULL;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:theRequest returningResponse:&response error:&requestError];
    //  NSString *dataString = [[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding] autorelease];
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:responseData //1
                                                                   options:kNilOptions
                                                                     error:&requestError];
    id results = [jsonDictionary objectForKey:@"results"];
    for( id stuff in results )
    {
        //NSDictionary *northeast = [[[stuff objectForKey:@"geometry"] objectForKey:@"bounds"] objectForKey:@"northeast"];
        //NSDictionary *southwest = [[[stuff objectForKey:@"geometry"] objectForKey:@"bounds"] objectForKey:@"southwest"];
        NSDictionary *center4 = [[stuff objectForKey:@"geometry"] objectForKey:@"location"];
        latitude1=[[center4 objectForKey:@"lat"] floatValue];
        longitude1=[[center4 objectForKey:@"lng"] floatValue];
        
    }
    NSLog(@"%f",latitude1);
    NSLog(@"%f",longitude1);
    CLLocationCoordinate2D centers;
    centers.latitude = latitude1;
    centers.longitude = longitude1;
    NSString *CoordinateStr=[NSString stringWithFormat:@"%f,%f",centers.latitude,centers.longitude];
    return CoordinateStr;
}
+(NSString *)getDistancefromAdresses:(NSString *)source Destination:(NSString *)Destination
{
    NSString *urlPath = [NSString stringWithFormat:@"/maps/api/distancematrix/json?origins=%@&destinations=%@&mode=driving&language=en-EN&sensor=false",source ,Destination ];
    NSURL *url = [[NSURL alloc]initWithScheme:@"https" host:@"maps.googleapis.com" path:urlPath];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
    [request setURL:url];
    [request setHTTPMethod:@"GET"];
    
    NSURLResponse *response ;
    NSError *error;
    NSData *data;
    data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    NSMutableDictionary *jsonDict= (NSMutableDictionary*)[NSJSONSerialization  JSONObjectWithData:data options:kNilOptions error:&error];
    NSMutableDictionary *newdict=[jsonDict valueForKey:@"rows"];
    NSArray *elementsArr=[newdict valueForKey:@"elements"];
    if([elementsArr count]!=0)
    {
        NSArray *arr=[elementsArr objectAtIndex:0];
        NSDictionary *dict=[arr objectAtIndex:0];
        NSMutableDictionary *distanceDict=[dict valueForKey:@"distance"];
        NSLog(@"distance:%@",[distanceDict valueForKey:@"text"]);
        return [distanceDict valueForKey:@"text"];

    }
    return [jsonDict valueForKey:@"status"];
}
+ (NSArray *)getDummyDataForQB{
    
    
    NSArray *tranDetailArr = [NSArray arrayWithObjects:
                    [NSDictionary dictionaryWithObjectsAndKeys:@"Transaction 1",@"tran_title",@"MM/DD/YYYY",@"tran_date",@"$100.00",@"tran_amt", nil],
                    [NSDictionary dictionaryWithObjectsAndKeys:@"Transaction 2",@"tran_title",@"MM/DD/YYYY",@"tran_date",@"$300.00",@"tran_amt", nil],
                    [NSDictionary dictionaryWithObjectsAndKeys:@"Transaction 3",@"tran_title",@"MM/DD/YYYY",@"tran_date",@"$200.00",@"tran_amt", nil],
                    [NSDictionary dictionaryWithObjectsAndKeys:@"Transaction 4",@"tran_title",@"MM/DD/YYYY",@"tran_date",@"$100.00",@"tran_amt", nil]
                    , nil];
    
    
    return [NSArray arrayWithObjects:
            [NSDictionary dictionaryWithObjectsAndKeys:@"Share",@"section_title",@"$157.50",@"section_amt",tranDetailArr,@"section_details", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"Checking",@"section_title",@"$23157.50",@"section_amt",tranDetailArr,@"section_details", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"Home Loan",@"section_title",@"$14872.14",@"section_amt",tranDetailArr,@"section_details", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"Car Loan",@"section_title",@"$1347.20",@"section_amt",tranDetailArr,@"section_details", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"Medical Loan",@"section_title",@"$4745.32",@"section_amt",tranDetailArr,@"section_details", nil]
            ,nil];
}

+(int)getTimeStamp{
    return [[NSDate date] timeIntervalSince1970];
//    return 1477986029;
}


+(NSString *)createSignatureWithTimeStamp:(int)timestamp andRequestType:(NSString *)request_type havingEncoding:(NSStringEncoding) encoding{
    
    NSString *stringToSignIn = [NSString stringWithFormat:@"%@\n%d\n%@\n%@\n%@",PUBLIC_KEY,timestamp,SECURITY_VERSION,request_type,H_MAC_TYPE];
//    NSLog(@"stringToSignIn : \n%@",stringToSignIn);
    return  [self getHMACSHAWithSignature:stringToSignIn andEncoding:encoding];
//    [self applyEncriptionWithPrivateKey:PRIVATE_KEY andPublicKey:PUBLIC_KEY];
}

+(NSString *)getHMACSHAWithSignature:(NSString *)signature andEncoding:(NSStringEncoding )encoding{
    
    
    const char *cKey  = [PRIVATE_KEY cStringUsingEncoding:encoding];
    const char *cData = [signature cStringUsingEncoding:encoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMACData = [NSData dataWithBytes:cHMAC length:sizeof(cHMAC)];
    return [self getBase64ValueWithObject:HMACData];
}

+ (NSString *)getBase64ValueWithObject:(NSData *)hmac_sha_data{
    return [hmac_sha_data base64EncodedStringWithOptions:0];
}

+(void)applyEncriptionWithPrivateKey:(NSString *)private_key andPublicKey:(NSString *)public_key{
    
    NSData* salt = [BBAES randomDataWithLength:BBAESSaltDefaultLength];
    NSData *key = [BBAES keyBySaltingPassword:private_key salt:salt keySize:BBAESKeySize256 numberOfIterations:BBAESPBKDF2DefaultIterationsCount];
    
    
    NSString *secretMessage = private_key;
    NSLog(@"Original message: %@", secretMessage);
    
    NSString *encryptedString = [secretMessage bb_AESEncryptedStringForIV:[BBAES randomIV] key:key options:BBAESEncryptionOptionsIncludeIV];
    NSLog(@"Encrypted message: %@", encryptedString);
    
    NSString *decryptedMessage = [encryptedString bb_AESDecryptedStringForIV:nil key:key];
    NSLog(@"Decrypted message: %@", decryptedMessage);
}

+ (NSString *)getAESRandom4WithSecretKey:(NSString *)secret_key AndPublicKey:(NSString *)public_key{
    
    NSData *datRow=[BBAES IVFromString:secret_key];
    return  [self hexStringFromData:datRow];
}

+ (NSString *) hexStringFromData:(NSData *)data
{
    NSUInteger bytesCount = data.length;
    if (bytesCount) {
        const char *hexChars = "0123456789ABCDEF";
        const unsigned char *dataBuffer = data.bytes;
        char *chars = malloc(sizeof(char) * (bytesCount * 2 + 1));
        char *s = chars;
        for (unsigned i = 0; i < bytesCount; ++i) {
            *s++ = hexChars[((*dataBuffer & 0xF0) >> 4)];
            *s++ = hexChars[(*dataBuffer & 0x0F)];
            dataBuffer++;
        }
        *s = '\0';
        NSString *hexString = [NSString stringWithUTF8String:chars];
        free(chars);
        return hexString;
    }
    return @"";
}

+ (NSString *)getAuthHeaderWithRequestType:(NSString *)request_type{
    
//    string AuthorizationHeader = AesGeneratedIV + "|" + KeyPublic + "||" + unixTS.ToString() + "|" + Signature;
    //dcf421cc2be61068888b2b2b4dd3ca5a
    NSString *generatedIv =[self getAESRandom4WithSecretKey:PRIVATE_KEY AndPublicKey:PUBLIC_KEY];
//    NSLog(@"generatedIv :%@",generatedIv);
    NSString *header = [NSString stringWithFormat:@"%@|%@||%d|%@",generatedIv,PUBLIC_KEY,[self getTimeStamp],[self createSignatureWithTimeStamp:[self getTimeStamp] andRequestType:request_type havingEncoding:NSUTF8StringEncoding]];
    return header;
}

+ (void)showProgressViewOnView:(UIView *)view{
    [MBProgressHUD showHUDAddedTo:view animated:YES];
}

+(void)hideProgressViewOnView:(UIView *)view{
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        // Do something...
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:view animated:YES];
        });
    });
}



+(void)saveUserObject:(User *)user{
    
    NSData *archivedObject = [NSKeyedArchiver archivedDataWithRootObject:user];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:archivedObject forKey:[NSString stringWithFormat:@"%@",USER_KEY]];
    [defaults synchronize];
}

+(User *)getUserObject{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *archivedObject = [defaults objectForKey:USER_KEY];
    return  (User *)[NSKeyedUnarchiver unarchiveObjectWithData:archivedObject];
}

+(void)saveUserObjectToLocalObjects:(User *)user{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    __block User *userFound = nil;
    
    NSMutableArray *existingUsers = [[self getUserObjectsFromLocalObjects] mutableCopy];
    if(!existingUsers)
        existingUsers = [[NSMutableArray alloc] init];
    
    [existingUsers enumerateObjectsUsingBlock:^(NSData *objArchiveData, NSUInteger idx, BOOL * stop) {
        User *saveedUser = (User *)[NSKeyedUnarchiver unarchiveObjectWithData:objArchiveData];
        if([[saveedUser Account] intValue]==[[user Account] intValue]){
            userFound=saveedUser;
            *stop=TRUE;
        }
    }];
    
    
    if(userFound){
        
        // User exist in Local DB
        NSLog(@"USER EXIST");
        [self copySettingsOfSavedUserToNewLoginInfo:user AndOldUser:userFound];
        
        //swaping old to new object
        //userFound = user;
        user = userFound;
        
//        [[SharedUser sharedManager] setUserObject:user];

        [self saveUserObject:user];
        
    }
    else{
        
        // New User
        
        [self setDefaultSettngOnUser:user];
        NSData *archivedObject = [NSKeyedArchiver archivedDataWithRootObject:user];
        [existingUsers addObject:archivedObject];
        
        [self saveUserObject:user];

    }
    
    [defaults setObject:existingUsers forKey:ALL_USER_OBJECTS];
    
    [defaults synchronize];


}


+(void)setDefaultSettngOnUser:(User *)user{
    
    user.isPushNotifOpen=TRUE;
    user.isShowOffersOpen=TRUE;
    user.isQBOpen=TRUE;
    
}
+(NSArray *)getUserObjectsFromLocalObjects{
    

    NSArray *user=(NSArray *) [[NSUserDefaults standardUserDefaults]valueForKey:ALL_USER_OBJECTS];
    return user;
}


+(void )getSavedObjectOfCurrentLoginUser:(User *)user{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSMutableArray *userArr=[(NSMutableArray *) [[NSUserDefaults standardUserDefaults]valueForKey:ALL_USER_OBJECTS] mutableCopy];
    
    
    [userArr enumerateObjectsUsingBlock:^(NSData *objArchiveData, NSUInteger idx, BOOL * stop) {
        User *saveedUser = (User *)[NSKeyedUnarchiver unarchiveObjectWithData:objArchiveData];
        if([[saveedUser Account] intValue]==[[user Account] intValue]){
            
            NSData *archivedObject = [NSKeyedArchiver archivedDataWithRootObject:user];

            [userArr replaceObjectAtIndex:idx withObject:archivedObject];
            
            [self saveUserObject:user];
        }
        
        
    }];

    [defaults setObject:userArr forKey:ALL_USER_OBJECTS];
    
    [defaults synchronize];

}

+(void)savedSufficInfoLocally:(NSDictionary *)dict{
    
    [[NSUserDefaults standardUserDefaults] setValue:dict forKey:@"sufficInfo"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSDictionary *)getSuffixInfoSavesLocally{
  return (NSDictionary *) [[NSUserDefaults standardUserDefaults] valueForKey:@"sufficInfo"];
}

+(void)copySettingsOfSavedUserToNewLoginInfo:(User *)newUser AndOldUser:(User *)savedUser{
    newUser.isPushNotifOpen=savedUser.isPushNotifOpen;
    newUser.isQBOpen=savedUser.isQBOpen;
    newUser.isShowOffersOpen=savedUser.isShowOffersOpen;
    newUser.isTouchIDOpen=savedUser.isTouchIDOpen;
}


+(UIImage *)getImageInLandscapeOrientation:(UIImage *)img{
    
    UIImage *imageToDisplay =
    [UIImage imageWithCGImage:[img CGImage]
                        scale:[img scale]
                  orientation: UIImageOrientationDown];
    return imageToDisplay;
}



+ (void)setUserRememberedStatusWithBool:(BOOL)isRemember{
    
    [[NSUserDefaults standardUserDefaults] setBool:isRemember forKey:@"isLoginRemembered"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}
+ (BOOL)isUserRemembered{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"isLoginRemembered"];
}


+ (void)setTouhIDStatusWithBool:(BOOL)isRemember{
    
    [[NSUserDefaults standardUserDefaults] setBool:isRemember forKey:TOUCH_ID_SETTINGS];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

+ (BOOL)isTouchIDEnabled{
    return [[NSUserDefaults standardUserDefaults] boolForKey:TOUCH_ID_SETTINGS];
}

+(void)savaLogedInSignature:(NSString *)signature{
    [[NSUserDefaults standardUserDefaults] setValue:signature forKey:@"Signature"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

+(NSString *)getSignedINSignature{
   return  [[NSUserDefaults standardUserDefaults] valueForKey:@"Signature"];
}


+ (BOOL)getSettingsWithKey:(NSString *)key{
    
    BOOL flag ;
    User *user = [self getUserObject];
    if(user){
        
        if([key isEqualToString:PUSH_NOTIF_SETTINGS])
            flag= user.isPushNotifOpen;
        else if ([key isEqualToString:QUICK_BAL_SETTINGS])
            flag = user.isQBOpen;
        else if ([key isEqualToString:TOUCH_ID_SETTINGS])
            flag= user.isTouchIDOpen;
        else if([key isEqualToString:SHOW_OFFERS_SETTINGS])
            flag= user.isShowOffersOpen;
    }
    return flag;
    
//    return [[NSUserDefaults standardUserDefaults] boolForKey:key];
}

+ (void)saveSettingsWithStatus:(BOOL)flag AndKey:(NSString *)key{
    
    
    User *user = [self getUserObject];
    
    if([key isEqualToString:PUSH_NOTIF_SETTINGS])
         user.isPushNotifOpen=flag;
    else if ([key isEqualToString:QUICK_BAL_SETTINGS])
          user.isQBOpen=flag;
    else if ([key isEqualToString:TOUCH_ID_SETTINGS])
         user.isTouchIDOpen=flag;
    else if([key isEqualToString:SHOW_OFFERS_SETTINGS])
        user.isShowOffersOpen=flag;

    
    [self getSavedObjectOfCurrentLoginUser:user];

//    [[NSUserDefaults standardUserDefaults] setBool:flag forKey:key];
//    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *) randomStringWithLength: (int) len {
    
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform([letters length])]];
    }
    
    return randomString;
}

+ (NSString *)generateBoundaryString
{
    return [NSString stringWithFormat:@"Boundary-%@", [[NSUUID UUID] UUIDString]];
    
    // if supporting iOS versions prior to 6.0, you do something like:
    //
    // // generate boundary string
    // //
    // adapted from http://developer.apple.com/library/ios/#samplecode/SimpleURLConnections
    //
    // CFUUIDRef  uuid;
    // NSString  *uuidStr;
    //
    // uuid = CFUUIDCreate(NULL);
    // assert(uuid != NULL);
    //
    // uuidStr = CFBridgingRelease(CFUUIDCreateString(NULL, uuid));
    // assert(uuidStr != NULL);
    //
    // CFRelease(uuid);
    //
    // return uuidStr;
}

+ (NSData *)createBodyWithBoundary:(NSString *)boundary
                        parameters:(NSDictionary *)parameters
{
    NSMutableData *httpBody = [NSMutableData data];
    
    // add params (all params are strings)
    
    [parameters enumerateKeysAndObjectsUsingBlock:^(NSString *parameterKey, NSString *parameterValue, BOOL *stop) {
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", parameterKey] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"%@\r\n", parameterValue] dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    
    [httpBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return httpBody;
}

+(void)setDefaultSettingValues{
    
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:QUICK_BAL_SETTINGS];
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:SHOW_OFFERS_SETTINGS];
//    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:TOUCH_ID_SETTINGS];
//    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:RETINA_SCAN_SETTINGS];
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:PUSH_NOTIF_SETTINGS];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

+(void)setPreferencesOnLaunch{
    
    
    
    User *user = [self getUserObject];
    if(user){
        
    }
    else{
        
    }
    
    NSString *key = [[NSUserDefaults standardUserDefaults] valueForKey:@"FIRST_LAUNCH"];
    if(!key){
        [self setDefaultSettingValues];
        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"FIRST_LAUNCH"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
        
}

+(NSString *)getSessionnKey{
    return @"Klko4DmW3CAW2oJai4Iz1TUyD3YiR4V8wv5o89SHYDSq29rTmnNfcCtoGaxakbMXOKNvPZ97AoNFUx9m";
//    return [self randomStringWithLength:80];

}

+(NSString *)getSecretKey{
    return KEY_VALUE_2;
}

+(NSString *)getMemberValue{
    return @"666";
//    return [self randomStringWithLength:16];
}

+(NSString *)getAccountValue{
    
    // account number + suffix[000 00000]
    return @"66655078";
//    return [self randomStringWithLength:17];
}


+(NSString *)getMemberEmail{
    
    return @"ggwyn@shareone.com";
}

+(NSString *)getMemberName{
    
    return @"Louis Uncommon";
}
+ (NSString *)applyMD5OnValue:(NSString *)value{
    
    const char* str = [value UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

+ (NSString*)MD5onData:(NSData *)data
{
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(data.bytes, data.length, md5Buffer);
    
    // Convert unsigned char buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}

+(NSString *)getMacForVertifi{
    
    NSString *hex = nil;

    NSString *mac=[NSString stringWithFormat:@"%@%@%d%@%@%@",REQUESTER_VALUE,[self getSessionnKey],[self getTimeStamp],ROUTING_VALUE,[self getMemberValue],[self getAccountValue]];
    
    NSLog(@"MAC : %@  Key : %@",mac,[self getSecretKey]);
    
    
   hex = [self HMACWithSecret:[self getSecretKey] AndData:mac];
    
    NSLog(@"Encrypted MAC : %@ ",hex);

    
    return hex;
}

+ (NSString*) HMACWithSecret:(NSString*) secret AndData:(NSString *)data
{
    
    CCHmacContext    ctx;
//    const char       *key = [secret UTF8String];
//    const char       *str = [data UTF8String];
    
    const char       *key = [secret cStringUsingEncoding:NSASCIIStringEncoding];
    const char       *str = [data cStringUsingEncoding:NSASCIIStringEncoding];

    unsigned char    mac[CC_MD5_DIGEST_LENGTH];
    char             hexmac[2 * CC_MD5_DIGEST_LENGTH + 1];
    char             *p;
    
    CCHmacInit( &ctx, kCCHmacAlgMD5, key, strlen( key ));
    CCHmacUpdate( &ctx, str, strlen(str) );
    CCHmacFinal( &ctx, mac );
    
    p = hexmac;
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++ ) {
        snprintf( p, 3, "%02x", mac[ i ] );
        p += 2;
    }
    
    return [NSString stringWithUTF8String:hexmac];
     
//    NSData *keyData = [secret dataUsingEncoding:NSASCIIStringEncoding];
//    NSData *dataData = [data dataUsingEncoding:NSASCIIStringEncoding];
//    NSMutableData *hash = [NSMutableData dataWithLength:CC_MD5_DIGEST_LENGTH];
//    CCHmac(kCCHmacAlgMD5, keyData.bytes, keyData.length , dataData.bytes, dataData.length, hash.mutableBytes);
//    
//    NSString *string = [[NSString alloc] initWithData:hash encoding:NSASCIIStringEncoding] ;
//    NSLog(@"hash: %@", string);
//
//    return string;


}

+(NSString *)convertStringToASCIIEncoding:(NSString *)sourceString{
    
    NSData *asciiData = [sourceString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *asciiString = [[NSString alloc] initWithData:asciiData encoding:NSASCIIStringEncoding];
    
    return asciiString;

}

+(void)getBytesOfString:(NSString *)string{
    NSData* data=[string dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger myLength = data.length;
    NSLog(@"getBytesOfString : %d",data.length);
}

+(NSData*) calculateHMACMD5WithKey:(NSString*) key andData:(NSString*) data{
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char cHMAC[CC_MD5_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgMD5, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    return [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    
}

+(NSString *)getUUID{
    
    NSString *Appname = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    NSString *deviceID = [SAMKeychain passwordForService:Appname account:@""];
    if (deviceID == nil)
    {
        deviceID  = [[[UIDevice currentDevice]identifierForVendor] UUIDString];
        [SAMKeychain setPassword:deviceID forService:Appname account:@""];
    }
    
    return deviceID;
}
+(NSString *)getLocationStatusWithObject:(Location *)location{
    
    NSString *status =nil;
    
    return status;
}

+(NSString *)getSectionTitleByCode:(NSString *)code{
    
    NSString *formatedString = nil;
    
    if([code isEqualToString:@"S"] || [code isEqualToString:@"s"]){
        formatedString = @"Share";
    }
    else if([code isEqualToString:@"L"] || [code isEqualToString:@"l"]){
        formatedString = @"Loan";
    }
    else if([code isEqualToString:@"C"]|| [code isEqualToString:@"c"]){
        formatedString=@"Certificate";
    }
    else if([code isEqualToString:@"V"]|| [code isEqualToString:@"v"]){
        formatedString=@"Internal credit card";
    }
    else if([code isEqualToString:@"T"] || [code isEqualToString:@"t"]){
        formatedString=@"External credit card";
    }
    else if([code isEqualToString:@"M"] || [code isEqualToString:@"m"]){
        formatedString=@"External Mortgage";
    }
    return formatedString;
}

+(NSString *)getAESEncryptedContexIDInBase64:(NSString *)contexID{
   return  [self getHMACSHAWithSignature:contexID andEncoding:NSUTF8StringEncoding];
}

+(NSString *)getAESRandomIVForSSON{
     return [self getAESRandom4WithSecretKey:PRIVATE_KEY AndPublicKey:PUBLIC_KEY];
}
@end
