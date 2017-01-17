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
#import "NSString+MD5String.h"
#import "ShareOneUtility.h"
#import "BBAES.h"
#import "ConstantsShareOne.h"
#import "Services.h"
#import "ConstantsShareOne.h"
#import "SAMKeychain.h"
#import "Location.h"
#import "SharedUser.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonDigest.h>
#import <Security/Security.h>
#import "SuffixInfo.h"
#import "FBEncryptorAES.h"
#import "NSData+Base64.h"
#import "MobileDepositController.h"


static const char encodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

#define LOGGING_FACILITY(X, Y)	\
if(!(X)) {			\
NSLog(Y);		\
}

#define LOGGING_FACILITY1(X, Y, Z)	\
if(!(X)) {				\
NSLog(Y, Z);		\
}






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


+(NSDictionary *)getAccountSummaryObjectFromPlist{
    
    NSDictionary *accountSummaryDict = nil;
    NSArray *plsitArr =[self getSideMenuDataFromPlist];
    if([plsitArr count]>0)
        accountSummaryDict = plsitArr[0];
    
    return accountSummaryDict;
    
}
+(NSString *)getTitleOfMobileDeposit{
    NSString *title = nil;
    
    NSArray * array = [self getSideMenuDataFromPlist];
    
    NSPredicate *depositTitlePredicate = [NSPredicate predicateWithFormat: @"SELF[%@] CONTAINS %@",CONTROLLER_NAME,NSStringFromClass([MobileDepositController class])];
    
    NSArray *filteredArr = [array filteredArrayUsingPredicate:depositTitlePredicate];
    
    if([filteredArr count]>0){
        NSDictionary * depositControllerDict = filteredArr[0];
        title = [[depositControllerDict valueForKey:SUB_CAT_CONTROLLER_TITLE] capitalizedString];
    }
    
    return title;
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
    return  [self getHMACSHAWithSignature:stringToSignIn andEncoding:encoding AndKey:PRIVATE_KEY];
//    [self applyEncriptionWithPrivateKey:PRIVATE_KEY andPublicKey:PUBLIC_KEY];
}



+(NSDictionary *)applyEncriptionWithPrivateKey:(NSString *)private_key andPublicKey:(NSString *)public_key{
    
    
    
    NSString *string= public_key;
    NSRange fullRange;
    fullRange.length = [string length];
    fullRange.location = 0;
    
    uint8_t buffer[[string length]];
    
    [string getBytes:&buffer maxLength:[string length] usedLength:NULL encoding:NSUTF8StringEncoding options:0 range:fullRange remainingRange:NULL];
    
    NSData *plainText = [NSData dataWithBytes:buffer length:[string length]];
    
    NSData *keyData =[private_key hexToBytes];
    
    NSString* myString;
    myString = [[NSString alloc] initWithData:keyData encoding:NSASCIIStringEncoding];


    
    
    
    
    NSData *genIV = [BBAES randomIV] ;
    
    
    NSString *result = [BBAES encryptedStringFromData:plainText IV:genIV key:keyData options:BBAESEncryptionOptionsIncludeIV];
    
    NSLog(@"BBAES : %@",result);
    
    NSString * genratedIV = [self hexStringFromData:genIV];
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:result,@"EncryptedContextID",genratedIV,@"EncryptionIV", nil];
    
    return dict;
    
    NSString *secretMessage = private_key;

    NSData* salt = [BBAES randomDataWithLength:BBAESSaltDefaultLength];
    NSData *key = [BBAES keyBySaltingPassword:private_key salt:salt keySize:BBAESKeySize256 numberOfIterations:BBAESPBKDF2DefaultIterationsCount];

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

