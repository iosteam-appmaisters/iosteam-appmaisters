//
//  DeviceAuth.h
//  ShareOne
//
//  Created by Qazi Naveed on 25/10/2016.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceAuth : NSObject
@property (nonatomic,strong) NSString *AuthorizingDateTime;
@property (nonatomic,strong) NSNumber *AuthorizingUser;
@property (nonatomic,strong) NSString *ID;
@property (nonatomic,strong) NSNumber *Source;
@property (nonatomic,strong) NSNumber *Status;
@property (nonatomic,strong) NSNumber *Type;


+(NSMutableArray *)getDeviceAuthArrWithObject :(NSDictionary *)dict;


-(id) initWithDictionary:(NSDictionary *)dict;



@end
