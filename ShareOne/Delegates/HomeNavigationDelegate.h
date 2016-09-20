//
//  HomeNavigationDelegate.h
//  ShareOne
//
//  Created by Qazi Naveed on 20/09/2016.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HomeNavigationDelegate <NSObject>

- (void)pushViewControllerWithObject:(NSDictionary *)dict;

@end
