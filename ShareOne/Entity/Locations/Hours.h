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

+(NSMutableArray *) parseHours:(NSArray *)hoursArr;

@end
