//
//  QuickTransaction.h
//  ShareOne
//
//  Created by Qazi Naveed on 11/3/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QuickTransaction : NSObject
@property (nonatomic,strong) NSString *Amt;
@property (nonatomic,strong) NSNumber *Bal;
@property (nonatomic,strong) NSString *Eff;
@property (nonatomic,strong) NSString *Hst;
@property (nonatomic,strong) NSNumber *ID;
@property (nonatomic,strong) NSString *OFX;
@property (nonatomic,strong) NSString *Post;
@property (nonatomic,strong) NSString *Prin;
@property (nonatomic,strong) NSString *Tran;
@property (nonatomic, strong) NSString *Desc;




-(id) initWithDictionary:(NSDictionary *)dict;

+(NSMutableArray *)getQTObjects:(NSDictionary *)dict;


@end
