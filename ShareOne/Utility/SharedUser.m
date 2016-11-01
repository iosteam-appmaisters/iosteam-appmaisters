//
//  SharedUser.m
//  ShareOne
//
//  Created by Qazi Naveed on 05/10/2016.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "SharedUser.h"

@implementation SharedUser

#pragma mark Singleton Methods

+ (id)sharedManager {
    static SharedUser *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        _memberDevicesArr =[[NSArray alloc] init];
        _suffixInfoArr = [[NSArray alloc] init];
        _QBSectionsArr = [[NSArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end
