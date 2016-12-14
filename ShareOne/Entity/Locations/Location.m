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


@implementation Location

+(void)getAllBranchLocations:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(NSArray *locations))block failureBlock:(void(^)(NSError* error))failBlock{
    
//    NSURLComponents *components = [NSURLComponents componentsWithString:[NSString stringWithFormat:@"%@",kLOCATION_API]];
//    NSURLQueryItem *maxRadiud = [NSURLQueryItem queryItemWithName:@"maxRadius" value:@"20"];
//    NSURLQueryItem *maxResults = [NSURLQueryItem queryItemWithName:@"maxResults" value:@"20"];
//    NSURLQueryItem *zip = [NSURLQueryItem queryItemWithName:@"zip" value:@"91730"];
//
//    components.queryItems = @[ maxRadiud, zip,maxResults ];
//    NSString  *urlString = components.URL.absoluteString; // http://stackoverflow.com?q=ios&count=10
    
    
    NSString *urlString =kLOCATION_API;

    [[AppServiceModel sharedClient] getMethod:nil AndParam:param progressMessage:nil urlString:[NSString stringWithFormat:@"%@",urlString] delegate:delegate completionBlock:^(NSObject *response) {
        
        if([response isKindOfClass:[NSDictionary class]]){
            block([self parseAllLocationsWithObject:(NSDictionary *)response]);
        }
        
    } failureBlock:^(NSError *error) {
        
    }];
    
}


+(NSMutableArray *)parseAllLocationsWithObject:(NSDictionary *)dictionary{
    NSMutableArray *locationArr = [[NSMutableArray alloc] init];
    
    
    NSArray *rawDataArr = dictionary[@"response"][@"locations"];
    
    [rawDataArr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        Location *objLocation = [[Location alloc] initWithDictionary:obj];
        [locationArr addObject:objLocation];
        
    }];
    return locationArr;
}


-(id) initWithDictionary:(NSDictionary *)locationDict{
    self = [super init];{
        [self setValuesForKeysWithDictionary:locationDict];
    }
    return self;
}


@end
