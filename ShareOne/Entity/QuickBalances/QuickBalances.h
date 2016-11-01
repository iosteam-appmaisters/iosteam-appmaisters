//
//  QuickBalances.h
//  ShareOne
//
//  Created by Qazi Naveed on 17/10/2016.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuickBalances : NSObject

@property (nonatomic,strong) NSString *Account;
@property (nonatomic,strong) NSNumber *Balance;
@property (nonatomic,strong) NSNumber *Class;
@property (nonatomic,strong) NSString *PastDue;
@property (nonatomic,strong) NSString *Payoff;
@property (nonatomic,strong) NSNumber *SuffixID;
@property (nonatomic,strong) NSNumber *SuffixNumber;
@property (nonatomic,strong) NSString *TotDue;
@property (nonatomic,strong) NSString *Type;
@property (nonatomic,strong) NSNumber *Available;





+(void)getAllBalances:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(NSObject *user))block failureBlock:(void(^)(NSError* error))failBlock;


+(void)getAllQuickTransaction:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(NSObject *user))block failureBlock:(void(^)(NSError* error))failBlock;

-(id) initWithDictionary:(NSDictionary *)dict;

+(NSMutableArray *)getQBObjects:(NSDictionary *)dict;



@end
