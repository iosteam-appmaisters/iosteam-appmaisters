//
//  LoaderServices.m
//  ShareOne
//
//  Created by Qazi Naveed on 24/10/2016.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "LoaderServices.h"
#import "AppServiceModel.h"
#import "Services.h"
#import "SharedUser.h"
#import "ShareOneUtility.h"
#import "MemberDevices.h"
#import "SuffixInfo.h"
#import "QuickBalances.h"
#import "QuickTransaction.h"

@implementation LoaderServices



+(void)setQTRequestOnQueueWithDelegate:(id)delegate AndQuickBalanceArr:(NSArray *)qbArr completionBlock:(void(^)(BOOL success,NSString *errorString))block failureBlock:(void(^)(NSError* error))failBlock{
    
    NSMutableArray *queuReqArr = [[NSMutableArray alloc] init];
    [qbArr enumerateObjectsUsingBlock:^(QuickBalances *object, NSUInteger idx, BOOL *stop) {
        
        NSString *url = [NSString stringWithFormat:@"%@/%@/%@/%d/%@",[ShareOneUtility getBaseUrl],KQUICK_TRANSACTION,[ShareOneUtility getUUID],[object.Suffixid intValue] ,[ShareOneUtility getNumberOfQuickViewTransactions]];

        [queuReqArr addObject:[NSDictionary dictionaryWithObjectsAndKeys:url,REQ_URL,RequestType_GET,REQ_TYPE,[ShareOneUtility getAuthHeaderWithRequestType:RequestType_GET],REQ_HEADER,nil,REQ_PARAM, nil]];
    }];
    
    
    [[AppServiceModel sharedClient] createBatchOfRequestsWithObject:queuReqArr requestCompletionBlock:^(NSObject *response,id responseObj) {
        
        NSURLResponse *responseCast = (NSURLResponse *)responseObj;
        NSString *url = responseCast.URL.absoluteString;

        NSArray *urlCompArr = [url  componentsSeparatedByString:@"/"];
        NSString *suffixID = urlCompArr[[urlCompArr count]-2];

        NSPredicate *suffixPredicate = [NSPredicate predicateWithFormat:@"Suffixid = %d",[suffixID intValue]];

        NSArray *filteredQBArr = [qbArr filteredArrayUsingPredicate:suffixPredicate];

        if([filteredQBArr count]>0){
            QuickBalances *obj = filteredQBArr[0];
            NSArray *qtObjects = [QuickTransaction  getQTObjects:(NSDictionary *)response];
            obj.transArr = [qtObjects mutableCopy];
        }
        
    } requestFailureBlock:^(NSError *error) {
        
    } queueCompletionBlock:^(BOOL sucess,NSString *errorString) {
        block(sucess,errorString);
    } queueFailureBlock:^(NSError *error) {
        
    }];
    
}


+ (void)getModifiedServicesWithDelegate:(id)delegate
                        withContentDict:(NSDictionary *)dict
                        completionBlock:(void(^)(BOOL success,NSString *errorString))block
                           failureBlock:(void(^)(NSError* error))failBlock {
    
    NSString *authToken = [NSString stringWithFormat:@"%@ %@",dict[@"token_type"],dict[@"access_token"]];
    
    NSDictionary *modifiedServicesDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                          NSCONFIG_GET_MODIFIEDSERVICES([ShareOneUtility getClientApplicationID],
                                           @"0"),REQ_URL,
                                          RequestType_GET,REQ_TYPE,
                                          authToken,REQ_HEADER_CONFIGURATION,
                                          nil,REQ_PARAM,
                                          nil];
    
    NSArray *reqArr = [NSArray arrayWithObjects:modifiedServicesDict, nil];
    
    [[AppServiceModel sharedClient] createBatchOfRequestsWithObject:reqArr requestCompletionBlock:^(NSObject *response,id responseObj) {
        
        NSDictionary * responseDic = (NSDictionary*)response;
        
        NSString * versionNumber = [NSString stringWithFormat:@"%d", [responseDic[@"VersionNumber"]intValue]] ;
        
        [ShareOneUtility saveVersionNumber:versionNumber];
        
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"MessageLabelNotification"
         object:self userInfo:@{@"MESSAGE":@"Applying settings...",
                                @"STATUS":@"0",
                                @"VERSION":versionNumber,
                                @"CUSTOMER_ID":[ShareOneUtility getCustomerId]}];
        
        NSMutableArray * modifiedServices = [responseDic[@"ModifiedServices"] mutableCopy];
        
        NSMutableArray * validModifiedServices = [NSMutableArray array];
        
        for (id val in modifiedServices){
            NSString * valueString = (NSString*)val;
            if (![valueString isEqualToString:@"content_text_group"] && ![valueString isEqualToString:@"content_text"]) {
                [validModifiedServices addObject:valueString];
            }
        }
        
        NSLog(@"%@",validModifiedServices);
        
        [LoaderServices setConfigurationQueueWithDelegate:self withContentDict:dict queueArray:[validModifiedServices copy] completionBlock:^(BOOL success, NSString *errorString) {
            block(success,errorString);
        } failureBlock:^(NSError *error) {
            block(FALSE,[Configuration getMaintenanceVerbiage]);
        }];
        
    } requestFailureBlock:^(NSError *error) {
        
    } queueCompletionBlock:^(BOOL sucess,NSString *errorString) {
        
//        if([ShareOneUtility isConfigDataSaved])
//            block(sucess,errorString);
        
    } queueFailureBlock:^(NSError *error) {
        block(FALSE,[Configuration getMaintenanceVerbiage]);
    }];
}