+(void)showProgressOnLoginViewForReAuthentication:(UIView *)view{
    MBProgressHUD *hud =  [MBProgressHUD showHUDAddedTo:view animated:YES];
    [hud.label setText:@"Please wait, we are Re-authenticating"];
    [hud.detailsLabel setText:@"As your session has been expired."];
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
//        NSLog(@"USER EXIST");
        [self copySettingsOfSavedUserToNewLoginInfo:user AndOldUser:userFound];
        NSMutableArray *contactsArr = user.favouriteContactsArray;
        //swaping old to new object
        //userFound = user;
        user = userFound;
        user.favouriteContactsArray=contactsArr;

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
    
    user.isPushNotifOpen=FALSE;
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
            *stop=TRUE;
        }
        
    }];

    [defaults setObject:userArr forKey:ALL_USER_OBJECTS];
    
    [defaults synchronize];

}

+(void)savedQBHeaderInfo:(NSDictionary *)dict{
    
    NSDictionary *notNullValuesDict = [self eliminateNullValuesFromDictionary:dict parentDictionaryKey:@"Suffixes"];
    
    [[NSUserDefaults standardUserDefaults] setValue:notNullValuesDict forKey:@"qb_header_info"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSDictionary *)getQBHeaderInfo{
  return (NSDictionary *) [[NSUserDefaults standardUserDefaults] valueForKey:@"qb_header_info"];
}

+(void)savedSuffixInfo:(NSDictionary *)dict{
    
    NSDictionary *notNullValuesDict = [self eliminateNullValuesFromDictionary:dict parentDictionaryKey:@"Suffixes"];
    [[NSUserDefaults standardUserDefaults] setValue:notNullValuesDict forKey:@"suffix_info"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSDictionary *)getSuffixInfo{
    return (NSDictionary *) [[NSUserDefaults standardUserDefaults] valueForKey:@"suffix_info"];
}

+(void)savedDevicesInfo:(NSDictionary *)dict{
    
    NSDictionary *notNullValuesDict = [self eliminateNullValuesFromDictionary:dict parentDictionaryKey:@"MemberDevices"];

    [[NSUserDefaults standardUserDefaults] setValue:notNullValuesDict forKey:@"deveices_info"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSDictionary *)getDevicesInfo{
    return (NSDictionary *) [[NSUserDefaults standardUserDefaults] valueForKey:@"deveices_info"];
}

+(void)copySettingsOfSavedUserToNewLoginInfo:(User *)newUser AndOldUser:(User *)savedUser{
    newUser.isPushNotifOpen=savedUser.isPushNotifOpen;
    newUser.isQBOpen=savedUser.isQBOpen;
    newUser.isShowOffersOpen=savedUser.isShowOffersOpen;
    newUser.isTouchIDOpen=savedUser.isTouchIDOpen;
//    newUser.favouriteContactsArray=savedUser.favouriteContactsArray;

    
    //swap contexid
    savedUser.Contextid=newUser.Contextid;
//    savedUser.favouriteContactsArray=newUser.favouriteContactsArray;

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
    else if([key isEqualToString:VERTIFI_AGREEMANT_KEY])
        user.hasUserAcceptedVertifiAgremant=flag;
    else if([key isEqualToString:NOTIFICATION_SETTINGS_UPDATION])
        user.hasUserUpdatedNotificationSettings=flag;
    else if([key isEqualToString:TOUCH_ID_SETTINGS_UPDATION])
        user.hasUserUpdatedTouchIDSettings=flag;

    
    
    
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
    
    
    // add image data
    NSData *imageDataJPG = [parameters valueForKey:@"imageColor"];
    if (imageDataJPG) {
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.jpg\"\r\n", @"imageColor"] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:imageDataJPG];
        [httpBody appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    
    NSData *imageDataPNG = [parameters valueForKey:@"image"];
    if (imageDataPNG) {
        [httpBody appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"image.png\"\r\n", @"image"] dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [httpBody appendData:imageDataPNG];
        [httpBody appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }

    
    [httpBody appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSMutableDictionary *dict = [parameters mutableCopy];
    [dict removeObjectForKey:@"image"];
    [dict removeObjectForKey:@"imageColor"];

    
    return httpBody;
}

+(void)setDefaultSettingValues{
    
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:QUICK_BAL_SETTINGS];
    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:SHOW_OFFERS_SETTINGS];
//    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:TOUCH_ID_SETTINGS];
//    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:RETINA_SCAN_SETTINGS];
//    [[NSUserDefaults standardUserDefaults] setBool:TRUE forKey:PUSH_NOTIF_SETTINGS];
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
//    [self getBytesOfString:@"Klko4DmW3CAW2oJai4Iz1TUyD3YiR4V8wv5o89SHYDSq29rTmnNfcCtoGaxakbMXOKNvPZ97AoNFUx9m"];
    return @"Klko4DmW3CAW2oJai4Iz1TUyD3YiR4V8wv5o89SHYDSq29rTmnNfcCtoGaxakbMXOKNvPZ97AoNFUx9m";
//    return [self randomStringWithLength:80];

}

+(NSString *)getSecretKey{
    return KEY_VALUE;
}

+(NSString *)getMemberValue{
    
//    return @"546";

    User *obj =     [[SharedUser sharedManager] userObject];
    return [NSString stringWithFormat:@"%d",[obj.Account intValue]];
}

+(NSString *)getAccountValue{

    User *obj =     [[SharedUser sharedManager] userObject];
    
    SuffixInfo *objSuffixInfo;
    int suffixID = 0;
    if([[[SharedUser sharedManager] suffixInfoArr] count]>0){
        objSuffixInfo= (SuffixInfo *)[[SharedUser sharedManager] suffixInfoArr][0];
        suffixID= [objSuffixInfo.Suffixid intValue];
    }
    else
        suffixID= 55122;
    
    
    return [NSString stringWithFormat:@"%d%d",[obj.Account intValue],suffixID];

    
//    return @"54645432";
//    return [self randomStringWithLength:17];
}

+(NSString *)getAccountValueWithSuffix:(SuffixInfo *)suffix{
    
    NSString *accountValue = nil;
    if(suffix){
        User *obj =     [[SharedUser sharedManager] userObject];
        accountValue= [NSString stringWithFormat:@"%d%d",[obj.Account intValue],[suffix.Suffixid intValue]];
    }
    else{
        accountValue = [self getAccountValue];
    }

    return accountValue;
}



+(NSString *)getMemberEmail{
    
    User *obj =     [[SharedUser sharedManager] userObject];
    return obj.Email;

//    return @"ggwyn@shareone.com";
}

+(NSString *)getMemberName{
    
    User *obj =     [[SharedUser sharedManager] userObject];
    return obj.Name;

//    return @"Louis Uncommon";
}

+(NSString *)getMacForVertifiForSuffix:(SuffixInfo *)objSuffixInfo{
    

    NSString *mac=[NSString stringWithFormat:@"%@%@%d%@%@%@",REQUESTER_VALUE,[self getSessionnKey],[self getTimeStamp],ROUTING_VALUE,[self getMemberValue],[self getAccountValueWithSuffix:objSuffixInfo]];
    
    NSData* data = [mac dataUsingEncoding:NSUTF8StringEncoding];
    
    return  [self calculateHMACMD5:data];
}

+(NSString *)getHMACSHAWithSignature:(NSString *)signature andEncoding:(NSStringEncoding )encoding AndKey:(NSString *)key{
    
    
    const char *cKey  = [key cStringUsingEncoding:encoding];
    const char *cData = [signature cStringUsingEncoding:encoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    NSData *HMACData = [NSData dataWithBytes:cHMAC length:sizeof(cHMAC)];
    return [self getBase64ValueWithObject:HMACData];
}

+(NSString *)getAESEncryption:(NSString *)signature andEncoding:(NSStringEncoding )encoding AndKey:(NSString *)key{
    
    
    NSData *keyData =[key hexToBytes];
    
    NSData* data = [signature dataUsingEncoding:NSUTF8StringEncoding];
    
    
    NSMutableData *hMacOut = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA256,
           keyData.bytes, keyData.length,
           data.bytes,    data.length,
           hMacOut.mutableBytes);
    
    /* Returns hexadecimal string of NSData. Empty string if data is empty. */
    NSString *hexString = @"";
    if (data) {
        uint8_t *dataPointer = (uint8_t *)(hMacOut.bytes);
        for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
            hexString = [hexString stringByAppendingFormat:@"%02x", dataPointer[i]];
        }
    }
    
    
    
    NSLog(@"It should b HGZJbtfEyim5o5nT9QbgwhXnxCCEMSYwmefv0X1HoCU=");
    NSLog(@"REal : %@",[self getBase64ValueWithObject:hMacOut]);
    
    return [self getBase64ValueWithObject:hMacOut];
    

}

+ (NSString *)getBase64ValueWithObject:(NSData *)hmac_sha_data{
    return [hmac_sha_data base64EncodedStringWithOptions:0];
}

+ (NSString *)calculateHMACMD5:(NSData *)data {
    NSParameterAssert(data);
    
    NSData *keyData =[[self getSecretKey] hexToBytes];

    NSMutableData *hMacOut = [NSMutableData dataWithLength:CC_MD5_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgMD5,
           keyData.bytes, keyData.length,
           data.bytes,    data.length,
           hMacOut.mutableBytes);
    
    /* Returns hexadecimal string of NSData. Empty string if data is empty. */
    NSString *hexString = @"";
    if (data) {
        uint8_t *dataPointer = (uint8_t *)(hMacOut.bytes);
        for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
            hexString = [hexString stringByAppendingFormat:@"%02x", dataPointer[i]];
        }
    }
    
    return hexString;
}

+(void)getBytesOfString:(NSString *)string{
    NSData* data=[string dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger myLength = data.length;
    NSLog(@"getBytesOfString : %d",data.length);
}



+(NSString *)getUUID{
    
    User * user= [self getUserObject];
    NSString *Appname = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
    NSString *deviceID = [SAMKeychain passwordForService:Appname account:[NSString stringWithFormat:@"%d",[user.Account intValue]]];
    if (deviceID == nil){
        deviceID  = [[[UIDevice currentDevice]identifierForVendor] UUIDString];
        deviceID = [NSString stringWithFormat:@"%@%d",deviceID,[user.Account intValue]];
        [SAMKeychain setPassword:deviceID forService:Appname account:[NSString stringWithFormat:@"%d",[user.Account intValue]]];
    }
    return deviceID;
}

+(NSString *)getDeviceNotifToken{
    NSString *device_token = [ShareOneUtility getDeiviceToken];
    if(!device_token)
        device_token=@"";
    return device_token;
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
    
    
    //eab08a6943728a37
    
    
   return  [self applyEncriptionWithPrivateKey:PRIVATE_KEY_SSO andPublicKey:contexID];
    
//    return [self encryptString:contexID];


//    return [self encryptString:@"0a4e586b4db22c7e"];
}

+(NSDictionary *)getAESObjectWithGeneratedIV:(NSString *)contexID{
    
    NSDictionary *dic =  [self applyEncriptionWithPrivateKey:PRIVATE_KEY_SSO andPublicKey:contexID];
    return dic;;
}

+(NSString *)getAESRandomIVForSSON{
    
    return @"1db91e439b4521f72dde897f8a193e61";
//     return [self getAESRandom4WithSecretKey:PRIVATE_KEY_SSO AndPublicKey:PUBLIC_KEY];
}
//- (NSData *)doCipher:(NSData *)plainText key:(NSData *)theSymmetricKey context:(CCOperation)encryptOrDecrypt padding:(CCOptions *)pkcs7{
//    
//}

+ (NSString*)encryptString:(NSString*)string
{
    NSRange fullRange;
    fullRange.length = [string length];
    fullRange.location = 0;
    
    uint8_t buffer[[string length]];
    
    [string getBytes:&buffer maxLength:[string length] usedLength:NULL encoding:NSUTF8StringEncoding options:0 range:fullRange remainingRange:NULL];
    
    NSData *plainText = [NSData dataWithBytes:buffer length:[string length]];
    
    NSData *keyData =[PRIVATE_KEY_SSO hexToBytes];
    
    //NSData* data = [string dataUsingEncoding:NSUTF8StringEncoding];

    
    NSData *encryptedResponse = [self doCipher:plainText key:keyData context:kCCEncrypt padding:0];
    
    NSLog(@"It should b :  e/m+RmrpJgdiT5suEjzzNovFSrKQOYggjOYEjF+gdjk=");
    NSLog(@"base64EncodeData :%@" , [self base64EncodeData:encryptedResponse]);
    NSLog(@"getBase64ValueWithObject :%@" , [self getBase64ValueWithObject:encryptedResponse]);

    return [self base64EncodeData:encryptedResponse];
}



+ (NSData *)doCipher:(NSData *)plainText key:(NSData *)theSymmetricKey context:(CCOperation)encryptOrDecrypt padding:(CCOptions *)pkcs7
{
    CCCryptorStatus ccStatus = kCCSuccess;
    // Symmetric crypto reference.
    CCCryptorRef thisEncipher = NULL;
    // Cipher Text container.
    NSData * cipherOrPlainText = nil;
    // Pointer to output buffer.
    uint8_t * bufferPtr = NULL;
    // Total size of the buffer.
    size_t bufferPtrSize = 0;
    // Remaining bytes to be performed on.
    size_t remainingBytes = 0;
    // Number of bytes moved to buffer.
    size_t movedBytes = 0;
    // Length of plainText buffer.
    size_t plainTextBufferSize = 0;
    // Placeholder for total written.
    size_t totalBytesWritten = 0;
    // A friendly helper pointer.
    uint8_t * ptr;
    
    // Initialization vector; dummy in this case 0's.
    uint8_t iv[kCCBlockSizeAES128];
    memset((void *) iv, 0x0, (size_t) sizeof(iv));
    
    LOGGING_FACILITY(plainText != nil, @"PlainText object cannot be nil." );
    LOGGING_FACILITY(theSymmetricKey != nil, @"Symmetric key object cannot be nil." );
    LOGGING_FACILITY(pkcs7 != NULL, @"CCOptions * pkcs7 cannot be NULL." );
    LOGGING_FACILITY([theSymmetricKey length] == kCCKeySizeAES128, @"Disjoint choices for key size." );
    
    plainTextBufferSize = [plainText length];
    
    LOGGING_FACILITY(plainTextBufferSize > 0, @"Empty plaintext passed in." );
    
    // We don't want to toss padding on if we don't need to
    
    
    if(encryptOrDecrypt == kCCEncrypt)
    {
        /*
        if(*pkcs7 != kCCOptionECBMode)
        {
            if((plainTextBufferSize % kCCBlockSizeAES128) == 0)
            {
                *pkcs7 = 0x0000;
            }
            else
            {
                *pkcs7 = kCCOptionPKCS7Padding;
            }
        }
         */
        
//        *pkcs7 = kCCOptionPKCS7Padding;

    }
    else if(encryptOrDecrypt != kCCDecrypt)
    {
        LOGGING_FACILITY1( 0, @"Invalid CCOperation parameter [%d] for cipher context.", *pkcs7 );
    }
    
    // Create and Initialize the crypto reference.
    ccStatus = CCCryptorCreate(	encryptOrDecrypt,
                               kCCAlgorithmAES128,
                               kCCOptionPKCS7Padding,
                               (const void *)[theSymmetricKey bytes],
                               kCCKeySizeAES128,
                               (const void *)iv,
                               &thisEncipher
                               );
    
    LOGGING_FACILITY1( ccStatus == kCCSuccess, @"Problem creating the context, ccStatus == %d.", ccStatus );
    
    // Calculate byte block alignment for all calls through to and including final.
    bufferPtrSize = CCCryptorGetOutputLength(thisEncipher, plainTextBufferSize, true);
    
    // Allocate buffer.
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t) );
    
    // Zero out buffer.
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    
    // Initialize some necessary book keeping.
    
    ptr = bufferPtr;
    
    // Set up initial size.
    remainingBytes = bufferPtrSize;
    
    // Actually perform the encryption or decryption.
    ccStatus = CCCryptorUpdate( thisEncipher,
                               (const void *) [plainText bytes],
                               plainTextBufferSize,
                               ptr,
                               remainingBytes,
                               &movedBytes
                               );
    
    LOGGING_FACILITY1( ccStatus == kCCSuccess, @"Problem with CCCryptorUpdate, ccStatus == %d.", ccStatus );
    
    // Handle book keeping.
    ptr += movedBytes;
    remainingBytes -= movedBytes;
    totalBytesWritten += movedBytes;
    
    // Finalize everything to the output buffer.
    ccStatus = CCCryptorFinal(	thisEncipher,
                              ptr,
                              remainingBytes,
                              &movedBytes
                              );
    
    totalBytesWritten += movedBytes;
    
    if(thisEncipher)
    {
        (void) CCCryptorRelease(thisEncipher);
        thisEncipher = NULL;
    }
    
    LOGGING_FACILITY1( ccStatus == kCCSuccess, @"Problem with encipherment ccStatus == %d", ccStatus );
    
    cipherOrPlainText = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)totalBytesWritten];
    
    if(bufferPtr) free(bufferPtr);
    
    return cipherOrPlainText;
    
    /*
     Or the corresponding one-shot call:
     
     ccStatus = CCCrypt(	encryptOrDecrypt,
     kCCAlgorithmAES128,
     typeOfSymmetricOpts,
     (const void *)[self getSymmetricKeyBytes],
     kChosenCipherKeySize,
     iv,
     (const void *) [plainText bytes],
     plainTextBufferSize,
     (void *)bufferPtr,
     bufferPtrSize,
     &movedBytes
     );
     
     ccStatus = CCCrypt(	encryptOrDecrypt,
     kCCAlgorithmAES128,
     0,
     symmetricKey,
     kCCKeySizeAES128,
     iv,
     (const void *) [plainText bytes],
     plainTextBufferSize,
     (void *)bufferPtr,
     bufferPtrSize,
     &movedBytes
     );
     
     */
}

