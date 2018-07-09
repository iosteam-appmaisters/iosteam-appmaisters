//
//  DepositInitOperation
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

#import "DepositInitOperation.h"
#import "MultiPartForm.h"
#import "FormPostHandler.h"

@implementation DepositInitOperation

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
    
    // must have valid account with MAC and requestor, and registration status must be REGISTERED
    if ((account == nil) || (account.MAC == nil) || (depositModel.requestor == nil) || (depositModel.registrationStatus != kVIP_REGSTATUS_REGISTERED))
        return;

    // load front image from cached file
    __block NSData *image = depositModel.frontImageData;
    if (image == nil)
        return;
    __block NSData *imageColor = depositModel.frontImageColorData;

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
    [form addFormField:@"scaled" withStringData:depositModel.isSmartScaled ? @"true" : @"false"];                                       // VIPLibrary v7.0+, scaled=true
    [form addFormField:@"ignoreLimit" withStringData:depositModel.allowDepositsExceedingLimit ? @"true" : @"false"];                    // allow over-limit deposits
    [form addFormField:@"source" withStringData:[UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? @"4" : @"2"];  // source 2 = iPhone, 4 = iPad

	// image
	[form addFile:@"front.png" withFieldName:@"image" withNSData:image];
	
    if (imageColor != nil)
    {
#ifdef DEBUG
        NSLog(@"%@ Ignore limit %@ amount %@ limit %.2f",self.class, depositModel.allowDepositsExceedingLimit ? @"true" : @"false", [NSString stringWithFormat:@"%.2f", depositModel.depositAmount.doubleValue], depositModel.depositLimit.doubleValue);
        NSLog(@"%@ Scaled %@",self.class,depositModel.isSmartScaled ? @"true" : @"false");
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
    
    __block dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
  
    // send Notification at completion
    self.completionBlock = ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kVIP_NOTIFICATION_DEPOSIT_INIT_COMPLETE object:nil];
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
            
            NSXMLParser *xml = [[NSXMLParser alloc] initWithData:data];
            [xml setDelegate:self];
            if ([xml parse])
            {
            }
            [xml setDelegate:nil];
        }
        else if (error != nil)
        {
            [depositModel.dictMasterGeneral setHelp:[NSString stringWithFormat:@"Internet Connection Error: \n\n%@.", [error localizedDescription]] forKey:@"URLConnectionError"];
            [depositModel.resultsGeneral addObject:@"URLConnectionError"];
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
    [depositModel.resultsGeneral removeAllObjects];                 // clear error arrays
    [depositModel.resultsFrontImage removeAllObjects];              // .
    depositModel.ssoKey = nil;                                      // clear SSO key
    depositModel.depositAmountCAR = [NSNumber numberWithDouble:0];  // clear CAR amount
    
    xmlValue = [[NSMutableString alloc] init];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    if (xmlValue != nil)
        xmlValue = nil;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
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

    // test failure?
    if ([xmlValue isEqualToString:@"Failed"])
    {
        // if key is in Master dictionary for front image, set the error into the Results dictionary
        if ([depositModel.dictMasterFrontImage valueForKey:elementName] != nil)
            [depositModel.resultsFrontImage addObject:elementName];
        return;
    }
    
    // test passed?
    if (([xmlValue isEqualToString:@"OK"]) || ([xmlValue isEqualToString:@"Passed"]) || ([xmlValue isEqualToString:@"Not Tested"]))
        return;
   
    // SSOKey
    else if ([elementName isEqualToString:@"SSOKey"])
        depositModel.ssoKey = [xmlValue copy];
    
    // CARAmount
    else if ([elementName isEqualToString:@"CARAmount"])
        depositModel.depositAmountCAR = [NSNumber numberWithDouble:[xmlValue doubleValue]];
    
    else if ([elementName isEqualToString:@"LoginValidation"])
    {
        // this shouldn't happen if Registration Query API is used properly!
        if (![xmlValue isEqualToString:@"OK"])
        {
            [depositModel.dictMasterGeneral setHelp:xmlValue forKey:elementName];
            [depositModel.resultsGeneral addObject:elementName];
        }
    }

    else if ([elementName isEqualToString:@"InputValidation"])
    {
        // this shouldn't happen if this API is used properly!
        if (![xmlValue isEqualToString:@"OK"])
        {
            [depositModel.dictMasterGeneral setHelp:xmlValue forKey:elementName];
            [depositModel.resultsGeneral addObject:elementName];
        }
    }
    
    else if ([elementName isEqualToString:@"SystemError"])
    {
        [depositModel.dictMasterGeneral setHelp:xmlValue forKey:elementName];
        [depositModel.resultsGeneral addObject:elementName];
    }
    
    else if ([elementName isEqualToString:@"PreProcessing"])
    {
        // typically indicates bad image data being posted
        if (![xmlValue isEqualToString:@"OK"])
        {
            [depositModel.dictMasterGeneral setHelp:xmlValue forKey:elementName];
            [depositModel.resultsGeneral addObject:elementName];
        }
    }
    
    [xmlValue setString:@""];
}

@end
