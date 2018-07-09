//
//  DepositSubmitViewController.h
//  VIPSample
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
    
    NSMutableArray *resultsGeneral;                     // results - General
    NSMutableArray *resultsFrontImage;                  // results - front image
	NSMutableArray *resultsBackImage;                   // results - back image

}

// Properties
@property (nonatomic) UIProgressView *progressView;
@property (nonatomic) UITableView *tableViewResults;
@property (nonatomic) NSArray *arrayResultCategories;
@property (nonatomic) NSTimer *timerProgress;
@property (strong) NSMutableArray *resultsGeneral;
@property (strong) NSMutableArray *resultsFrontImage;
@property (strong) NSMutableArray *resultsBackImage;

// Methods

- (void) onTimer:(NSTimer*)timer;
- (void) timerInvalidate;
- (IBAction) onSubmitDone:(id)sender;

- (void) onDepositInitComplete:(NSNotification *)notification;      // deposit init complete
- (void) onDepositCommitComplete:(NSNotification *)notification;	// deposit commit complete

- (IBAction) onShowErrors:(id)sender;                   // show errors

@end
