//
//  Hours.h
//  ShareOne
//
//  Created by Qazi Naveed on 12/19/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Hours : NSObject

@property(nonatomic,strong) NSNumber *DayNumber;
@property(nonatomic,strong) NSNumber *LobbyIsOpen;
@property(nonatomic,strong) NSString *LobbyOpenTime;
@property(nonatomic,strong) NSString *LobbyCloseTime;
@property(nonatomic,strong) NSNumber *DriveThruIsOpen;
@property(nonatomic,strong) NSString *DriveThruOpenTime;
@property(nonatomic,strong) NSString *DriveThruCloseTime;

-(id) initWithDictionary:(NSDictionary *)hoursDict;

@end
