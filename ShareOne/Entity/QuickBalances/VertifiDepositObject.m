//
//  VertifiDepositObject.m
//  ShareOne
//
//  Created by Qazi Naveed on 11/25/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "VertifiDepositObject.h"

@implementation VertifiDepositObject


-(id) initWithDictionary:(NSDictionary *)dict{
    
    self = [super init];{
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
    
}
+(VertifiDepositObject *)parseDeposit:(NSDictionary *)dict{
 
    VertifiDepositObject *obj = [[VertifiDepositObject alloc] initWithDictionary:dict];
    return obj;
}

@end
