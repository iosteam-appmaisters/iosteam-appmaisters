//
//  XmlParser.m
//  VIPSample
//
//  Created by Vertifi Software, LLC
//
//-------------------------------------------------------------------------------------------------------------------------------------------------
// License:
//
// Copyright (c) 2017 Vertifi Software, LLC
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

#import "XmlSimpleParser.h"

@implementation XmlSimpleParser

// Properties

- (NSDictionary *)dictElements
{
	return ((NSDictionary *)dictElements);
}

// Methods

- (XmlSimpleParser *) initXmlParser 
{	
    if ((self = [super init]) != nil)
    {
        dictElements = [[NSMutableDictionary alloc] initWithCapacity:36];
        xmlValue = [[NSMutableString alloc] init];
	}
    return (self);
}

- (void) dealloc 
{
	if (xmlValue != nil)
		xmlValue = nil;
}

// XML parser delegate methods

- (void)parserDidStartDocument:(NSXMLParser *)parser
{
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict 
{
	[dictElements setObject:@"" forKey:elementName];
	currentKey = elementName;
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
	if ((currentKey != nil) && (xmlValue != nil) && (xmlValue.length > 0))
	{
		[dictElements setValue:[NSString stringWithString:xmlValue] forKey:currentKey];
		currentKey = nil;
	}

    [xmlValue setString:@""];

}

#pragma mark XML general utilities

//--------------------------------------------------------------------------------------------
// XML string encoding
//--------------------------------------------------------------------------------------------

+ (NSString *) escapeString:(NSString *)string
{
	if (string == nil)
		return (nil);

	NSMutableString *escaped = [NSMutableString stringWithString:string];
	[escaped replaceOccurrencesOfString:@"&" withString:@"&amp;" options:NSLiteralSearch range:NSMakeRange(0,[escaped length])];
	[escaped replaceOccurrencesOfString:@"<" withString:@"&lt;" options:NSLiteralSearch range:NSMakeRange(0,[escaped length])];
	[escaped replaceOccurrencesOfString:@">" withString:@"&gt;" options:NSLiteralSearch range:NSMakeRange(0,[escaped length])];
	[escaped replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:NSLiteralSearch range:NSMakeRange(0,[escaped length])];
	return ((NSString *)escaped);
}

@end
