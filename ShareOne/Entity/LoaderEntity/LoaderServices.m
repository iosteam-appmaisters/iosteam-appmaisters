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

+(void)setRequestOnQueueWithDelegate:(id)delegate completionBlock:(void(^)(BOOL success,NSString *errorString))block failureBlock:(void(^)(NSError* error))failBlock{
    
    
    NSDictionary *getDevicesDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@/%@/%@",KWEB_SERVICE_BASE_URL,KMEMBER_DEVICES,[[[SharedUser sharedManager] userObject] ContextID]],REQ_URL,RequestType_GET,REQ_TYPE,[ShareOneUtility getAuthHeaderWithRequestType:RequestType_GET],REQ_HEADER,nil,REQ_PARAM, nil];
    
    
    NSDictionary *getSuffixDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@/%@/%@",KWEB_SERVICE_BASE_URL,KSUFFIX_INFO,[[[SharedUser sharedManager] userObject] ContextID]],REQ_URL,RequestType_GET,REQ_TYPE,[ShareOneUtility getAuthHeaderWithRequestType:RequestType_GET],REQ_HEADER,nil,REQ_PARAM, nil];
    
    
    NSDictionary *getQBDict = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@/%@/%@",KWEB_SERVICE_BASE_URL,KQUICK_BALANCES,[ShareOneUtility getUUID]]
,REQ_URL,RequestType_GET,REQ_TYPE,[ShareOneUtility getAuthHeaderWithRequestType:RequestType_GET],REQ_HEADER,nil,REQ_PARAM, nil];

    
    
    NSArray *reqArr = [NSArray arrayWithObjects:getDevicesDict,getSuffixDict, nil];
    
    
    [[AppServiceModel sharedClient] createBatchOfRequestsWithObject:reqArr requestCompletionBlock:^(NSObject *response, NSString *responseObj) {
        
        NSURLResponse *responseCast = (NSURLResponse *)responseObj;

        if([[responseCast.URL absoluteString] containsString:KMEMBER_DEVICES])

//        if([responseObj containsString:KMEMBER_DEVICES])
        {
            NSArray *arr = [MemberDevices getMemberDevices:(NSDictionary *)response];
            [[SharedUser sharedManager] setMemberDevicesArr:arr];
        }
        if([[responseCast.URL absoluteString] containsString:KSUFFIX_INFO])

//        if([responseObj containsString:KSUFFIX_INFO])
        {
            NSArray *suffixArr = [SuffixInfo getSuffixArrayWithObject:(NSDictionary *)response];
            [[SharedUser sharedManager] setSuffixInfoArr:suffixArr];
        }
        if([[responseCast.URL absoluteString] containsString:KQUICK_BALANCES])

//        if([responseObj containsString:KQUICK_BALANCES])
        {
            NSArray *qbObjects = [QuickBalances  getQBObjects:(NSDictionary *)response];
            [ShareOneUtility savedSufficInfoLocally:(NSDictionary *)response];
            [[SharedUser sharedManager] setQBSectionsArr:qbObjects];
        }


    } requestFailureBlock:^(NSError *error) {
        
    } queueCompletionBlock:^(BOOL sucess,NSString *errorString) {
        block(sucess,errorString);
        
    } queueFailureBlock:^(NSError *error) {
        
    }];
}

+(void)setQTRequestOnQueueWithDelegate:(id)delegate AndQuickBalanceArr:(NSArray *)qbArr completionBlock:(void(^)(BOOL success,NSString *errorString))block failureBlock:(void(^)(NSError* error))failBlock{
    
    NSMutableArray *queuReqArr = [[NSMutableArray alloc] init];
    [qbArr enumerateObjectsUsingBlock:^(QuickBalances *object, NSUInteger idx, BOOL *stop) {
        
        NSString *url = [NSString stringWithFormat:@"%@/%@/%@/%d/%@",KWEB_SERVICE_BASE_URL,KQUICK_TRANSACTION,[ShareOneUtility getUUID],[object.SuffixID intValue] ,kNO_OF_TRANSACTION];

        [queuReqArr addObject:[NSDictionary dictionaryWithObjectsAndKeys:url,REQ_URL,RequestType_GET,REQ_TYPE,[ShareOneUtility getAuthHeaderWithRequestType:RequestType_GET],REQ_HEADER,nil,REQ_PARAM, nil]];
    }];
    
    [[AppServiceModel sharedClient] createBatchOfRequestsWithObject:queuReqArr requestCompletionBlock:^(NSObject *response, NSString *responseObj) {
        
        
        NSURLResponse *responseCast = (NSURLResponse *)responseObj;
        NSString *url = responseCast.URL.absoluteString;

        NSArray *urlCompArr = [url  componentsSeparatedByString:@"/"];
        NSString *suffixID = urlCompArr[[urlCompArr count]-2];
        
        NSPredicate *suffixPredicate = [NSPredicate predicateWithFormat:@"SuffixID = %d",[suffixID intValue]];
        
        NSArray *filteredQBArr = [qbArr filteredArrayUsingPredicate:suffixPredicate];
        
        if([filteredQBArr count]>0){
            
            QuickBalances *obj = filteredQBArr[0];
            NSArray *qtObjects = [QuickTransaction  getQTObjects:(NSDictionary *)response];
            obj.transArr=[qtObjects mutableCopy];
        }
        

        
    } requestFailureBlock:^(NSError *error) {
        
    } queueCompletionBlock:^(BOOL sucess,NSString *errorString) {
        block(sucess,errorString);
    } queueFailureBlock:^(NSError *error) {
        
    }];
    
}

@end
