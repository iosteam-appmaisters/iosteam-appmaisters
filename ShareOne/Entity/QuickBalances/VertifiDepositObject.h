//
//  VertifiDepositObject.h
//  ShareOne
//
//  Created by Qazi Naveed on 11/25/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VertifiDepositObject : NSObject


@property (nonatomic,strong)NSString *Account_number;
@property (nonatomic,strong)NSString *Acct_description;
@property (nonatomic,strong)NSString *Amount;
@property (nonatomic,strong)NSString *Create_timestamp;
@property (nonatomic,strong)NSString *Deposit_id;
@property (nonatomic,strong)NSString *Deposit_status;
@property (nonatomic,strong)NSString *Items;
@property (nonatomic,strong)NSString *Notes;
@property (nonatomic,strong)NSString *Release_timestamp;
@property (nonatomic,strong)NSString *Release_timestamp_UTC;
@property (nonatomic,strong)NSString *Source_type;
@property (nonatomic,strong)NSDictionary *image_dict;



-(id) initWithDictionary:(NSDictionary *)dict;

+(VertifiDepositObject *)parseDeposit:(NSDictionary *)dict;

@end
