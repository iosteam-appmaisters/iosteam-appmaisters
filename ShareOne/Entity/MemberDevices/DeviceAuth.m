//
//  DeviceAuth.m
//  ShareOne
//
//  Created by Qazi Naveed on 25/10/2016.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "DeviceAuth.h"

@implementation DeviceAuth

+(NSMutableArray *)getDeviceAuthArrWithObject :(NSDictionary *)dict{
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    NSArray *contentArr = dict[@"Authorizations"];
    
    [contentArr enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        DeviceAuth *objDeviceAuth = [[DeviceAuth alloc] initWithDictionary:obj];
        [arr addObject:objDeviceAuth];
    }];
    return arr;
}


-(id) initWithDictionary:(NSDictionary *)dict{
    self = [super init];{
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}
@end
