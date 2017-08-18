//
//  ClientApplicationsObject.h
//  ShareOne
//
//  Created by Qazi Naveed on 8/17/17.
//  Copyright © 2017 Ali Akbar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClientApplicationsObject : NSObject

@property (nonatomic,strong)NSNumber *ClientApplicationTypeID;
@property (nonatomic,strong)NSNumber *CustomerEnvironmentTypeID;
@property (nonatomic,strong)NSNumber *CustomerID;
@property (nonatomic,strong)NSNumber *ID;
@property (nonatomic,strong)NSString *Name;

-(id) initWithDictionary:(NSDictionary *)dict;

@end
