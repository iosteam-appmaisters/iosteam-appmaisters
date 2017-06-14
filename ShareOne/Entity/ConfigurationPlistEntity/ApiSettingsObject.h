//
//  ApiSettingsObject.h
//  ShareOne
//
//  Created by Qazi Naveed on 6/8/17.
//  Copyright © 2017 Ali Akbar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApiSettingsObject : NSObject

@property (nonatomic,strong) NSString *ApplicationName;
@property (nonatomic,strong) NSMutableArray *ClientApplications;
@property (nonatomic,strong) NSString *CreatedDTM;
@property (nonatomic,strong) NSString *HMACType;
@property (nonatomic,strong) NSString *HostName;
@property (nonatomic,strong) NSString *ID;
@property (nonatomic,strong) NSString *PrivateKey;
@property (nonatomic,strong) NSString *PublicKey;
@property (nonatomic,strong) NSString *SecurityVersion;
@property (nonatomic,strong) NSString *UpdatedDTM;

+(ApiSettingsObject *)parseClientSettings:(NSDictionary *)dict;
-(id) initWithDictionary:(NSDictionary *)dict;


@end
