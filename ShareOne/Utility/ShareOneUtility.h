//
//  ShareOneUtility.h
//  ShareOne
//
//  Created by Qazi Naveed on 20/09/2016.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UtilitiesHelper.h"


@interface ShareOneUtility : UtilitiesHelper

+ (NSArray *)getSideMenuDataFromPlist;
+ (NSArray *)getDummyDataForQB;
+ (NSMutableArray*)getLocationArray;

+(int)getTimeStamp;


+ (NSString *)createSignatureWithTimeStamp:(int)timestamp andRequestType:(NSString *)request_type havingEncoding:(NSStringEncoding) encoding;

+ (NSString *)getAESRandom4WithSecretKey:(NSString *)secret_key AndPublicKey:(NSString *)public_key;


+ (NSString *)getAuthHeader;


@end
