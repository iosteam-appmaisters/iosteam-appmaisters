//
//  ResponseDictionary.m
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

#import <UIKit/UIKit.h>
#import "ResponseDictionary.h"


@implementation ResponseDictionary

// keys property for enumerators
- (NSArray *) keys
{
	return ((NSArray *)keys);
}

// init
- (id) init
{
	if ((self = [super init]) != nil)
	{
		keys = [[NSMutableArray alloc] initWithCapacity:20];
		values = [[NSMutableArray alloc] initWithCapacity:20];
		helps = [[NSMutableArray alloc] initWithCapacity:20];
		styles = [[NSMutableArray alloc] initWithCapacity:20];
	}
	return (self);
}


- (void) addValues:(NSString *)key value:(NSString *)value help:(NSString *)help style:(NSInteger)style
{
	[keys addObject:key];
	[values addObject:value];
	[helps addObject:help];
	[styles addObject:[NSNumber numberWithInteger:style]];

}

- (NSString *) valueForKey:(NSString *)key
{
	for (int i = 0;i < keys.count;i++)
	{
		if ([[keys objectAtIndex:i] isEqualToString:key])
			return ([values objectAtIndex:i]);
	}
	return ((NSString *)nil);
}

- (NSString *) helpForKey:(NSString *)key
{
	for (int i = 0;i < keys.count;i++)
	{
		if ([[keys objectAtIndex:i] isEqualToString:key])
			return ([helps objectAtIndex:i]);
	}
	return ((NSString *)nil);
}

- (NSInteger) styleForKey:(NSString *)key
{
	for (int i = 0;i < keys.count;i++)
	{
		if ([[keys objectAtIndex:i] isEqualToString:key])
			return ([[styles objectAtIndex:i] intValue]);
	}
	return (UITableViewCellAccessoryNone);
}

			
- (void) setValue:(NSString *)value forKey:(NSString *)key
{
	for (int i = 0;i < keys.count;i++)
	{
		if ([[keys objectAtIndex:i] isEqualToString:key])
		{
            [values replaceObjectAtIndex:i withObject:[value copy]];    // v7.5; copy the value!
			return;
		}
	}
	return;
}

- (void) setHelp:(NSString *)help forKey:(NSString *)key
{
	for (int i = 0;i < keys.count;i++)
	{
		if ([[keys objectAtIndex:i] isEqualToString:key])
		{
			[helps replaceObjectAtIndex:i withObject:[help copy]];    // v7.5; copy the value!
			return;
		}
	}
	return;
}

@end
