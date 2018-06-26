//
//  Location.m
//  ShareOne
//
//  Created by Qazi Naveed on 19/10/2016.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "Location.h"
#import "AppServiceModel.h"
#import "Services.h"
#import "ShareOneUtility.h"
#import "SharedUser.h"
#import "ConstantsShareOne.h"


@implementation Location

+(void)getAllBranchLocations:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(NSArray *locations))block failureBlock:(void(^)(NSError* error))failBlock{
    
    NSString *urlString =kLOCATION_API;

    [[AppServiceModel sharedClient] getMethod:nil AndParam:param progressMessage:nil urlString:[NSString stringWithFormat:@"%@",urlString] delegate:delegate completionBlock:^(NSObject *response) {
        
        if([response isKindOfClass:[NSDictionary class]]){
            block([self parseAllLocationsWithObject:(NSDictionary *)response]);
        }
        
    } failureBlock:^(NSError *error) {
        
    }];
    
}

+(void)getShareOneBranchLocations:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(NSArray *locations))block failureBlock:(void(^)(NSError* error))failBlock{
    
    NSString *signature =[ShareOneUtility getAuthHeaderWithRequestType:RequestType_GET];

    [[AppServiceModel sharedClient] getMethod:signature AndParam:nil progressMessage:nil urlString:[NSString stringWithFormat:@"%@/%@/%@",[ShareOneUtility getBaseUrl],KBRANCH_LOCATIONS,[[[SharedUser sharedManager] userObject] Contextid]] delegate:delegate completionBlock:^(NSObject *response) {
        //[ShareOneUtility convertDicToJSON:(NSDictionary*)response];
        if([response isKindOfClass:[NSDictionary class]]){
            block([self parseAllShareOneLocationsWithObject:(NSDictionary *)response]);
        }

        
    } failureBlock:^(NSError *error) {}];

}


+(NSMutableArray *)parseAllLocationsWithObject:(NSDictionary *)dictionary{
    NSMutableArray *locationArr = [[NSMutableArray alloc] init];
    
    
    NSArray *rawDataArr = dictionary[@"response"][@"locations"];
    NSDictionary *rawErrorDict ;
    BOOL statusFailed = NO ;
    if(dictionary[@"response"][@"exceptions"]) {
        rawErrorDict  = dictionary[@"response"][@"exceptions"][0];
        statusFailed = ([dictionary[@"response"][@"status"] isEqualToString:@"FAILED"]);
    }
    
    
    if(statusFailed==NO){
        [rawDataArr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            Location *objLocation = [[Location alloc] initWithDictionary:obj];
            [locationArr addObject:objLocation];
            
        }];
        
        return locationArr ;
    }
    else {
        NSMutableArray *errArr ;
        errArr = [[NSMutableArray alloc] init];
        NSNumber *errorCode = [NSNumber numberWithInt:[rawErrorDict[@"errorCode"] intValue]];
        [errArr addObject:errorCode];
        if([errorCode intValue]==CO_OP_API_KEY_INVALID_ERROR_CODE){
            [errArr addObject:CO_OP_API_KEY_INVALID_ERROR_MSG];
         }
        else {
            [errArr addObject:rawErrorDict[@"detail"]];
        }
        
        return errArr ;
    }
    return [NSMutableArray new];
}

+(NSMutableArray *)parseAllShareOneLocationsWithObject:(NSDictionary *)dictionary{
    NSMutableArray *locationArr = [[NSMutableArray alloc] init];
    
    
    NSArray *rawDataArr = dictionary[@"Branches"];
//    NSLog(@"%@",rawDataArr);
    [rawDataArr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        Location *objLocation = [[Location alloc] initWithDictionary:obj];
        
        NSDictionary *addresDict =[obj valueForKey:@"Address"];
        NSArray *hoursArr =[obj valueForKey:@"Hours"];
        NSArray *photosArr =[obj valueForKey:@"Photos"];

        if([addresDict isKindOfClass:[NSDictionary class]])
            objLocation.address= [[Address alloc] initWithDictionary:addresDict];
        
        if([hoursArr isKindOfClass:[NSArray class]])
            objLocation.hours= [Hours parseHours:hoursArr];
        
        if([photosArr isKindOfClass:[NSArray class]])
            objLocation.photos= [Photos parsePhotos:photosArr];
        

        [locationArr addObject:objLocation];
        
    }];
    return locationArr;
}


-(id) initWithDictionary:(NSDictionary *)locationDict{
    
    Location *obj = [[Location alloc] init];
    
    for (NSString* key in locationDict) {
        id value = [locationDict objectForKey:key];
        
        //            NSLog(@"locationDict : %@",locationDict);
        SEL selector = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", [[key substringToIndex:1] uppercaseString], [[key substringFromIndex:1] lowercaseString]]);
        //                                NSLog(@"Selector Name: %@ Value :%@",NSStringFromSelector(selector),value);
        if (value != [NSNull null]) {
            if ([obj respondsToSelector:selector]) {
                
#       pragma clang diagnostic push
#       pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                [obj performSelector:selector withObject:value];
#       pragma clang diagnostic pop
            }
        }
    }
    
    return obj;
}


@end
