//
//  DepositSubmitQueue.m
//  VIPSample
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

#import "DepositSubmitQueue.h"
#import "DepositInitOperation.h"
#import "DepositSubmitOperation.h"

@implementation DepositSubmitQueue

- (NSOperationQueue *)operationQueue
{
    if (operationQueue == nil)
    {
        operationQueue = [[NSOperationQueue alloc] init];
        [operationQueue setMaxConcurrentOperationCount:5];
    }
    return (operationQueue);
}

- (void) setOperationQueue:(NSOperationQueue *)queue
{
    operationQueue = queue;
}

//-----------------------------------------------------------------------------
// init
//-----------------------------------------------------------------------------

- (id) init
{
	if ((self = [super init]) != nil)
	{
        depositModel = [DepositModel sharedInstance];
	}
	return (self);
}

//-----------------------------------------------------------------------------
// cancel
//-----------------------------------------------------------------------------

- (void) onSubmitCancel
{
    if (operationQueue != nil)
        [operationQueue cancelAllOperations];
}

//-----------------------------------------------------------------------------
// Front Image Processing - runs on background thread
//-----------------------------------------------------------------------------

- (void) onSubmitInit
{
    [self onSubmitCancel];                    // cancel any running operations
    
    [depositModel.dictResultsGeneral removeAllObjects];
    [depositModel.dictResultsFrontImage removeAllObjects];
    depositModel.ssoKey = nil;                                      // clear SSO key
    depositModel.depositAmountCAR = [NSNumber numberWithDouble:0];  // clear CAR amount
    
    // use Operation Queue
    DepositInitOperation *carOperation = [[DepositInitOperation alloc] initWithDelegate:self];
    [self.operationQueue addOperation:carOperation];
    
	return;
}

//-----------------------------------------------------------------------------
// Commit Processing - runs on background thread
//-----------------------------------------------------------------------------

- (void) onSubmitCommit
{
    // if front needs to be sent (no SSOKey and no operations in progress)
    if ((depositModel.ssoKey == nil) && (operationQueue.operationCount == 0))
    {
        [self onSubmitInit];
    }

    [depositModel.dictResultsGeneral removeAllObjects];
    [depositModel.dictResultsBackImage removeAllObjects];

    // use Operation Queue
    DepositSubmitOperation *submitOperation = [[DepositSubmitOperation alloc] initWithDelegate:self];
    for (NSOperation *op in self.operationQueue.operations)
    {
        [submitOperation addDependency:op];
    }
    [self.operationQueue addOperation:submitOperation];

	return;
}

//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Delegate callbacks from NSOperations
//-----------------------------------------------------------------------------

//-----------------------------------------------------------------------------
// Front Image processing complete (DOES NOT run on main thread)
//-----------------------------------------------------------------------------

- (void) onSubmitInitDone:(NSDictionary *)dictResults
{
    if (dictResults != nil)
    {
        NSString *str = (NSString *)[dictResults valueForKey:@"SSOKey"];
        if (str != nil)
            depositModel.ssoKey = str;
        else
            depositModel.ssoKey = nil;
        
        str = (NSString *)[dictResults valueForKey:@"CARAmount"];
        if (str != nil)
        {
            depositModel.depositAmountCAR = [NSNumber numberWithDouble:[str doubleValue]];
        }
        
        // for each key in XML results
        NSString *key, *value;
        for (key in dictResults)
        {
            value = (NSString *)[dictResults valueForKey:key];                         // get value
            
#ifdef DEBUG
            NSLog(@"%@ init done: key=%@ value=%@",self.class, key, value);				// log
#endif
            
            if ([value isEqualToString:@"OK"])
                continue;

            if ([value isEqualToString:@"Failed"])
            {
                if ([depositModel.dictMasterFrontImage valueForKey:key] != nil)
                    [depositModel.dictResultsFrontImage setValue:[depositModel.dictMasterFrontImage helpForKey:key] forKey:key];
            }
            
            if ([key isEqualToString:@"InputValidation"])
            {
                [depositModel.dictMasterGeneral setValue:value forKey:key];
                [depositModel.dictMasterGeneral setHelp:value forKey:key];
                if ([value isEqualToString:@"Session Expired"])
                {
                    [depositModel.dictMasterGeneral setHelp:@"Your authentication credentials are no longer valid." forKey:key];
                }
                [depositModel.dictResultsGeneral setValue:[depositModel.dictMasterGeneral valueForKey:key] forKey:key];
            }
            if ([key isEqualToString:@"Database"])
            {
                [depositModel.dictMasterGeneral setHelp:value forKey:key];
                [depositModel.dictResultsGeneral setValue:[depositModel.dictMasterGeneral valueForKey:key] forKey:key];
            }
            if ([key isEqualToString:@"SystemError"])
            {
                [depositModel.dictMasterGeneral setHelp:value forKey:key];
                [depositModel.dictResultsGeneral setValue:[depositModel.dictMasterGeneral valueForKey:key] forKey:key];
            }
            if ([key isEqualToString:@"PreProcessing"])
            {
                [depositModel.dictMasterGeneral setHelp:value forKey:key];
                [depositModel.dictResultsGeneral setValue:[depositModel.dictMasterGeneral valueForKey:key] forKey:key];
            }
            if ([key isEqualToString:@"URLConnectionError"])
            {
                [depositModel.dictMasterGeneral setHelp:[NSString stringWithFormat:@"Internet Connection Error:\n\n%@.", value] forKey:key];
                [depositModel.dictResultsGeneral setValue:[depositModel.dictMasterGeneral valueForKey:key] forKey:key];
            }
            
        }
    
    }
    
	// send notification
	[[NSNotificationCenter defaultCenter] postNotificationName:kVIP_NOTIFICATION_DEPOSIT_INIT_COMPLETE object:nil];
	
	return;
}

