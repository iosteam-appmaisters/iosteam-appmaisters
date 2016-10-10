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

#import "ShareOneUtility.h"
#import "BBAES.h"
#import "Constants.h"
#import "Services.h"


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
    [locationArr addObject:@"53.4198855,-2.9808854"];
    [locationArr addObject:@"53.4184578,-3.0030442"];
    [locationArr addObject:@"53.4201264,-2.9916392"];
    [locationArr addObject:@"53.4024066,-2.9844725"];
    [locationArr addObject:@"53.4039417,-2.9808717"];
    [locationArr addObject:@"53.4035396,-2.9799329"];
    [locationArr addObject:@"53.4027041,-2.9798886"];


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
//    const unsigned char *buffer = (const unsigned char *)[HMACData bytes];
//    NSMutableString *HMAC = [NSMutableString stringWithCapacity:HMACData.length * 2];
//    for (int i = 0; i < HMACData.length; ++i){
//        [HMAC appendFormat:@"%02x", buffer[i]];
//    }

//    NSLog(@"getBase64ValueWithObject : %@",[self getBase64ValueWithObject:HMACData]);
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
    [defaults setObject:archivedObject forKey:@"USER_KEY"];
    [defaults synchronize];
}


+(User *)getUserObject{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *archivedObject = [defaults objectForKey:@"USER_KEY"];
    return  (User *)[NSKeyedUnarchiver unarchiveObjectWithData:archivedObject];
}


+ (void)setUserRememberedStatusWithBool:(BOOL)isRemember{
    
    [[NSUserDefaults standardUserDefaults] setBool:isRemember forKey:@"isLoginRemembered"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}
+ (BOOL)isUserRemembered{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"isLoginRemembered"];
}


+ (void)setTouhIDStatusWithBool:(BOOL)isRemember{
    
    [[NSUserDefaults standardUserDefaults] setBool:isRemember forKey:@"isTouchEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

+ (BOOL)isTouchIDEnabled{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"isTouchEnabled"];
}

+(void)savaLogedInSignature:(NSString *)signature{
    [[NSUserDefaults standardUserDefaults] setValue:signature forKey:@"Signature"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}
+(NSString *)getSignedINSignature{
    
   return  [[NSUserDefaults standardUserDefaults] valueForKey:@"Signature"];
}


@end
