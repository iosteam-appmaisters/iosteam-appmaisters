//
//  Configuration.m
//  ShareOne
//
//  Created by Qazi Naveed on 2/22/17.
//  Copyright © 2017 Ali Akbar. All rights reserved.
//

#import "Configuration.h"
#import "AppServiceModel.h"
#import "ShareOneUtility.h"
#import "LoaderServices.h"
#import "ConfigurationModel.h"
#import "ApiSettingsObject.h"
#import "ClientApplicationsObject.h"




//#define BASE_URL_CONFIGURATION @"https://nsauth-dev.ns3web.com/core"

//#define BASE_URL_CONFIGURATION @"https://nsconfig-extdev.ns3web.com"

#define BASE_URL_CONFIGURATION   @"https://nsauth-extdev.ns3web.com/core"

#define BASE_URL_CONFIGURATION_NS_CONGIG   @"https://nsconfig-extdev.ns3web.com/api/ClientApplications/1/MenuItems"






#define ACCESS_TOKEN           @"connect/token"

#define Grant_Type_Value       @"client_credentials"
#define Scope_value            @"content_file.read content_text_group.read content_text.read style_value.read client_setting.read menu_item.read nsapi_setting.read modified_service.read client_application.read"
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

+ (void)getConfigurationWithDelegate :(id)delegate completionBlock:(void(^)(BOOL success,NSString *errorString))block failureBlock:(void(^)(NSError* error))failBlock{
    
    NSDictionary *param = [NSDictionary dictionaryWithObjectsAndKeys:Grant_Type_Value,@"grant_type",Scope_value,@"scope",Client_ID_value,@"client_id",Client_Secret_value,@"client_secret", nil];
    
    NSString  *urlString = [NSString stringWithFormat:@"%@/%@/",BASE_URL_CONFIGURATION,ACCESS_TOKEN];

    [[AppServiceModel sharedClient] postRequestForConfigAPIWithParam:param progressMessage:nil urlString:urlString delegate:delegate completionBlock:^(NSObject *response) {
        if(response){
            
            NSDictionary *dict = (NSDictionary *)response;
            
            NSString *authToken = [NSString stringWithFormat:@"%@ %@",dict[@"token_type"],dict[@"access_token"]];

            
            [[AppServiceModel sharedClient] getRequestForConfigAPIWithAuthHeader:authToken andProgressMessage:nil urlString:BASE_URL_CONFIGURATION_NS_CONGIG_WITH_CLIENT_ID_AND_SERVICE_NAME(CUSTOMER_CONTROLLER, [ShareOneUtility getCustomerId], CONFIG_CLIENT_APP)   delegate:nil completionBlock:^(NSObject *response) {
                
                if(response){
                    
                    [LoaderServices getModifiedServicesWithDelegate:self withContentDict:dict completionBlock:^(BOOL success, NSString *errorString) {
                        block(success,errorString);
                        
                    } failureBlock:^(NSError *error) {
                        block(FALSE,[Configuration getMaintenanceVerbiage]);
                    }];
                }
                
            } failureBlock:^(NSError *error) {
                block(FALSE,[Configuration getMaintenanceVerbiage]);
            }];
        }
        else{
            block(FALSE,[Configuration getMaintenanceVerbiage]);
        }
    } failureBlock:^(NSError *error) {
        block(FALSE,[Configuration getMaintenanceVerbiage]);
    }];
}

+(NSArray *)getPlistFileWithName:(NSString *)filename{
    
    NSString *path = [ShareOneUtility getDocumentsDirectoryPathWithFileName:[NSString stringWithFormat:@"%@.plist",filename]];
    NSArray  *arrPlist = [NSArray arrayWithContentsOfFile:path];
    return arrPlist;
}

+(NSDictionary *)getPlistDictFileWithName:(NSString *)filename{
    
    NSString *path = [ShareOneUtility getDocumentsDirectoryPathWithFileName:[NSString stringWithFormat:@"%@.plist",filename]];
    NSDictionary  *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    return dict;
}

+(NSMutableArray *)getAllMenuItemsIncludeHiddenItems:(BOOL)showHidenItems{
    
    NSArray *menuItemsArr = [self getPlistFileWithName:CONFIG_MENU_ITEMS_SERVICE];
    
    NSSortDescriptor *indexDescriptorForSections = [NSSortDescriptor sortDescriptorWithKey:@"Index"
                                                                 ascending:YES];
    

    NSPredicate *predForParentNodeNotExist = nil;
    NSPredicate *predForParentNodeExist = nil;
    
    if(showHidenItems){
        
        predForParentNodeNotExist = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"(NOT (Parent in SELF))"]];
        
        predForParentNodeExist = [NSPredicate predicateWithFormat:@"(Parent in SELF)"];

    }
    else{
        
        predForParentNodeNotExist = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"(NOT (Parent in SELF)) AND IsHidden == FALSE"]];
        
        predForParentNodeExist = [NSPredicate predicateWithFormat:@"(Parent in SELF AND IsHidden == FALSE)"];

    }

    NSMutableArray *sectionItemsArray = [[[menuItemsArr filteredArrayUsingPredicate:predForParentNodeNotExist]
                        sortedArrayUsingDescriptors:[NSArray arrayWithObject:indexDescriptorForSections]] mutableCopy];
    
    NSArray *rowItemsArray = [menuItemsArr filteredArrayUsingPredicate:predForParentNodeExist];
    
    [sectionItemsArray enumerateObjectsUsingBlock:^(NSDictionary *sectionObject, NSUInteger idx, BOOL * _Nonnull stop) {
        
        int sectionID = [sectionObject[@"ID"] intValue];
        
//        NSString *DisplayText = sectionObject[@"DisplayText"];

        NSPredicate *predForChildNodes = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"Parent.ID == %d",sectionID]];
        
        NSSortDescriptor *indexDescriptorForRows = [NSSortDescriptor sortDescriptorWithKey:@"Index"
                                                                                 ascending:YES];

        NSArray *rowItemsArr = [[rowItemsArray filteredArrayUsingPredicate:predForChildNodes]
                                sortedArrayUsingDescriptors:[NSArray arrayWithObject:indexDescriptorForRows]];
        if([rowItemsArr count]>0){
            
            NSMutableDictionary *mutableCloneSectionObject = [sectionObject mutableCopy];
            [mutableCloneSectionObject setValue:rowItemsArr forKey:MAIN_CAT_SUB_CATEGORIES];
            
            [sectionItemsArray replaceObjectAtIndex:idx withObject:mutableCloneSectionObject];
        }