//-----------------------------------------------------------------------------
// Commit processing complete (DOES NOT run on main thread)
//-----------------------------------------------------------------------------

- (void) onSubmitCommitDone:(NSDictionary *)dictResults
{
    NSString *key;
    NSString *value;
     
     // for each key in XML results
     for (key in dictResults)
     {
         value = (NSString *)[dictResults valueForKey:key];				// get value
         
#ifdef DEBUG
         NSLog(@"%@ commit done: key=%@ value=%@",self.class, key, value);  // log
#endif

         // key exists in General dictionary and value != "OK"?
         if (([depositModel.dictMasterGeneral valueForKey:key] != nil) && (![value isEqualToString:@"OK"]))
         {
             if ([key isEqualToString:@"DepositID"])
             {
                 [depositModel.dictMasterGeneral setValue:[NSString stringWithFormat:@"Deposit Reference #%lli", [value longLongValue]] forKey:key];
             }
             else if ([key isEqualToString:@"DepositDisposition"])
             {
                 [depositModel.dictMasterGeneral setValue:value forKey:key];
     
                 if ([value isEqualToString:@"Accepted"])
                 {
                 }
                 else if ([value isEqualToString:@"Held for Review"])
                 {
                     depositModel.submittedDeposits++;				// increment submitted deposits count
                 }
             }
             else if ([key isEqualToString:@"InputValidation"])
             {
                 [depositModel.dictMasterGeneral setValue:value forKey:key];
                 [depositModel.dictMasterGeneral setHelp:value forKey:key];
                 if ([value isEqualToString:@"Session Expired"])
                 {
                     [depositModel.dictMasterGeneral setHelp:@"Your authentication credentials are no longer valid.  Please close this app and re-authenticate." forKey:key];
                 }
             }
             else if ([key isEqualToString:@"Database"])
             {
                 [depositModel.dictMasterGeneral setHelp:value forKey:key];
             }
             else if ([key isEqualToString:@"SystemError"])
             {
                 [depositModel.dictMasterGeneral setHelp:value forKey:key];
             }
             else if ([key isEqualToString:@"PreProcessing"])
             {
                 [depositModel.dictMasterGeneral setHelp:value forKey:key];
             }
             else if ([key isEqualToString:@"URLConnectionError"])
             {
                 [depositModel.dictMasterGeneral setHelp:[NSString stringWithFormat:@"Internet Connection Error:\n\n%@.", value] forKey:key];
             }
     
             [depositModel.dictResultsGeneral setValue:[depositModel.dictMasterGeneral valueForKey:key] forKey:key];
             continue;
         }
    
         // key exists in Back Image dictionary and value == "Failed"?
         if (([depositModel.dictMasterBackImage valueForKey:key] != nil) && ([value isEqualToString:@"Failed"]))
         {
             if ([depositModel.dictMasterBackImage valueForKey:key] != nil)
                 [depositModel.dictResultsBackImage setValue:[depositModel.dictMasterBackImage valueForKey:key] forKey:key];
             continue;
         }
     
         // lastly, check for DepositDispositionMessage for display
         if ([key isEqualToString:@"DepositDispositionMessage"])
         {
             [depositModel.dictMasterGeneral setHelp:value forKey:@"DepositDisposition"];
        }
     }
     
    // send notification
    [[NSNotificationCenter defaultCenter] postNotificationName:kVIP_NOTIFICATION_DEPOSIT_COMMIT_COMPLETE object:nil];

}

@end
