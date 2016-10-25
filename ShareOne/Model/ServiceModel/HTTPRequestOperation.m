//
//  HTTPRequestOperation.m
//  ShareOne
//
//  Created by Qazi Naveed on 24/10/2016.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "HTTPRequestOperation.h"

@implementation HTTPRequestOperation

- (instancetype)initWithRequest:(NSMutableURLRequest *)request{
    
    _request=request;
    
    return self;
}

@end
