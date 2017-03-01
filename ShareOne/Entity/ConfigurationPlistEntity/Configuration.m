//
//  Configuration.m
//  ShareOne
//
//  Created by Qazi Naveed on 2/22/17.
//  Copyright © 2017 Ali Akbar. All rights reserved.
//

#import "Configuration.h"
#import "AppServiceModel.h"

//#define BASE_URL_CONFIGURATION @"https://nsauth-dev.ns3web.com/core"

//#define BASE_URL_CONFIGURATION @"https://nsconfig-extdev.ns3web.com"

#define BASE_URL_CONFIGURATION   @"https://nsauth-extdev.ns3web.com/core"


#define ACCESS_TOKEN           @"connect/token"

#define Grant_Type_Value       @"client_credentials"
#define Scope_value            @"customer.read cleint_application.read"
#define Client_ID_value        @"nsmobile_nsconfig_read_client"
#define Client_Secret_value    @"202E8187-94DE-4CDA-8908-7A9436B21292"

@implementation Configuration

-(id) initWithDictionary:(NSDictionary *)configurationDict{
    
    self = [super init];{
        [self setValuesForKeysWithDictionary:configurationDict];
    }
    return self;
}

+ (void)getConfiguration{
    
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:Grant_Type_Value,@"grant_type",Scope_value,@"scope",Client_ID_value,@"client_id",Client_Secret_value,@"client_secret", nil];
    
    [[AppServiceModel sharedClient] postRequestForConfigAPIWithParam:param progressMessage:nil urlString:[NSString stringWithFormat:@"%@/%@",BASE_URL_CONFIGURATION,ACCESS_TOKEN] delegate:nil completionBlock:^(NSObject *response) {
        
    } failureBlock:^(NSError *error) {
        
    }];
    
}

@end
