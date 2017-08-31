//
//  Configuration.h
//  ShareOne
//
//  Created by Qazi Naveed on 2/22/17.
//  Copyright © 2017 Ali Akbar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StyleValuesObject.h"
#import "ClientSettingsObject.h"


@interface Configuration : NSObject

@property (nonatomic, strong) NSString *baseUrl;
@property (nonatomic, strong) NSString *customerId;
@property (nonatomic, strong) NSString *buttonColor;
@property (nonatomic, strong) NSString *staticTextColor;
@property (nonatomic, strong) NSString *variableTextColor;
@property (nonatomic, strong) NSString *logoMobileMain;
@property (nonatomic, strong) NSString *joinLink;
@property (nonatomic, strong) NSString *applyLoanLink;
@property (nonatomic, strong) NSString *branchLocationLink;
@property (nonatomic, strong) NSString *contactLink;
@property (nonatomic, strong) NSString *ratesLink;
@property (nonatomic, strong) NSString *menuBackgroundColor;
@property (nonatomic, strong) NSString *menuTextColor;
@property (nonatomic, strong) NSString *loginImage;
@property (nonatomic, strong) NSString *splashImage;
@property (nonatomic, strong) NSString *emp1Email;
@property (nonatomic, strong) NSString *emp2Email;
@property (nonatomic, strong) NSString *vertifiSecretKey;
@property (nonatomic, strong) NSString *vertifiRequestorKey;
@property (nonatomic, strong) NSString *vertifiRouting;
@property (nonatomic, strong) NSString *CoOpId;
@property (nonatomic, strong) NSString *DeepTargetId;
@property (nonatomic, strong) NSString *OuttageVerbiage;
@property (nonatomic, strong) NSNumber *DisableShowOffers;
@property (nonatomic, strong) NSString *SocialFacebookLink;
@property (nonatomic, strong) NSString *SocialTwitterLink;
@property (nonatomic, strong) NSString *SocialLinkedinLink;
@property (nonatomic, strong) NSString *privacyPolicyLink;
@property (nonatomic, strong) NSString *googleApiKey;
@property (nonatomic, strong) NSString *ssoBaseUrl;
@property (nonatomic, strong) NSString *TestFairyID;

@property (nonatomic,strong) NSString *hMacType;
@property (nonatomic,strong) NSString *securityVersion;
@property (nonatomic,strong) NSString *creditUnionPrivateKey;
@property (nonatomic,strong) NSString *creditUnionPublicKey;
@property (nonatomic,strong) NSString *ssoPrivateKey;
@property BOOL shouldBuildForProduction;


-(id) initWithDictionary:(NSDictionary *)configurationDict;

+ (void)getConfigurationWithDelegate :(id)delegate completionBlock:(void(^)(BOOL success,NSString *errorString))block failureBlock:(void(^)(NSError* error))failBlock;

+(NSArray *)getPlistFileWithName:(NSString *)filename;

+(NSMutableArray *)getAllMenuItemsIncludeHiddenItems:(BOOL)showHidenItems;


+(StyleValuesObject *)getStyleValueContent;
+(ClientSettingsObject *)getClientSettingsContent;
+(NSString *)getMaintenanceVerbiage;
+(NSString *)getCoOpID;
+(NSString *)getVertifiRDCTestMode;
+(NSString *)getVertifiRDCURL;
+(NSString *)getVertifiSecretKey;
+(NSString *)getVertifiRequesterKey;
+(NSString *)getVertifiRouterKey;
+(NSString *)getSSOBaseUrl;


+(NSDictionary *)getPlistDictFileWithName:(NSString *)filename;


+(NSString *)getErrorMessage;

+(NSString *)getBaseUrl;
+(NSString *)getBaseUrlPublicKey;
+(NSString *)getBaseUrlPrivateKey;

+(NSString *)getSecurityVersion;
+(NSString *)getHmacType;



+(NSArray *)getClientApplications;




@end
