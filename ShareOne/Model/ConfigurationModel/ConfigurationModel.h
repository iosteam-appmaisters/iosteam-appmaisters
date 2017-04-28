//
//  ConfigurationModel.h
//  ShareOne
//
//  Created by Qazi Naveed on 1/31/17.
//  Copyright © 2017 Ali Akbar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppServiceModel.h"
#import "Services.h"
#import "UtilitiesHelper.h"
#import "ConstantsShareOne.h"
#import "ShareOneUtility.h"
#import "SharedUser.h"


@interface ConfigurationModel : NSObject
+(NSMutableArray *)parseMenuItemsWithObject:(NSMutableArray *)sourceArray;
@end
