//
//  NetworkQueue.m
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

#import "NetworkQueue.h"
#import "DepositModel.h"
#import "RegistrationQueryOperation.h"
#import "RegistrationAcceptOperation.h"
#import "RegistrationGetEUAOperation.h"
#import "DepositInitOperation.h"
#import "DepositCommitOperation.h"
#import "HistoryAuditQueryOperation.h"
#import "HeldForReviewDeleteOperation.h"
#import "DepositReportOperation.h"

@implementation NetworkQueue

//--------------------------------------------------------------------------------------------
// Singleton object
//--------------------------------------------------------------------------------------------

+ (instancetype) sharedInstance
{
    static NetworkQueue *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil)
        {
            instance = [[self alloc] init];
        }
    });
    
    return (instance);
}

//-----------------------------------------------------------------------------
// init
//-----------------------------------------------------------------------------

- (instancetype) init
{
	if ((self = [super init]) != nil)
	{
        [self setMaxConcurrentOperationCount:5];            // concurrent
	}
	return (self);
}

//-----------------------------------------------------------------------------
// cancel
//-----------------------------------------------------------------------------

- (void) cancelOperationsOfClass:(Class)class
{
    for (NSOperation *op in self.operations)
    {
        if ([op isKindOfClass:class])
            [op cancel];
    }
}

//-----------------------------------------------------------------------------
// running Operation check
//-----------------------------------------------------------------------------

- (BOOL) hasRunningOperationOfClass:(Class)class
{
    for (NSOperation *op in self.operations)
    {
        if (([op isKindOfClass:class]) && (op.isFinished == NO))
            return (YES);
    }
    return (NO);
}

//-----------------------------------------------------------------------------
// add dependency
//-----------------------------------------------------------------------------

- (void) addDependencyToClass:(Class)class withOperation:(NSOperation *)op
{
    for (NSOperation *operation in self.operations)
    {
        if ([operation isKindOfClass:class])
            [op addDependency:operation];
    }
    return;
}

//-----------------------------------------------------------------------------
// Registration Query Processing - runs on background thread
//
// calls Mobile Deposit Registration Query API
//-----------------------------------------------------------------------------

- (void) sendRegistrationQuery
{
    // cancel any running operations
    [self cancelOperationsOfClass:RegistrationQueryOperation.class];
    
    // create operation
    RegistrationQueryOperation *regQueryOp = [[RegistrationQueryOperation alloc] init];
    [self addOperation:regQueryOp];
    return;
}

//-----------------------------------------------------------------------------
// Registration Accept Processing - runs on background thread
//
// calls Mobile Deposit Registration Accept API
//-----------------------------------------------------------------------------

- (void) sendRegistrationAccept
{
    // cancel any running operations
    [self cancelOperationsOfClass:RegistrationAcceptOperation.class];
    
    // create operation, dependent on RegistrationQueryOperation
    RegistrationAcceptOperation *regAcceptOp = [[RegistrationAcceptOperation alloc] init];
    [self addDependencyToClass:RegistrationQueryOperation.class withOperation:regAcceptOp];
    [self addOperation:regAcceptOp];
    return;
}

//-----------------------------------------------------------------------------
// Registration Get EUA Processing - runs on background thread
//
// calls Mobile Deposit Registration Get EUA API
//-----------------------------------------------------------------------------

- (void) sendRegistrationGetEUA
{
    // cancel any running operations
    [self cancelOperationsOfClass:RegistrationGetEUAOperation.class];
    
    // create operation, dependent on RegistrationQueryOperation
    RegistrationGetEUAOperation *regGetEUAOp = [[RegistrationGetEUAOperation alloc] init];
    [self addDependencyToClass:RegistrationQueryOperation.class withOperation:regGetEUAOp];
    [self addOperation:regGetEUAOp];
    return;
}

//-----------------------------------------------------------------------------
// Front Image Processing - runs on background thread
//
// calls Mobile Deposit Init API
//-----------------------------------------------------------------------------

- (void) sendDepositInit
{
    // cancel any running operations
    [self cancelOperationsOfClass:DepositInitOperation.class];
    
    // use Operation Queue, dependent on RegistrationQueryOperation
    DepositInitOperation *depositInitOp = [[DepositInitOperation alloc] init];
    [self addDependencyToClass:RegistrationQueryOperation.class withOperation:depositInitOp];
    [self addOperation:depositInitOp];
 	return;
}

//-----------------------------------------------------------------------------
// Commit Processing - runs on background thread
//
// call Mobile Deposit Commit API
//-----------------------------------------------------------------------------

- (void) sendDepositCommit
{
    // cancel any running operations
    [self cancelOperationsOfClass:DepositCommitOperation.class];
    
    // if front needs to be sent (no SSOKey), do it
    DepositModel *depositModel = [DepositModel sharedInstance];
    if ((![self hasRunningOperationOfClass:DepositInitOperation.class]) && (depositModel.ssoKey == nil))
        [self sendDepositInit];

    // create operation, dependent on DepositInitOperation
    DepositCommitOperation *depositCommitOp = [[DepositCommitOperation alloc] init];
    [self addDependencyToClass:DepositInitOperation.class withOperation:depositCommitOp];
    [self addOperation:depositCommitOp];
	return;
}

//-----------------------------------------------------------------------------
// Held for Review Query Processing - runs on background thread
//
// calls Mobile Deposit Held for Review Query API
//-----------------------------------------------------------------------------

- (void) sendHistoryAuditQuery
{
    // cancel any running operations
    [self cancelOperationsOfClass:HistoryAuditQueryOperation.class];
    
    // create operation
    HistoryAuditQueryOperation *heldForReviewQueryOp = [[HistoryAuditQueryOperation alloc] init];
    [self addOperation:heldForReviewQueryOp];
    return;
}

//-----------------------------------------------------------------------------
// Held for Review Delete Processing - runs on background thread
//
// calls Mobile Deposit Held for Review Delete API
//-----------------------------------------------------------------------------

- (void) sendHeldForReviewDelete:(DepositHistory *)deposit
{
    // create operation
    HeldForReviewDeleteOperation *heldForReviewDeleteOp = [[HeldForReviewDeleteOperation alloc] init];
    heldForReviewDeleteOp.deposit = deposit;
    [self addOperation:heldForReviewDeleteOp];
    return;
}

//-----------------------------------------------------------------------------
// Deposit Report Processing - runs on background thread
//
// calls Mobile Deposit Held for Review Report API
//-----------------------------------------------------------------------------

- (void) sendDepositReport:(DepositHistory *)deposit
{
    // create operation
    DepositReportOperation *heldForReviewReportOp = [[DepositReportOperation alloc] init];
    heldForReviewReportOp.deposit = deposit;
    [self addOperation:heldForReviewReportOp];
    return;
}

@end
