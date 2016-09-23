//
//  ShareOneUtility.h
//  ShareOne
//
//  Created by Qazi Naveed on 20/09/2016.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UtilitiesHelper.h"


@interface ShareOneUtility : UtilitiesHelper

+ (NSArray *)getSideMenuDataFromPlist;

+ (NSArray *)getDummyDataForQB;
+(NSMutableArray*)getLocationArray;
@end
