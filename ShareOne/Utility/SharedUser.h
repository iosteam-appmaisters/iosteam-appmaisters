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

+ (id)sharedManager;


@end