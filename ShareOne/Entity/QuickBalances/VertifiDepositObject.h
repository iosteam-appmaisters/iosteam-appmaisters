//
//  VertifiDepositObject.h
//  ShareOne
//
//  Created by Qazi Naveed on 11/25/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VertifiDepositObject : NSObject


@property (nonatomic,strong)NSString *Account_Number;
@property (nonatomic,strong)NSString *Acct_Description;
@property (nonatomic,strong)NSString *Amount;
@property (nonatomic,strong)NSString *Create_Timestamp;
@property (nonatomic,strong)NSString *Deposit_ID;
@property (nonatomic,strong)NSString *Deposit_Status;
@property (nonatomic,strong)NSString *Items;
@property (nonatomic,strong)NSString *Notes;
@property (nonatomic,strong)NSString *Release_Timestamp;
@property (nonatomic,strong)NSString *Release_Timestamp_UTC;
@property (nonatomic,strong)NSString *Source_Type;


-(id) initWithDictionary:(NSDictionary *)dict;

+(VertifiDepositObject *)parseDeposit:(NSDictionary *)dict;

@end
