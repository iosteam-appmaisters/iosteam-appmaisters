//
//  ApiSettingsObject.m
//  ShareOne
//
//  Created by Qazi Naveed on 6/8/17.
//  Copyright © 2017 Ali Akbar. All rights reserved.
//

#import "ApiSettingsObject.h"

@implementation ApiSettingsObject


-(id) initWithDictionary:(NSDictionary *)dict{
    
    self = [super init];{
    
        self.ApplicationName = dict[@"ApplicationName"];
        self.ClientApplications = dict[@"ClientApplications"];
        self.CreatedDTM = dict[@"CreatedDTM"];
        self.HMACType = dict[@"HMACType"];
        self.HostName = dict[@"HostName"];
        self.ID = dict[@"ID"];
        self.PrivateKey = dict[@"PrivateKey"];
        self.PublicKey = dict[@"PublicKey"];
        self.SecurityVersion = dict[@"SecurityVersion"];
        self.UpdatedDTM = dict[@"UpdatedDTM"];
        
    }
    return self;
}

@end
