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
@property (nonatomic,strong) NSString *Pastdue;
@property (nonatomic,strong) NSString *Payoff;
@property (nonatomic,strong) NSNumber *Suffixid;
@property (nonatomic,strong) NSNumber *Suffixnumber;
@property (nonatomic,strong) NSString *Totdue;
@property (nonatomic,strong) NSString *Type;
@property (nonatomic,strong) NSNumber *Available;
@property (nonatomic,strong) NSMutableArray *transArr;
@property (nonatomic,strong) NSString *Descr;


+(void)getAllBalances:(NSDictionary*)param
             delegate:(id)delegate
      completionBlock:(void(^)(NSArray* qbObjects))block
         failureBlock:(void(^)(NSError* error))failBlock;


+(void)getAllQuickTransaction:(NSDictionary*)param
                     delegate:(id)delegate
              completionBlock:(void(^)(NSObject *user))block
                 failureBlock:(void(^)(NSError* error))failBlock;

-(id) initWithDictionary:(NSDictionary *)dict;

+(NSMutableArray *)getQBObjects:(NSDictionary *)dict;



@end
