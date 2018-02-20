//
//  Hours.h
//  ShareOne
//
//  Created by Qazi Naveed on 12/19/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Hours : NSObject

@property(nonatomic,strong) NSNumber *Daynumber;

@property(nonatomic,strong) NSString *Lobbyopentime;
@property(nonatomic,strong) NSString *Lobbyclosetime;

@property(nonatomic,strong) NSString *Drivethruopentime;
@property(nonatomic,strong) NSString *Drivethruclosetime;

@property(nonatomic,strong) NSNumber *Drivethruisopen;
@property(nonatomic,strong) NSNumber *Lobbyisopen;

+(NSMutableArray *) parseHours:(NSArray *)hoursArr;

@end
