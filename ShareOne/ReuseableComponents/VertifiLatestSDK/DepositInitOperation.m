//
//  DepositInitOperation
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

#import "DepositViewController.h"
#import "DepositInitOperation.h"
#import "DepositModel.h"
#import "MultiPartForm.h"
#import "FormPostHandler.h"
#import "XmlSimpleParser.h"

@implementation DepositInitOperation

@synthesize delegate;

- (id) initWithDelegate:(id<DepositSubmitQueueDelegate>)sender
{
    if ((self = [super init]) != nil)
    {
        self.delegate = sender;
    }
    return (self);
}

- (void) dealloc
{
#ifdef DEBUG
    NSLog(@"%@ dealloc", self.class);
#endif
    self.delegate = nil;
}

- (void) main
{
	__weak DepositModel *depositModel = [DepositModel sharedInstance];
    
    // not registered?
    if (depositModel.registrationStatus != kVIP_REGSTATUS_REGISTERED)
        return;

    // get selected account
    DepositAccount *account = (DepositAccount *)[depositModel.depositAccounts objectAtIndex:depositModel.depositAccountSelected];
    
    // no MAC?
    if (account.MAC == nil)
        return;

    // load front image from cached file
    __block NSData *image = depositModel.frontImageData;
    if (image == nil)
        return;
    __block NSData *imageColor = depositModel.frontImageColorData;

    srand48(time(0));                       // seed for lrand()
    
	// URL request
    FormPostHandler *postHandler = [[FormPostHandler alloc] init];
    NSURL *postURL = [postHandler getURLFromHost:[depositModel.dictSettings valueForKey:@"URL_RDCHost"] withPath:[depositModel.dictSettings valueForKey:@"Path_DepositInit"]];
    
	MultipartForm *form = [[MultipartForm alloc] initWithURL:postURL];
	
	// fields
	[form addFormField:@"requestor" withStringData:depositModel.requestor];
	[form addFormField:@"session" withStringData:account.session];
	[form addFormField:@"timestamp" withStringData:account.timestamp];
	[form addFormField:@"routing" withStringData:depositModel.routing];
	[form addFormField:@"member" withStringData:account.member];
	[form addFormField:@"account" withStringData:account.account];
	[form addFormField:@"accounttype" withStringData:account.accountType];
	[form addFormField:@"MAC" withStringData:account.MAC];
	[form addFormField:@"mode" withStringData:depositModel.testMode ? @"test" : @"prod"];
    [form addFormField:@"amount" withStringData:[NSString stringWithFormat:@"%.2f", depositModel.depositAmount.doubleValue]];
    [form addFormField:@"membername" withStringData:depositModel.userName];
	[form addFormField:@"email" withStringData:depositModel.userEmail];
    [form addFormField:@"source" withStringData:[UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? @"4" : @"2"];  // source 2 = iPhone, 4 = iPad

	// image
	[form addFile:@"front.png" withFieldName:@"image" withNSData:image];
	
    if (imageColor != nil)
    {
#ifdef DEBUG
        NSLog(@"%@ PNG b/w %lu",self.class,(unsigned long)image.length);
        NSLog(@"%@ JPEG color %lu",self.class,(unsigned long)imageColor.length);
#endif
        [form addFile:@"front_color.jpg" withFieldName:@"imageColor" withNSData:imageColor];
    }
    
    if ([self isCancelled])
    {
#ifdef DEBUG
        NSLog(@"%@ Cancelled",self.class);
#endif
        return;
    }
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    // Post the message
    [postHandler postBackgroundFormWithRequest:form toURL:postURL completion:^(BOOL success, NSData *data, NSError *error)
    {

         if ([self isCancelled])
         {
#ifdef DEBUG
             NSLog(@"%@ Cancelled",self.class);
#endif
             // SIGNAL
             dispatch_semaphore_signal(semaphore);

             return;
         }

         if (success)
         {
             XmlSimpleParser *parser = [[XmlSimpleParser alloc] initXmlParser];
             NSXMLParser *xml = [[NSXMLParser alloc] initWithData:data];
             [xml setDelegate:parser];
             if ([xml parse])
             {
                 if (delegate)
                     [delegate onSubmitInitDone:[NSDictionary dictionaryWithDictionary:parser.dictElements]];
             }
             [xml setDelegate:nil];

         }
         else
         {
             [depositModel.dictMasterGeneral setHelp:[NSString stringWithFormat:@"Internet Connection Error:\n\n%@.", [error localizedDescription]] forKey:@"URLConnectionError"];
             [depositModel.dictResultsGeneral setValue:[depositModel.dictMasterGeneral valueForKey:@"URLConnectionError"] forKey:@"URLConnectionError"];
             if (delegate)
                 [delegate onSubmitInitDone:nil];
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
