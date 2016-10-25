//
//  HTTPRequestOperation.h
//  ShareOne
//
//  Created by Qazi Naveed on 24/10/2016.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HTTPRequestOperation : NSObject

@property (nonatomic, strong, readonly) NSMutableURLRequest *request;

@property (nonatomic, copy) void (^completionBlock)(NSURLResponse *response, id responseObject, NSError * error);

- (instancetype)initWithRequest:(NSMutableURLRequest *)request;
@end
