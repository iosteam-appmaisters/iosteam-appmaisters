//
//  ClientApplicationsObject.m
//  ShareOne
//
//  Created by Qazi Naveed on 8/17/17.
//  Copyright © 2017 Ali Akbar. All rights reserved.
//

#import "ClientApplicationsObject.h"

@implementation ClientApplicationsObject

-(id) initWithDictionary:(NSDictionary *)dict{
    
    self = [super init];{
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}
@end
