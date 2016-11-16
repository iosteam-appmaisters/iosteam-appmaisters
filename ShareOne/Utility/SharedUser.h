//
//  SharedUser.h
//  ShareOne
//
//  Created by Qazi Naveed on 05/10/2016.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"


@interface SharedUser : NSObject

@property (nonatomic, strong) User *userObject;

@property(nonatomic,strong) NSArray *memberDevicesArr;
@property(nonatomic,strong) NSArray *suffixInfoArr;
@property(nonatomic,strong) NSArray *QBSectionsArr;
@property BOOL skipTouchIDForJustLogOut;


+ (id)sharedManager;


@end
