//
//  DepositSubmitViewController.h
//  VIPSample
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

#import <UIKit/UIKit.h>
#import "DepositModel.h"
#import "UISchema.h"

@interface DepositSubmitViewController : UIViewController
{
    DepositModel *depositModel;                         // model
    UISchema *schema;                                   // schema
    
	IBOutlet UIProgressView *progressView;              // progress bar
	IBOutlet UITableView *tableViewResults;             // table view
	
	bool bSuccess;                                      // success flag
    
	NSArray *arrayResultCategories;                     // table sections/categories array
    NSTimer *timerProgress;                             // progress timer
    
    NSMutableDictionary *dictResultsGeneral;            // results - General
    NSMutableDictionary *dictResultsFrontImage;         // results - front image
	NSMutableDictionary *dictResultsBackImage;          // results - back image

}

// Properties
@property (nonatomic) UIProgressView *progressView;
@property (nonatomic) UITableView *tableViewResults;
@property (nonatomic) NSArray *arrayResultCategories;
@property (nonatomic) NSTimer *timerProgress;
@property (strong) NSMutableDictionary *dictResultsGeneral;
@property (strong) NSMutableDictionary *dictResultsFrontImage;
@property (strong) NSMutableDictionary *dictResultsBackImage;

// Methods

- (void) onTimer:(NSTimer*)timer;
- (IBAction) onSubmitDone:(id)sender;

- (void) onDepositInitComplete:(NSNotification *)notification;      // deposit init complete
- (void) onDepositCommitComplete:(NSNotification *)notification;	// deposit commit complete

- (IBAction) onShowErrors:(id)sender;                   // show errors

@end