//        NSLog(@"Items for %@,\n %@",DisplayText,rowItemsArr);
    }];
    
    return sectionItemsArray;
}


+(StyleValuesObject *)getStyleValueContent{
    
    NSArray *styleItemsArray = [self getPlistFileWithName:CONFIG_STYLE_VALUES_SERVICE];
    return  [StyleValuesObject parseStyleValues:styleItemsArray];
}


+(ClientSettingsObject *)getClientSettingsContent{
    
    NSArray *cleintSettingsArray = [self getPlistFileWithName:CONFIG_CLIENT_SETTINGS_SERVICE];
    
    return [ClientSettingsObject parseClientSettings:cleintSettingsArray];
}


+(NSString *)getBaseUrl{
    
    NSDictionary *dict =[self getPlistDictFileWithName:CONFIG_API_SETTINGS_SERVICE];
    ApiSettingsObject *objparseClientSettings=[[ApiSettingsObject alloc] initWithDictionary:dict];
    NSString *hostname = objparseClientSettings.HostName;
    if(![hostname containsString:@"https"])
        hostname=[NSString stringWithFormat:@"https://%@",hostname];
    return  hostname;
}


+(NSString *)getBaseUrlPublicKey{
    
    NSDictionary *dict =[self getPlistDictFileWithName:CONFIG_API_SETTINGS_SERVICE];
    ApiSettingsObject *objparseClientSettings=[[ApiSettingsObject alloc] initWithDictionary:dict];
    return objparseClientSettings.PublicKey;
}

+(NSString *)getBaseUrlPrivateKey{
    
    NSDictionary *dict =[self getPlistDictFileWithName:CONFIG_API_SETTINGS_SERVICE];
    ApiSettingsObject *objparseClientSettings=[[ApiSettingsObject alloc] initWithDictionary:dict];
    return objparseClientSettings.PrivateKey;
}

+(NSString *)getSecurityVersion{
    
    NSDictionary *dict =[self getPlistDictFileWithName:CONFIG_API_SETTINGS_SERVICE];
    ApiSettingsObject *objparseClientSettings=[[ApiSettingsObject alloc] initWithDictionary:dict];
    return objparseClientSettings.SecurityVersion;
}
+(NSString *)getHmacType{
    
    NSDictionary *dict =[self getPlistDictFileWithName:CONFIG_API_SETTINGS_SERVICE];
    ApiSettingsObject *objparseClientSettings=[[ApiSettingsObject alloc] initWithDictionary:dict];
    return objparseClientSettings.HMACType;
}




+(NSString *)getMaintenanceVerbiage{
    
    ClientSettingsObject *obj = [self getClientSettingsContent];
    
    NSString *message = obj.maintenanceverbiage;
    if(!message)
        message=[self getErrorMessage];
    
    return  message;
}

+(NSString *)getErrorMessage{
    Configuration *config = [ShareOneUtility getConfigurationFile];
    return config.OuttageVerbiage;
}


+(NSString *)getCoOpID{
    
    ClientSettingsObject *obj = [self getClientSettingsContent];
    return  obj.coopid;
}



+(NSString *)getVertifiSecretKey{
    ClientSettingsObject *obj = [self getClientSettingsContent];
    return  obj.vertifirdcsecretkey;
}

+(NSString *)getVertifiRequesterKey{
    ClientSettingsObject *obj = [self getClientSettingsContent];
    return  obj.vertifirdcrequestorkey;
}

+(NSString *)getVertifiRDCTestMode{
    ClientSettingsObject *obj = [self getClientSettingsContent];
    return  obj.vertifirdctestmode;
}

+(NSString *)getVertifiRDCURL{
    ClientSettingsObject *obj = [self getClientSettingsContent];
    return  [ShareOneUtility checkLastSlashInURL:obj.vertifirdcurl];
}


+(NSString *)getVertifiRouterKey{
    ClientSettingsObject *obj = [self getClientSettingsContent];
    return  obj.routingnumber;
}

+(NSString *)getPrivateKey{
    ClientSettingsObject *obj = [self getClientSettingsContent];
    return  obj.routingnumber;
}




+(NSString *)getSSOBaseUrl{
    
    NSString *hostname = nil;
    ClientSettingsObject *obj = [self getClientSettingsContent];

    hostname = obj.basewebviewurl;
    
    if(![hostname containsString:@"https"])
        hostname=[NSString stringWithFormat:@"https://%@",hostname];

    return hostname;
}

+(NSArray *)getClientApplications{
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSArray *cleintAppsArray = [self getPlistFileWithName:CONFIG_CLIENT_APP];
    [cleintAppsArray enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ClientApplicationsObject *objClientApplicationsObject = [[ClientApplicationsObject alloc] initWithDictionary:obj];
        [array addObject:objClientApplicationsObject];
    }];

    return array;
}

@end
