//
//  DataAccounts.m
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

#import "DataAccountsDelegate.h"

@implementation DataAccountsDelegate

@synthesize account;
@synthesize errorString;

- (id)init
{
	if ((self = [super init]) != nil)
	{
		depositModel = [DepositModel sharedInstance];
		self.errorString = @"";
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
	xmlValue = [[NSMutableString alloc] init];
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	if (xmlValue != nil)
		xmlValue = nil;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict
{
	// Accounts
	if ( [elementName isEqualToString:@"Accounts"]) 
	{
        [depositModel.depositAccounts removeAllObjects];             // clear accounts list
        
        // attributes include requestor= and routing=
        NSString *strAttr = [attributeDict objectForKey:@"requestor"];
        if (strAttr != nil)
            depositModel.requestor = [strAttr copy];

        strAttr = [attributeDict objectForKey:@"routing"];
        if (strAttr != nil)
            depositModel.routing = [strAttr copy];
	}

	// Account
	if ( [elementName isEqualToString:@"Account"]) 
	{
        self.account = [[DepositAccount alloc] init];               // create DepositAccount
        [depositModel.depositAccounts addObject:account];
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
	
	if ([elementName isEqualToString:@"name"])
        account.name = [s copy];
	else if ([elementName isEqualToString:@"member"])
        account.member = [s copy];
	else if ([elementName isEqualToString:@"account"])
        account.account = [s copy];
	else if ([elementName isEqualToString:@"accountType"])
        account.accountType = [s copy];
	else if ([elementName isEqualToString:@"timestamp"])
        account.timestamp = [s copy];
	else if ([elementName isEqualToString:@"session"])
        account.session = [s copy];
	else if ([elementName isEqualToString:@"MAC"])
        account.MAC = [s copy];

	else if ([elementName isEqualToString:@"Error"])
		self.errorString = [NSString stringWithString:s];
	
	[xmlValue setString:@""];
}

@end