#pragma mark Base64 Encode/Decoder
+ (NSString *)base64EncodeData:(NSData*)dataToConvert
{
    if ([dataToConvert length] == 0)
        return @"";
    
    char *characters = malloc((([dataToConvert length] + 2) / 3) * 4);
    if (characters == NULL)
        return nil;
    
    NSUInteger length = 0;
    
    NSUInteger i = 0;
    while (i < [dataToConvert length])
    {
        char buffer[3] = {0,0,0};
        short bufferLength = 0;
        while (bufferLength < 3 && i < [dataToConvert length])
            buffer[bufferLength++] = ((char *)[dataToConvert bytes])[i++];
        
        //  Encode the bytes in the buffer to four characters, including padding "=" characters if necessary.
        characters[length++] = encodingTable[(buffer[0] & 0xFC) >> 2];
        characters[length++] = encodingTable[((buffer[0] & 0x03) << 4) | ((buffer[1] & 0xF0) >> 4)];
        if (bufferLength > 1)
            characters[length++] = encodingTable[((buffer[1] & 0x0F) << 2) | ((buffer[2] & 0xC0) >> 6)];
        else characters[length++] = '=';
        if (bufferLength > 2)
            characters[length++] = encodingTable[buffer[2] & 0x3F];
        else characters[length++] = '=';
    }
    
    return [[NSString alloc] initWithBytesNoCopy:characters length:length encoding:NSASCIIStringEncoding freeWhenDone:YES];
}


