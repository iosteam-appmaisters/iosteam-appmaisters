//
//  DepositCommitOperation.m
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

#import "DepositCommitOperation.h"
#import "MultiPartForm.h"
#import "FormPostHandler.h"

@implementation DepositCommitOperation

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
    
    // no MAC or Requestor or SSOKey?  User not REGISTERED?
    if ((account.MAC == nil) || (depositModel.requestor == nil) || (depositModel.ssoKey == nil) || (depositModel.registrationStatus != kVIP_REGSTATUS_REGISTERED))
        return;
    
    // load back image from cached file
    NSData *image = depositModel.backImageData;
    if (image == nil)
        return;
    __block NSData *imageColor = depositModel.backImageColorData;

	// URL request
    FormPostHandler *postHandler = [[FormPostHandler alloc] init];
    NSURL *postURL = [postHandler getURLFromHost:[depositModel.dictSettings valueForKey:@"URL_RDCHost"] withPath:[depositModel.dictSettings valueForKey:@"Path_DepositCommit"]];

 	MultipartForm *form = [[MultipartForm alloc] initWithURL:postURL];

	// fields
	[form addFormField:@"requestor" withStringData:depositModel.requestor];
	[form addFormField:@"session" withStringData:account.session];
	[form addFormField:@"timestamp" withStringData:account.timestamp];
	[form addFormField:@"routing" withStringData:depositModel.routing];
	[form addFormField:@"member" withStringData:account.member];
	[form addFormField:@"account" withStringData:account.account];
	[form addFormField:@"MAC" withStringData:account.MAC];
    [form addFormField:@"amount" withStringData:[NSString stringWithFormat:@"%.2f", depositModel.depositAmount.doubleValue]];
    [form addFormField:@"ssokey" withStringData:depositModel.ssoKey];

    // v7.5; send iurearendorsement, which should have a value of 2=Passed
    [form addFormField:@"iurearendorsement" withStringData:[NSString stringWithFormat:@"%ld",(long)depositModel.iuRearEndorsement]];

	// image
	[form addFile:@"back.png" withFieldName:@"image" withNSData:image];

    // v7.5; no Vision API key and we have a color image?  Send the color image!
    if (((depositModel.visionApiKey == nil) || (depositModel.visionApiKey.length == 0)) && (imageColor != nil))
    {
#ifdef DEBUG
        NSLog(@"%@ PNG b/w %lu",self.class,(unsigned long)image.length);
        NSLog(@"%@ JPEG color %lu",self.class,(unsigned long)imageColor.length);
#endif
        [form addFile:@"back_color.jpg" withFieldName:@"imageColor" withNSData:imageColor];
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
        [[NSNotificationCenter defaultCenter] postNotificationName:kVIP_NOTIFICATION_DEPOSIT_COMMIT_COMPLETE object:nil];
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
    [depositModel.resultsGeneral removeAllObjects];     // clear error arrays
    [depositModel.resultsBackImage removeAllObjects];   // .
    depositModel.depositId = nil;                       // clear deposit Id and disposition
    depositModel.depositDisposition = nil;              // .
    depositModel.depositDispositionMessage = nil;       // .
    
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
        if ([depositModel.dictMasterBackImage valueForKey:elementName] != nil)
            [depositModel.resultsBackImage addObject:elementName];
    }
    
    // test passed?
    if (([xmlValue isEqualToString:@"OK"]) || ([xmlValue isEqualToString:@"Passed"]) || ([xmlValue isEqualToString:@"Not Tested"]))
        return;
    
    if ([elementName isEqualToString:@"DepositID"])
    {
        depositModel.depositId = [NSNumber numberWithLongLong:[xmlValue longLongValue]];
        return;
    }

    if ([elementName isEqualToString:@"DepositDisposition"])
    {
        depositModel.depositDisposition = [xmlValue copy];
        if ([xmlValue isEqualToString:kVIP_DEPOSIT_STATUS_HELD_FOR_REVIEW])
            depositModel.heldForReviewDepositsCount++;
        return;
    }
    
    if ([elementName isEqualToString:@"DepositDispositionMessage"])
    {
        depositModel.depositDispositionMessage = [xmlValue copy];
        return;
    }
    
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
