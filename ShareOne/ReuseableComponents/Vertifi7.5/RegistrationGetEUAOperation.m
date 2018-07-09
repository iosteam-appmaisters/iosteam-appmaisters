//
//  RegistrationGetEUAOperation.m
//  VIPSample
//
//  Created by Vertifi Software, LLC
//
//-------------------------------------------------------------------------------------------------------------------------------------------------
// License:
//
// Copyright (c) 2018 Vertifi Software, LLC
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

#import "RegistrationGetEUAOperation.h"
#import "MultiPartForm.h"
#import "FormPostHandler.h"
#import "RegistrationQueryDelegate.h"

@implementation RegistrationGetEUAOperation

@synthesize depositModel;

- (instancetype) init
{
    if ((self = [super init]) != nil)
    {
        self.depositModel = [DepositModel sharedInstance];
    }
    return (self);
}

- (void) dealloc
{
#ifdef DEBUG
    NSLog(@"%@ dealloc",self.class);
#endif
}

- (void) main
{
    // get selected account
    DepositAccount *account = (DepositAccount *)[depositModel.depositAccounts objectAtIndex:depositModel.depositAccountSelected];
    
    // must have valid account with MAC and requestor
    if ((account == nil) || (account.MAC == nil) || (depositModel.requestor == nil))
        return;
    
    // URL request
    FormPostHandler *postHandler = [[FormPostHandler alloc] init];
    NSURL *postURL = [postHandler getURLFromHost:[depositModel.dictSettings valueForKey:@"URL_RDCHost"] withPath:[depositModel.dictSettings valueForKey:@"Path_RegistrationGetEUA"]];
    
    MultipartForm *form = [[MultipartForm alloc] initWithURL:postURL];
    
    // fields
    [form addFormField:@"requestor" withStringData:depositModel.requestor];
    [form addFormField:@"session" withStringData:account.session];
    [form addFormField:@"timestamp" withStringData:account.timestamp];
    [form addFormField:@"routing" withStringData:depositModel.routing];
    [form addFormField:@"member" withStringData:account.member];
    [form addFormField:@"account" withStringData:account.account];
    [form addFormField:@"MAC" withStringData:account.MAC];
    
    if ([self isCancelled])
    {
#ifdef DEBUG
        NSLog(@"%@ Cancelled",self.class);
#endif
        return;
    }
    
    __block dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    // send Notification at completion
    self.completionBlock = ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kVIP_NOTIFICATION_DEPOSIT_REGISTRATION_QUERY_COMPLETE object:nil];
    };
    
    // Post the message
    [postHandler postBackgroundFormWithRequest:form toURL:postURL completion:^(BOOL success, NSData *data, NSError *error)
    {
         
        if ([self isCancelled])
        {
#ifdef DEBUG
            NSLog(@"%@ Cancelled",self.class);
#endif
        }
        else if (success)
        {
            // Save XML to debugString, should not be in production app
            if (depositModel.debugMode)
                depositModel.debugString = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            RegistrationQueryDelegate *rqd = [[RegistrationQueryDelegate alloc] init];
            NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:data];
            if (xmlParser != nil)
            {
                // parse the XML
                [xmlParser setDelegate:rqd];
                [xmlParser parse];
            }
        }
        else if (error != nil)
        {
            NSLog(@"%@ connection failed: %@ ; %@", self.class, [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
        }
        
        // SIGNAL
        dispatch_semaphore_signal(semaphore);
         
    }];
    
    // WAIT
    dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(120 * NSEC_PER_SEC));
    dispatch_semaphore_wait(semaphore, time);
    
    return;
}


@end
