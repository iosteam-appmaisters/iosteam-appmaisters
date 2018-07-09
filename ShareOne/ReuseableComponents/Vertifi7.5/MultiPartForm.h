//
//  MultipartForm.h
//  Mini-Mallows: A Multi-Part Form Wrapper for Cocoa & iPhone
//
//  Created by Sam Schroeder on 10/21/08.
//	http://www.samuelschroeder.com
//  Copyright 2008 Proton Microsystems, LLC. All rights reserved.
//
// Modified by Vertifi Software, LLC, 10/9/2009 and 11/4/2011

#import <Foundation/Foundation.h>

//-------------------------------------------------------------------------------------------------------------------
// License:
//
// Copyright (c) 2008 Samuel Schroeder / Proton Microsystems, LLC
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//-------------------------------------------------------------------------------------------------------------------

@interface MultipartForm : NSObject 
{
	NSMutableURLRequest	*mpfURLRequest;
	NSMutableDictionary	*mpfFormFields;
	NSMutableArray		*mpfFileName;
	NSMutableArray		*mpfFieldNameForFile;
	NSMutableArray		*mpfFileData;
	NSString			*mpfBoundary;
}

// Properties
@property (nonatomic, strong) NSMutableURLRequest *mpfURLRequest;
@property (nonatomic, strong) NSMutableDictionary *mpfFormFields;
@property (nonatomic, strong) NSMutableArray *mpfFileName;
@property (nonatomic, strong) NSMutableArray *mpfFieldNameForFile;
@property (nonatomic, strong) NSMutableArray *mpfFileData;
@property (nonatomic, strong) NSString *mpfBoundary;

// Methods
- (id) initWithURL:(NSURL *)url;
- (NSMutableURLRequest *) mpfRequest;
- (void) addFormField:(NSString *)fieldName withStringData:(NSString *)fieldData;
- (void) addFile:(NSString *)fileName withFieldName:(NSString *)fieldName withNSData:(NSData *)fileData;

@end