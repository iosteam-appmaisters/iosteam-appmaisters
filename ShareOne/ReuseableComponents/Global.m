//
//  Global.h
//  ImageProcSample
//
//  Created by Vertifi Software, LLC
//
//-------------------------------------------------------------------------------------------------------------------------------------------------
// License:
//
// Copyright (c) 2013 Vertifi Software, LLC
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

#import "Global.h"

@implementation Global

// Properties
@synthesize rectViewPort;
@synthesize rectFront;
@synthesize rectBack;

+ (Global *) globalinstance
{
	static Global *instance = nil;
	
	if (instance == nil)
	{
		instance = [[self alloc] init];
	}
	
	return (instance);
}

//--------------------------------------------------------------------------------------------
// instance initialization
//--------------------------------------------------------------------------------------------

- (id)init
{
	if ((self = [super init]) != nil)
	{	
        self.rectViewPort = CGRectMake(0.005, 0.16, 0.99, 0.65);	// left: 0.5%, top: 16%, width: 99%, height: 65%
    
        self.rectFront = CGRectNull;
        self.rectBack = CGRectNull;

	}
	return (self);
}


+ (void) setColorScheme
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    UIColor *colorBlue = [UIColor colorWithRed:(4.0f/255.0f) green:(83.0f/255.0f) blue:(147.0f/255.0f) alpha:1.0f];

    //UIColor *colorCyan = [UIColor colorWithRed:1.0f green:0.6f blue:0.2f alpha:1.0f];
    UIColor *colorButtons = [UIColor colorWithRed:0.8f green:0.4f blue:0.0f alpha:1.0f];

    [[UIBarButtonItem appearance] setTintColor:colorButtons];
    [[UIButton appearance] setTintColor:colorButtons];
    [[UISegmentedControl appearance] setTintColor:colorButtons];
    [[UISlider appearance] setTintColor:colorButtons];
    //[[UISlider appearance] setThumbTintColor:colorButtons];
    //[[UISlider appearance] setMaximumTrackTintColor:colorButtons];
    [[UINavigationBar appearance] setBarTintColor:colorBlue];
    [[UIToolbar appearance] setBarTintColor:colorButtons];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowColor:[UIColor blackColor]];
    [shadow setShadowOffset:CGSizeMake(1,-1)];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:(id)[UIColor whiteColor], NSForegroundColorAttributeName,
                                                          shadow, NSShadowAttributeName, nil]];

    [[UIWindow appearance] setTintColor:colorButtons];
}


@end