+ (void)setConfigurationQueueWithDelegate:(id)delegate
                          withContentDict:(NSDictionary *)dict
                               queueArray:(NSArray*)requestArray
                          completionBlock:(void(^)(BOOL success,NSString *errorString))block
                             failureBlock:(void(^)(NSError* error))failBlock{
    
    NSString *authToken = [NSString stringWithFormat:@"%@ %@",dict[@"token_type"],dict[@"access_token"]];
    
    NSDictionary *menuItemsServiceDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                     BASE_URL_CONFIGURATION_NS_CONGIG_WITH_CLIENT_ID_AND_SERVICE_NAME(CLIENT_APP_CONTROLLER,[ShareOneUtility getClientApplicationID],CONFIG_MENU_ITEMS_SERVICE),REQ_URL,
                                          RequestType_GET,REQ_TYPE,
                                          authToken,REQ_HEADER_CONFIGURATION,
                                          nil,REQ_PARAM,
                                          nil];
    
    NSDictionary *clientSettingsServiceDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                   BASE_URL_CONFIGURATION_NS_CONGIG_WITH_CLIENT_ID_AND_SERVICE_NAME(CLIENT_APP_CONTROLLER,[ShareOneUtility getClientApplicationID],CONFIG_CLIENT_SETTINGS_SERVICE),REQ_URL,
                                           RequestType_GET,REQ_TYPE,
                                           authToken,REQ_HEADER_CONFIGURATION,
                                           nil,REQ_PARAM,
                                           nil];
    
    NSDictionary *StyleValuesServiceDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                    BASE_URL_CONFIGURATION_NS_CONGIG_WITH_CLIENT_ID_AND_SERVICE_NAME(CLIENT_APP_CONTROLLER,[ShareOneUtility getClientApplicationID],CONFIG_STYLE_VALUES_SERVICE),REQ_URL,
                                        RequestType_GET,REQ_TYPE,
                                        authToken,REQ_HEADER_CONFIGURATION,
                                        nil,REQ_PARAM,
                                        nil];
    
    NSDictionary *ApiSettingsServiceDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                    BASE_URL_CONFIGURATION_NS_CONGIG_WITH_CLIENT_ID_AND_SERVICE_NAME(CLIENT_APP_CONTROLLER,[ShareOneUtility getClientApplicationID],CONFIG_API_SETTINGS_SERVICE),REQ_URL,
                                        RequestType_GET,REQ_TYPE,
                                        authToken,REQ_HEADER_CONFIGURATION,
                                        nil,REQ_PARAM,
                                        nil];
    
    
    NSMutableArray * reqArray = [NSMutableArray array];
    
    for (NSString * request in requestArray){
    
        if ([request isEqualToString:@"menu_item"]){
            [reqArray addObject:menuItemsServiceDict];
        }
        else if ([request isEqualToString:@"client_setting"]){
            [reqArray addObject:clientSettingsServiceDict];
        }
        else if ([request isEqualToString:@"style_value"]){
            [reqArray addObject:StyleValuesServiceDict];
        }
        else if ([request isEqualToString:@"nsapi_setting"]){
            [reqArray addObject:ApiSettingsServiceDict];
        }
    }
    
    
    [[AppServiceModel sharedClient] createBatchOfRequestsWithObject:[reqArray copy] requestCompletionBlock:^(NSObject *response,id responseObj) {
        
        NSURLResponse *responseCast = (NSURLResponse *)responseObj;
        
        if([[responseCast.URL absoluteString] containsString:CONFIG_MENU_ITEMS_SERVICE]){
            [ShareOneUtility writeDataToPlistFileWithJSON:(NSDictionary *)response AndFileName:[NSString stringWithFormat:@"%@.plist",CONFIG_MENU_ITEMS_SERVICE]];
        }
        
        if([[responseCast.URL absoluteString] containsString:CONFIG_CLIENT_SETTINGS_SERVICE]){
            [ShareOneUtility writeDataToPlistFileWithJSON:(NSDictionary *)response AndFileName:[NSString stringWithFormat:@"%@.plist",CONFIG_CLIENT_SETTINGS_SERVICE]];
        }

        if([[responseCast.URL absoluteString] containsString:CONFIG_STYLE_VALUES_SERVICE]){
            [ShareOneUtility writeDataToPlistFileWithJSON:(NSDictionary *)response AndFileName:[NSString stringWithFormat:@"%@.plist",CONFIG_STYLE_VALUES_SERVICE]];
        }
        if([[responseCast.URL absoluteString] containsString:CONFIG_API_SETTINGS_SERVICE]){
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary *)response];
            
            //Will be reset as constant from app.
//            [dict setObject:Client_Private_key forKey:@"PrivateKey"];
//            [dict setObject:Client_Public_key forKey:@"PublicKey"];
           
            [ShareOneUtility writeDataToPlistFileWithJSON:(NSDictionary *)dict AndFileName:[NSString stringWithFormat:@"%@.plist",CONFIG_API_SETTINGS_SERVICE]];
        }


    } requestFailureBlock:^(NSError *error) {
        
    } queueCompletionBlock:^(BOOL sucess,NSString *errorString) {
        
        [ShareOneUtility configDataSaved];
        block(sucess,errorString);
        
        
    } queueFailureBlock:^(NSError *error) {
        block(FALSE,[Configuration getMaintenanceVerbiage]);
    }];
}



@end
