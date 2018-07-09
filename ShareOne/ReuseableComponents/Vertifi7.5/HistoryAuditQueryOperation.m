//
//  HistoryAuditQueryOperation.m
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

#import "HistoryAuditQueryOperation.h"
#import "MultiPartForm.h"
#import "FormPostHandler.h"

@implementation HistoryAuditQueryOperation

@synthesize depositModel;
@synthesize deposit;

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
    
    // must have valid account with MAC and Requestor?  User must be REGISTERED
    if ((account == nil) || (account.MAC == nil) || (depositModel.requestor == nil) || (depositModel.registrationStatus != kVIP_REGSTATUS_REGISTERED))
        return;
    
    // URL request
    FormPostHandler *postHandler = [[FormPostHandler alloc] init];
    NSURL *postURL = [postHandler getURLFromHost:[depositModel.dictSettings valueForKey:@"URL_RDCHost"] withPath:[depositModel.dictSettings valueForKey:@"Path_HistoryAuditQuery"]];
    
    MultipartForm *form = [[MultipartForm alloc] initWithURL:postURL];
    
    // fields
    [form addFormField:@"requestor" withStringData:depositModel.requestor];
    [form addFormField:@"session" withStringData:account.session];
    [form addFormField:@"timestamp" withStringData:account.timestamp];
    [form addFormField:@"routing" withStringData:depositModel.routing];
    [form addFormField:@"member" withStringData:account.member];
    [form addFormField:@"account" withStringData:account.account];
    [form addFormField:@"MAC" withStringData:account.MAC];
    [form addFormField:@"mode" withStringData:depositModel.testMode ? @"test" : @"prod"];
    
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
        [[NSNotificationCenter defaultCenter] postNotificationName:kVIP_NOTIFICATION_HISTORY_AUDIT_QUERY_COMPLETE object:nil];
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
            
            // parse the XML and update the Model
            NSXMLParser *xml = [[NSXMLParser alloc] initWithData:data];
            [xml setDelegate:self];
            if ([xml parse])
            {
            }
            [xml setDelegate:nil];
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

#pragma mark -
#pragma mark NSXMLParser delegate

//----------------------------------------------------------------------------------------------------------------
// Parser delegate methods
//----------------------------------------------------------------------------------------------------------------

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    // initialize model
    [depositModel.depositHistory removeAllObjects];              // clear array
    depositModel.heldForReviewDepositsCount = 0;                 // reset counter
    
    xmlValue = [[NSMutableString alloc] init];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    if (xmlValue != nil)
        xmlValue = nil;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    
    // Deposit
    if ( [elementName isEqualToString:@"Deposit"])
    {
        self.deposit = [[DepositHistory alloc] init];               // create HeldForReviewDeposit object
        [depositModel.depositHistory addObject:deposit];            // add to array
    }
    
    [xmlValue setString:@""];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if ((string != nil) && (string.length > 0))
    {
        [xmlValue appendString:[string stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]]];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ((xmlValue == nil) || (xmlValue.length <= 0))
        return;
    
    NSString *s = [NSString stringWithString:xmlValue];
    
    if ([elementName isEqualToString:@"Deposit_ID"])
        self.deposit.depositId = [s copy];
    else if ([elementName isEqualToString:@"Deposit_Status"])
    {
        self.deposit.depositStatus = [s copy];
        if ([deposit.depositStatus isEqualToString:kVIP_DEPOSIT_STATUS_HELD_FOR_REVIEW]) // Held for Review deposit?
            depositModel.heldForReviewDepositsCount++;                  // increment counter
    }
    else if ([elementName isEqualToString:@"Account_Number"])
        self.deposit.accountNumber = [s copy];
    else if ([elementName isEqualToString:@"Release_Timestamp_UTC"])
    {
        if (s.length > 0)
        {
            // sent as time interval since 1/1/1970, convert to local time
            NSDate *localDate = [NSDate dateWithTimeIntervalSince1970:[s doubleValue]];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"MM/dd/yyyy h:mm:ss a";
            self.deposit.releaseTimestamp = [dateFormatter stringFromDate:localDate];
        }
    }
    else if ([elementName isEqualToString:@"Admin_Release_Timestamp_UTC"])
    {
        if (s.length > 0)
        {
            // sent as time interval since 1/1/1970, convert to local time
            NSDate *localDate = [NSDate dateWithTimeIntervalSince1970:[s doubleValue]];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = @"MM/dd/yyyy h:mm:ss a";
            self.deposit.adminReleaseTimestamp = [dateFormatter stringFromDate:localDate];
        }
    }
    else if ([elementName isEqualToString:@"Items"])
        self.deposit.items = [NSNumber numberWithInteger:[s integerValue]];
    else if ([elementName isEqualToString:@"Amount"])
        self.deposit.amount = [NSNumber numberWithDouble:[s doubleValue]];
    else if ([elementName isEqualToString:@"Notes"])
        self.deposit.notes = [s copy];
    
    [xmlValue setString:@""];
}

@end
