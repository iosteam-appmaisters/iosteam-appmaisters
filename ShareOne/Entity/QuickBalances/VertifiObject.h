//
//  VertifiObject.h
//  ShareOne
//
//  Created by Qazi Naveed on 11/9/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VertifiDepositObject.h"

@interface VertifiObject : NSObject

@property (nonatomic,strong) NSString *InputValidation;
@property (nonatomic,strong) NSString *LoginValidation;
@property (nonatomic,strong) NSString *SSOKey;
@property (nonatomic,strong) NSString *Deposit_ID;
@property (nonatomic,strong) NSString *URL;
@property (nonatomic,strong) NSString *DepositStatus;
@property (nonatomic,strong) NSArray *depositArr;
@property (nonatomic,strong) NSString *EUAContents;
@property (nonatomic,strong) NSString *focbase64String;
@property (nonatomic,strong) NSString *bocbase64String;
@property (nonatomic,strong) NSString *DepositLimit;
@property (nonatomic,strong) NSDictionary *imageDictionary;
@property (nonatomic,strong) NSString *DepositIDCurrentCheck;
@property (nonatomic,strong) NSString *CARAmount;
@property (nonatomic,strong) NSString *CARMismatch;
@property (nonatomic,strong) NSString *deletedError;
@property (nonatomic,strong) NSString *dupSuspectUsability;



+(NSArray *)parseAllDepositsWithObject:(NSArray *)array;
@end
