//
//  Configuration.h
//  ShareOne
//
//  Created by Qazi Naveed on 2/22/17.
//  Copyright © 2017 Ali Akbar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Configuration : NSObject

@property (nonatomic, strong) NSString *baseUrl;
@property (nonatomic, strong) NSString *customerId;
@property (nonatomic, strong) NSString *controllerUrl;
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
@property (nonatomic, strong) NSString *fiCkrouting;
@property (nonatomic, strong) NSString *CoOpId;
@property (nonatomic, strong) NSString *DeepTargetId;
@property (nonatomic, strong) NSString *OuttageVerbiage;
@property (nonatomic, strong) NSNumber *DisableShowOffers;
@property (nonatomic, strong) NSString *SocialFacebookLink;
@property (nonatomic, strong) NSString *SocialTwitterLink;
@property (nonatomic, strong) NSString *SocialLinkedinLink;
@property (nonatomic, strong) NSString *privacyPolicyLink;


-(id) initWithDictionary:(NSDictionary *)configurationDict;


+ (void)getConfiguration;
@end
