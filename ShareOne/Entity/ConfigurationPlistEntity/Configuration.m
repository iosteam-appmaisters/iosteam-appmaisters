//
//  Configuration.m
//  ShareOne
//
//  Created by Qazi Naveed on 2/22/17.
//  Copyright © 2017 Ali Akbar. All rights reserved.
//

#import "Configuration.h"

@implementation Configuration

-(id) initWithDictionary:(NSDictionary *)configurationDict{
    
    self = [super init];{
        [self setValuesForKeysWithDictionary:configurationDict];
    }
    return self;
}

@end
