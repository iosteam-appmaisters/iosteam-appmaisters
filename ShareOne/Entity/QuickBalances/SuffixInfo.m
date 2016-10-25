//
//  SuffixInfo.m
//  ShareOne
//
//  Created by Qazi Naveed on 17/10/2016.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "SuffixInfo.h"
#import "AppServiceModel.h"
#import "Services.h"
#import "ShareOneUtility.h"
#import "SharedUser.h"


@implementation SuffixInfo

+(void)getSuffixInfo:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(NSObject *user))block failureBlock:(void(^)(NSError* error))failBlock{
    
    NSString *signature =[ShareOneUtility getAuthHeaderWithRequestType:RequestType_GET];
    
    [[AppServiceModel sharedClient] getMethod:signature AndParam:param progressMessage:nil urlString:[NSString stringWithFormat:@"%@/%@/%@",KWEB_SERVICE_BASE_URL,KSUFFIX_INFO,[[[SharedUser sharedManager] userObject] ContextID]] delegate:delegate completionBlock:^(NSObject *response) {
        
        
    } failureBlock:^(NSError *error) {}];
}


+(void)postSuffixInfo:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(NSObject *user))block failureBlock:(void(^)(NSError* error))failBlock{
    
    NSString *signature =[ShareOneUtility getAuthHeaderWithRequestType:RequestType_POST];

    [[AppServiceModel sharedClient] postRequestWithAuthHeader:signature AndParam:param progressMessage:nil urlString:[NSString stringWithFormat:@"%@/%@",KWEB_SERVICE_BASE_URL,kSUFFIZ_PREPHERENCES] delegate:delegate completionBlock:^(NSObject *response) {
        
    } failureBlock:^(NSError *error) {
        
    }];
}

-(id) initWithDictionary:(NSDictionary *)dict{
    
    self = [super init];{
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;

}


+(NSMutableArray *)getSuffixArrayWithObject:(NSDictionary *)dict{
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    NSArray *contentArr = dict[@"Suffixes"];
    
    [contentArr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        SuffixInfo *objSuffixInfo = [[SuffixInfo alloc] initWithDictionary:obj];
        [arr addObject:objSuffixInfo];
        
    }];
    return arr;
}

@end