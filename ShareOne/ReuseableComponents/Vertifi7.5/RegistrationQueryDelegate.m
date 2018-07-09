//
//  RegQueryDelegate.m
//  VIPSample
//
//  Created by Vertifi Software, LLC on 12/27/17.
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

#import "RegistrationQueryDelegate.h"

@implementation RegistrationQueryDelegate

- (id)init
{
    if ((self = [super init]) != nil)
    {
        depositModel = [DepositModel sharedInstance];
    }
    return (self);
}

#pragma mark -
#pragma mark NSXMLParser delegate

//----------------------------------------------------------------------------------------------------------------
// Parser delegate methods
//----------------------------------------------------------------------------------------------------------------

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    // initialize the model
    depositModel.htmlContent = nil;

    xmlValue = [[NSMutableString alloc] init];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    if (xmlValue != nil)
        xmlValue = nil;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
    // UserValidation
    if ( [elementName isEqualToString:@"UserValidation"])
    {
    }
    
    // Settings
    if ( [elementName isEqualToString:@"Settings"])
    {
        depositModel.endorsementThreshold = 0;
        depositModel.visionApiURL = nil;
        depositModel.visionApiKey = @"";
        depositModel.endorsements = [NSMutableArray array];
    }
    
    // Endorsements
    if ( [elementName isEqualToString:@"Endorsements"])
    {
        // attributes include Threshold
        NSString *strAttr = [attributeDict objectForKey:@"Threshold"];
        if (strAttr != nil)
            depositModel.endorsementThreshold = [strAttr intValue];
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
    
    if ([elementName isEqualToString:@"LoginValidation"])
    {
        if ([xmlValue isEqualToString:@"OK"])
        {
            depositModel.registrationStatus = kVIP_REGSTATUS_REGISTERED;
        }
        else if ([xmlValue isEqualToString:@"User Registration Pending Approval"])
        {
            depositModel.registrationStatus = kVIP_REGSTATUS_PENDING;
        }
        else if ([xmlValue isEqualToString:@"User Not Registered"])
        {
            depositModel.registrationStatus = kVIP_REGSTATUS_UNREGISTERED;
        }
        else if ([xmlValue isEqualToString:@"User Registration Disabled"])
        {
            depositModel.registrationStatus = kVIP_REGSTATUS_DISABLED;
        }
    }
   
    else if ([elementName isEqualToString:@"EUAContents"])
        depositModel.htmlContent = [[NSData alloc] initWithBase64EncodedString:xmlValue options:0];
    else if ([elementName isEqualToString:@"PendingContents"])
        depositModel.htmlContent = [[NSData alloc] initWithBase64EncodedString:xmlValue options:0];
    else if ([elementName isEqualToString:@"DeniedContents"])
        depositModel.htmlContent = [[NSData alloc] initWithBase64EncodedString:xmlValue options:0];

    else if ([elementName isEqualToString:@"DepositLimit"])
        depositModel.depositLimit = [NSNumber numberWithDouble:[xmlValue doubleValue]];
    else if ([elementName isEqualToString:@"SubmittedDeposits"])
        depositModel.heldForReviewDepositsCount = [xmlValue intValue];

    else if ([elementName isEqualToString:@"Vision_URL"])
        depositModel.visionApiURL = xmlValue.length > 0 ? [xmlValue copy] : nil;
    else if ([elementName isEqualToString:@"API_Key"])
        depositModel.visionApiKey = xmlValue.length > 0 ? [xmlValue copy] : nil;

    else if ([elementName isEqualToString:@"Endorsement"])
        [depositModel.endorsements addObject:[xmlValue copy]];

    [xmlValue setString:@""];
}


@end
