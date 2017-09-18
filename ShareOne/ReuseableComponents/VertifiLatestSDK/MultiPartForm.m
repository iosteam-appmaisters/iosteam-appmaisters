//
//  MultipartForm.m
//  Mini-Mallows: A Multi-Part Form Wrapper for Cocoa & iPhone
//
//  Created by Sam Schroeder on 10/21/08.
//	http://www.samuelschroeder.com
//  Copyright 2008 Proton Microsystems, LLC. All rights reserved.
//
// Modified by Vertifi Software, LLC, 10/9/2009

#import "MultiPartForm.h"

@implementation MultipartForm

@synthesize mpfURLRequest;
@synthesize mpfFormFields;
@synthesize mpfFileName;
@synthesize mpfFieldNameForFile;
@synthesize mpfFileData;
@synthesize mpfBoundary;

#pragma mark -
#pragma mark Initializers

//-------------------------------------------------------------------------------------------------
// don't allow this initializer!
//-------------------------------------------------------------------------------------------------

- (id)init 
{
	@throw [NSException exceptionWithName:@"MultiPartFormBadInitCall" reason:@"Initial MultipartForm with initWithURL:" userInfo:nil];
	return nil;
}

//-------------------------------------------------------------------------------------------------
// designated initializer
//-------------------------------------------------------------------------------------------------

- (id)initWithURL:(NSURL *)url
{
	if ((self = [super init]) != nil)
    {
        self.mpfURLRequest = [NSMutableURLRequest requestWithURL:url];
        [mpfURLRequest setTimeoutInterval:240.0];
        [mpfURLRequest setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
        //[mpfURLRequest setHTTPShouldUsePipelining:YES];
        [mpfURLRequest setHTTPMethod:@"POST"];
        
        self.mpfFormFields = [NSMutableDictionary dictionaryWithCapacity:14];
        self.mpfFileName = [[NSMutableArray alloc] initWithCapacity:2];
        self.mpfFieldNameForFile = [[NSMutableArray alloc] initWithCapacity:2];
        self.mpfFileData = [[NSMutableArray alloc] initWithCapacity:2];
        
        // Set boundary string
        srandom((unsigned int)time(0));
        self.mpfBoundary = [NSString stringWithFormat:@"------------%ld%ld", random(),random()];
        
        // Adding header information
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", mpfBoundary];
        [mpfURLRequest addValue:contentType forHTTPHeaderField: @"Content-Type"];
        
        // !!!: Alter the line below if you need a specific accept type
        //[mpfRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
	}
    
	return (self);
}

- (void) dealloc
{
}

#pragma mark -
#pragma mark Builder Methods

- (void)addFormField:(NSString *)fieldName withStringData:(NSString *)fieldData 
{
	NSDictionary *newFieldDictionary = [NSDictionary dictionaryWithObject:(fieldData == nil ? @"" : fieldData) forKey:fieldName];
	[mpfFormFields addEntriesFromDictionary:newFieldDictionary];
}

- (void)addFile:(NSString *)fileName withFieldName:(NSString *)fieldName withNSData:(NSData *)fileData 
{
	[mpfFileName addObject:fileName];
	[mpfFieldNameForFile addObject:fieldName];
	[mpfFileData addObject:fileData];
}

#pragma mark -
#pragma mark Accessors

//-------------------------------------------------------------------------------------------------
// mpfRequest getter
//-------------------------------------------------------------------------------------------------

- (NSMutableURLRequest *)mpfRequest
{
    NSMutableData *mpfBody = [NSMutableData data];
    
	// Start Mutlipart Form
	[mpfBody appendData:[[NSString stringWithFormat:@"--%@\r\n", mpfBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	// Add Form Fields
	NSArray *fieldKeys = [NSArray arrayWithArray:[mpfFormFields allKeys]];
	NSEnumerator *enumerator = [fieldKeys objectEnumerator];
	id anObject;

    NSInteger nFields = fieldKeys.count;
    NSInteger nField = 0;
    while ((anObject = [enumerator nextObject]) != nil)
	{
		NSString *fieldKey = [NSString stringWithString:anObject];
		NSString *fieldData = [NSString stringWithString:[mpfFormFields objectForKey:anObject]];
		
		[mpfBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", fieldKey] dataUsingEncoding:NSUTF8StringEncoding]];
		[mpfBody appendData:[[NSString stringWithString:fieldData] dataUsingEncoding:NSUTF8StringEncoding]];
		[mpfBody appendData:[[NSString stringWithFormat:@"\r\n--%@", mpfBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        nField++;
        if ((nField == nFields) && (mpfFileName.count == 0))
        {
            [mpfBody appendData:[[NSString stringWithFormat:@"--\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];    // closing prefix tag
        }
        else
        {
            [mpfBody appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        }
	}
	
	// Add the Files
	for (int i = 0;i < mpfFileName.count;i++)
	{
		if ([mpfFileData objectAtIndex:i] != nil)
		{
            [mpfBody appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", [mpfFieldNameForFile objectAtIndex:i], [[mpfFileName objectAtIndex:i] lastPathComponent]] dataUsingEncoding:NSUTF8StringEncoding]];
			[mpfBody appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
			[mpfBody appendData:[mpfFileData objectAtIndex:i]];
			[mpfBody appendData:[[NSString stringWithFormat:@"\r\n--%@%@\r\n", mpfBoundary, i == mpfFileName.count - 1 ? @"--" : @""] dataUsingEncoding:NSUTF8StringEncoding]];
		}
	}
	
	[mpfURLRequest setHTTPBody:(NSData *)mpfBody];

    return (mpfURLRequest);
}

@end
