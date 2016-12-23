//
//  Address.h
//  ShareOne
//
//  Created by Qazi Naveed on 12/19/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Address : NSObject


@property(nonatomic,strong) NSString *Address1;
@property(nonatomic,strong) NSString *Address2;
@property(nonatomic,strong) NSString *Address3;
@property(nonatomic,strong) NSString *City;
@property(nonatomic,strong) NSString *State;
@property(nonatomic,strong) NSString *Postalcode;
@property(nonatomic,strong) NSString *Country;


-(id) initWithDictionary:(NSDictionary *)hoursDict;


@end
