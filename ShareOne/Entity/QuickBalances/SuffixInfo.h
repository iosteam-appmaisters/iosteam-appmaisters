//
//  SuffixInfo.h
//  ShareOne
//
//  Created by Qazi Naveed on 17/10/2016.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SuffixInfo : NSObject

@property (nonatomic,strong) NSString *Access;
@property (nonatomic,strong) NSNumber *Account;
@property (nonatomic,strong) NSNumber *Available;
@property (nonatomic,strong) NSNumber *Balance;
@property (nonatomic,strong) NSNumber *Class;
@property (nonatomic,strong) NSString *DefaultDescr;
@property (nonatomic,strong) NSNumber *DefaultTransfer;
@property (nonatomic,strong) NSString *Descr;
@property (nonatomic,strong) NSNumber *Hidden;
@property (nonatomic,strong) NSNumber *OptInATM;
@property (nonatomic,strong) NSNumber *Primary;
@property (nonatomic,strong) NSNumber *RegD;
@property (nonatomic,strong) NSNumber *RptCode;
@property (nonatomic,strong) NSNumber *SuffixID;
@property (nonatomic,strong) NSNumber *SuffixNumber;
@property (nonatomic,strong) NSDictionary *TaxInfo;
@property (nonatomic,strong) NSString *Type;
@property (nonatomic,strong) NSMutableArray *Cards;
@property (nonatomic,strong) NSString *DraftXRef;
@property (nonatomic,strong) NSString *Draft;
@property (nonatomic,strong) NSString *Maturity;
@property (nonatomic,strong) NSString *PastDue;
@property (nonatomic,strong) NSString *NextPayAmt;
@property (nonatomic,strong) NSString *NextPayDate;
@property (nonatomic,strong) NSString *Payoff;
@property (nonatomic,strong) NSString *TotDue;
@property (nonatomic,strong) NSString *Closed;
@property (nonatomic,strong) NSString *CreditCard;
@property (nonatomic,strong) NSMutableArray *transArray;



-(id) initWithDictionary:(NSDictionary *)dict;


+(NSMutableArray *)getSuffixArrayWithObject:(NSDictionary *)dict;


+(void)getSuffixInfo:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(NSObject *user))block failureBlock:(void(^)(NSError* error))failBlock;

+(void)postSuffixInfo:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(NSObject *user))block failureBlock:(void(^)(NSError* error))failBlock;




@end