+ (NSString *)encodeToBase64String:(UIImage *)image {
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}


+(NSString *)getAccountTypeWithSuffix:(SuffixInfo *)objSuffixInfo{
    
    NSString *accountType = @"0" ;
    
    if([objSuffixInfo.Type isEqualToString:@"S"]){
        // Share
        accountType = @"1";
    }
    else if([objSuffixInfo.Type isEqualToString:@"L"]){
        // Loan
        accountType = @"3";

    }
    else if([objSuffixInfo.Type isEqualToString:@"C"]){
        //Certificate
        accountType = @"1";

    }
   else if([objSuffixInfo.Type isEqualToString:@"V"]){
       //Internal credit card
       accountType = @"1";
    }
   else if([objSuffixInfo.Type isEqualToString:@"T"]){
       // External credit card
       accountType = @"1";
   }
   else if([objSuffixInfo.Type isEqualToString:@"M"]){
       // External Mortgage
       accountType = @"1";
   }
    return accountType;
}

+(NSString *)getDeviceType{
     return  [UIDevice currentDevice].model;
}
+(NSDictionary *)encryptionByFBEncryptorAESWithContextID:(NSString *)contextID{
    
    NSData* ivData = [FBEncryptorAES generateIv];
    NSString* hexStringIV = [FBEncryptorAES hexStringForData:ivData];
    
    NSString *keyString = PRIVATE_KEY_SSO;
    NSData *keyData = [keyString hexToBytes];
    
    NSString *plaintText = contextID;
    
    NSRange fullRange;
    fullRange.length = [plaintText length];
    fullRange.location = 0;
    
    uint8_t buffer[[plaintText length]];
    
    [plaintText getBytes:&buffer maxLength:[plaintText length] usedLength:NULL encoding:NSUTF8StringEncoding options:0 range:fullRange remainingRange:NULL];
    
    NSData *plainTextData = [NSData dataWithBytes:buffer length:[plaintText length]];
    
    
    NSData *encryptedData = [FBEncryptorAES encryptData:plainTextData key:keyData iv:ivData];
    
    NSData *decryptedData = [FBEncryptorAES decryptData:encryptedData key:keyData iv:ivData];
    
    BOOL res = [decryptedData isEqualToData:plainTextData];
//    NSLog(@"Match: %@", res ? @"Yes" : @"No"); // Match: Yes
    
    
//    NSString* contextIDFromDecryptedString = [NSString stringWithUTF8String:[decryptedData bytes]];
//    NSString* contextIDFromPlaintData = [NSString stringWithUTF8String:[plainTextData bytes]];
    
    NSString *base64EncodedString = [encryptedData base64EncodedString];
    
    
//    NSLog(@"1: base64EncodedString  :  %@",base64EncodedString);
//        NSLog(@"1: base64EncodedString2  :  %@",base64EncodedString2);
    
    
//    NSString *hexadecimalString = [ivData hexadecimalString];
//    NSLog(@"1: hexadecimalString  :  %@",hexadecimalString);
//    NSLog(@"2: hexStringIV : %@",hexStringIV);
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:base64EncodedString,@"EncryptedContextID",hexStringIV,@"EncryptionIV", nil];
    
    return dict;
}

