//
//  FormPostHandler.m
//  VMB
//
//  Created by Vertifi Software, LLC
//
//-------------------------------------------------------------------------------------------------------------------------------------------------
// License:
//
// Copyright (c) 2016 Vertifi Software, LLC
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
// USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//--------------------------------------------------------------------------------------------------------------------------------------------------


#import "VIPSampleAppDelegate.h"
#import "FormPostHandler.h"

@implementation FormPostHandler
@synthesize dataReceive;
@synthesize task;

- (instancetype) init
{
    if ((self = [super init]) != nil)
    {
        depositModel = [DepositModel sharedInstance];
    }
    return (self);
}

//------------------------------------------------------------------------------------------
//
// urlSession property
//
// NSURLSession
//
//------------------------------------------------------------------------------------------

- (NSURLSession *)urlSession
{
    static NSURLSession *session = nil;
    static dispatch_once_t onceSessionToken;
    dispatch_once(&onceSessionToken, ^
    {
        depositModel = [DepositModel sharedInstance];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        [config setRequestCachePolicy:NSURLRequestReloadIgnoringCacheData];
        session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    });
    
    return (session);
}

//------------------------------------------------------------------------------------------
//
// postBackgroundFormWithRequest
//
// post message (form) to URL, call completion handler block when done
//
//------------------------------------------------------------------------------------------

- (void) postBackgroundFormWithRequest:(MultipartForm *)form toURL:(NSURL *)url completion:(PostHandlerCompletion)handler
{
    if (self.task)
        return;
    
    depositModel = [DepositModel sharedInstance];
    
    //-------------------------------------------------------------------------------------
    // POST request
    //-------------------------------------------------------------------------------------
    
    NSMutableURLRequest *postRequest = [form mpfRequest];
    
    // Adding header information
    [postRequest setHTTPMethod:@"POST"];
    
    //
#ifdef DEBUG
    NSLog(@"%@ postBackgroundFormWithRequst %@ : %@", self.class, url, form);       // log
#endif
    
    VIPSampleAppDelegate *app = [UIApplication sharedApplication].delegate;
    [app sessionOpen];
    
    self.task = [self.urlSession dataTaskWithRequest:postRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
#ifdef DEBUG
        NSLog(@"%@ postBackgroundFormWithRequest response %@",self.class, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
#endif
        
        [app sessionClose];
        
        if (error == nil)
        {
            handler(YES, data, nil);
        }
        else
        {
            handler(NO, nil, [NSError errorWithDomain:[error localizedDescription] code:kVIP_MESSAGE_STATUS_CONNECTION_ERROR userInfo:nil]);
        }
        
    }];
    
    [task resume];
    
    return;
}

//------------------------------------------------------------------------------------------
//
// getURLFromHost: withPath:
//
// get a URL from app bundle by key name
//
//------------------------------------------------------------------------------------------

- (NSURL *) getURLFromHost:(NSString *)host withPath:(NSString *)path;
{
    return ([NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", host, path]]);
}

@end
