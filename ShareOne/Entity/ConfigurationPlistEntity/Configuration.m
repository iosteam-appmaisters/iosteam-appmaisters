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

#define BASE_URL_CONFIGURATION_NS_CONGIG   @"https://nsconfig-extdev.ns3web.com/api/ClientApplications/1/MenuItems"



#define ACCESS_TOKEN           @"connect/token"

#define Grant_Type_Value       @"client_credentials"
#define Scope_value            @"content_file.read content_text_group.read content_text.read style_value.read client_setting.read menu_item.read"
#define Client_ID_value        @"nsmobile_nsconfig_read_client"//nsmobile_nsconfig_read_client
#define Client_Secret_value    @"202E8187-94DE-4CDA-8908-7A9436B21292"

//#define Client_Secret_value    @"0873C663-961E-4F73-B598-9333DD44EA8A"


//customer.read client_setting.read menu_item.read

@implementation Configuration

-(id) initWithDictionary:(NSDictionary *)configurationDict{
    
    self = [super init];{
        [self setValuesForKeysWithDictionary:configurationDict];
    }
    return self;
}

+ (void)getConfiguration{
    
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:Grant_Type_Value,@"grant_type",Scope_value,@"scope",Client_ID_value,@"client_id",Client_Secret_value,@"client_secret", nil];
    
    NSString  *urlString = [NSString stringWithFormat:@"%@/%@/",BASE_URL_CONFIGURATION,ACCESS_TOKEN];

    [[AppServiceModel sharedClient] postRequestForConfigAPIWithParam:param progressMessage:nil urlString:urlString delegate:nil completionBlock:^(NSObject *response) {
        if(response){
            
            NSDictionary *dict = (NSDictionary *)response;
            [[AppServiceModel sharedClient] getRequestForConfigAPIWithAuthHeader:[NSString stringWithFormat:@"%@ %@",dict[@"token_type"],dict[@"access_token"]] andProgressMessage:nil urlString:BASE_URL_CONFIGURATION_NS_CONGIG delegate:nil completionBlock:^(NSObject *response) {
                
            } failureBlock:^(NSError *error) {
                
            }];
        }
        
    } failureBlock:^(NSError *error) {
        
    }];
        
}

@end
