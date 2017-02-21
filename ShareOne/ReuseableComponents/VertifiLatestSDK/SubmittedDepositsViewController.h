//
//  SubmittedDepositsViewController.h
//  VIPSample
//
//  Created by Vertifi Software, LLC
//
//-------------------------------------------------------------------------------------------------------------------------------------------------
// License:
//
// Copyright (c) 2016 Vertifi Software, LLC
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
#import "SubmittedDeposit.h"
#import "DepositModel.h"
#import "UISchema.h"

@interface SubmittedDepositsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSXMLParserDelegate, UIAdaptivePresentationControllerDelegate, UIPopoverPresentationControllerDelegate>
{
    DepositModel *depositModel;                     // model
    UISchema *schema;                               // schema

    IBOutlet UITableView *tableDeposits;            // table view

	NSMutableArray *submittedDeposits;
	SubmittedDeposit *submittedDeposit;
	
	NSMutableString *xmlValue;						// for XML parsing
}

@property (strong) UITableView *tableDeposits;
@property (strong)  NSMutableArray *submittedDeposits;
@property (strong)  SubmittedDeposit *submittedDeposit;
@property (strong)  NSMutableString *xmlValue;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;

- (IBAction) onDone:(id)sender;

// server messages
- (void) getSubmittedDeposits;
- (void) deleteDeposit:(NSInteger)idx;

// Notifications
- (void) onFontSizeChanged:(NSNotification *)notification;

// XML Parser delegate
- (void)parserDidStartDocument:(NSXMLParser *)parser;
- (void)parserDidEndDocument:(NSXMLParser *)parser;
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict;
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;

@end