+(NSString *)decodeBase64ToStirng:(NSString *)encodedString{
    
    NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:encodedString options:0];
    NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
    return decodedString;
}

+(void)saveDeviceToken:(NSString *)token{
    
    [[NSUserDefaults standardUserDefaults] setValue:token forKey:@"device_token"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSString *)getDeiviceToken{
    return  [[NSUserDefaults standardUserDefaults] valueForKey:@"device_token"];
}

+(void)saveMenuItemObjectForTouchIDAuthentication:(NSDictionary *)dict{
    
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"menu_item"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSDictionary *)getMenuItemForTouchIDAuthentication{
    
    NSDictionary *lastSelectedItem = (NSDictionary *)[[NSUserDefaults standardUserDefaults] valueForKey:@"menu_item"];
    if(!lastSelectedItem)
        lastSelectedItem = [self getAccountSummaryObjectFromPlist];
    
    return  lastSelectedItem;
    
//    return  (NSDictionary *)[[NSUserDefaults standardUserDefaults] valueForKey:@"menu_item"];
}

+(void)removeCacheControllerName{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"menu_item"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


+(int)getDayOfWeek{
    NSCalendar* cal = [NSCalendar currentCalendar];
    NSDateComponents* comp = [cal components:NSCalendarUnitWeekday fromDate:[NSDate date]];
    NSLog(@"weekday :%ld",(long)[comp weekday]);
    return (int)[comp weekday]; // 1 = Sunday, 2 = Monday, etc.
}

+(NSString *)getDateInCustomeFormatWithSourceDate:(NSString *)sourceDate andDateFormat:(NSString *)dateFormater{
    
    NSString *dateString;
    
    NSDateFormatter *sourceDateFormater = [[NSDateFormatter alloc] init];
    
    [sourceDateFormater setDateFormat:@"HH:mm:ss.000"];
    
    NSDate *date = [sourceDateFormater dateFromString:sourceDate];
    
    [sourceDateFormater setDateFormat:dateFormater];
    
    dateString = [sourceDateFormater stringFromDate:date];
    
    return dateString;
}

+ (void)setTerminateState:(BOOL)isTerminated{
    
    [[NSUserDefaults standardUserDefaults] setBool:isTerminated forKey:@"isTerminated"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isTerminated{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"isTerminated"];
}

+(NSMutableDictionary *)eliminateNullValuesFromDictionary:(NSDictionary *)dict parentDictionaryKey:(NSString *)key{
    
    NSMutableArray *arrayOfDictWithNoNullValues = [[NSMutableArray alloc] init];
    
    NSArray *nullValesArr =[dict valueForKey:key];
    
    for(NSDictionary *nullValuesDict in nullValesArr){
        
        NSMutableDictionary *prunedDictionary = [NSMutableDictionary dictionary];

        for (NSString * key in [nullValuesDict allKeys]){
            if (![[nullValuesDict objectForKey:key] isKindOfClass:[NSNull class]])
                [prunedDictionary setObject:[nullValuesDict objectForKey:key] forKey:key];
        }
        
        [arrayOfDictWithNoNullValues addObject:prunedDictionary];
    }
    
    NSMutableDictionary *castParentDictWithNonNullValues = [dict mutableCopy];
    [castParentDictWithNonNullValues setValue:arrayOfDictWithNoNullValues forKey:key];
    return castParentDictWithNonNullValues;
}

+ (void)setStatusOfPasswordChanged:(BOOL)isComingFromPasswordChanged{
    
    [[NSUserDefaults standardUserDefaults] setBool:isComingFromPasswordChanged forKey:@"isComingFromPasswordChanged"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}
+ (BOOL)isComingFromPasswordChanged{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"isComingFromPasswordChanged"];
}

+(UIImage *)getImageFromBase64String:(NSString *)base64String{
    
    NSData *data = [[NSData alloc]initWithBase64EncodedString:base64String options:NSDataBase64DecodingIgnoreUnknownCharacters];
    UIImage *image64 = [UIImage imageWithData:data];
    return image64;
}

+(NSDictionary *)makeContactsWithProfileLink:(NSString *)link AndNickName:(NSString *)nickName{
    
    return [NSDictionary dictionaryWithObjectsAndKeys:link,@"profie_link",nickName,@"nick_name", nil];
}

+(NSString *)getFavouriteContactProfileLinkWithObject:(NSDictionary *)dict{
    return [dict valueForKey:@"profie_link"];
}

+(NSString *)getFavouriteContactNickNameWithObject:(NSDictionary *)dict{
    return [dict valueForKey:@"nick_name"];
}

+(NSMutableArray *)getFavContactsForUser:(User *)user{
    
   return (NSMutableArray *) [[[NSUserDefaults standardUserDefaults] valueForKey:[NSString stringWithFormat:@"contacts%d",[user.Account intValue]]] mutableCopy];
}

+(void)saveContactsForUser:(User *)user withArray:(NSMutableArray *)array{
    
    [[NSUserDefaults standardUserDefaults] setValue:array forKey:[NSString stringWithFormat:@"contacts%d",[user.Account intValue]]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
}

@end
