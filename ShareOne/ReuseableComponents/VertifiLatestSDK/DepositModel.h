//
//  DepositModel.h
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

#import <Foundation/Foundation.h>
#import "DepositAccount.h"
#import "DepositSubmitQueue.h"
#import "ResponseDictionary.h"

// flash
static const int kVIP_FLASH_OFF = 0;
static const int kVIP_FLASH_AUTOMATIC = 1;
static const int kVIP_FLASH_ON = 2;

// camera mode
static const int kVIP_MODE_AUTOMATIC = 0;
static const int kVIP_MODE_MANUAL = 1;

// Registration status values
static const int kVIP_REGSTATUS_DISABLED = 0;
static const int kVIP_REGSTATUS_REGISTERED = 1;
static const int kVIP_REGSTATUS_PENDING = 2;
static const int kVIP_REGSTATUS_UNREGISTERED = 3;

// image files
static NSString *kVIP_FRONT_IMAGE = @"front.png";
static NSString *kVIP_FRONT_IMAGE_COLOR = @"front_color.jpg";
static NSString *kVIP_BACK_IMAGE = @"back.png";
static NSString *kVIP_BACK_IMAGE_COLOR = @"back_color.jpg";

// preferences
static NSString *kVIP_PREFERENCE_SHOW_COLOR = @"preferences.showColor";
static NSString *kVIP_PREFERENCE_PASSWORD = @"preferences.password";
static NSString *kVIP_PREFERENCE_CAMERA_MODE = @"preferences.cameraMode";
static NSString *kVIP_PREFERENCE_SHOW_CAMERA_INSTRUCTION_FRONT = @"preferences.cameraInstructionFront";
static NSString *kVIP_PREFERENCE_SHOW_CAMERA_INSTRUCTION_BACK = @"preferences.cameraInstructionBack";
static NSString *kVIP_PREFERENCE_ALLOW_DEPOSITS_EXCEEDING_LIMIT = @"preferences.allowDepositExceedingLimit";
static NSString *kVIP_PREFERENCE_DEBUG = @"preferences.debug";

// networking
static const int kVIP_MESSAGE_STATUS_SUCCESS = 0;
static const int kVIP_MESSAGE_STATUS_SERVER_ERROR = 1;
static const int kVIP_MESSAGE_STATUS_CONNECTION_ERROR = 2;
static const int kVIP_MESSAGE_STATUS_HANDLED_ERROR = 3;

// notifications
static NSString *kVIP_NOTIFICATION_DEPOSIT_LOGIN = @"VIPDepositLogin";
static NSString *kVIP_NOTIFICATION_DEPOSIT_INIT_COMPLETE = @"VIPDepositInitComplete";
static NSString *kVIP_NOTIFICATION_DEPOSIT_COMMIT_COMPLETE = @"VIPDepositCommitComplete";
static NSString *kVIP_NOTIFICATION_DEPOSIT_SUBMIT_COMPLETE = @"VIPDepositSubmitComplete";

@class DepositSubmitQueue;

@interface DepositModel : NSObject
{
    NSString *cacheDirectory;                       // application cache directory

    NSDictionary *dictSettings;                     // settings dictionary

    // camera and image properties
	CGRect rectViewPort;                            // camera viewport rectangle
    CGRect rectFront;                               // front image size
    CGRect rectBack;                                // back image size
    
    // deposit model
    NSString *routing;                              // FI routing #
    NSString *requestor;                            // FI requestor string
    NSString *userName;                             // user name
    NSString *userEmail;                            // user e-mail
    NSNumber *depositLimit;                         // per deposit limit
    NSNumber *depositAmount;                        // deposit amount
    NSNumber *depositAmountCAR;                     // CAR amount
    int registrationStatus;							// registration status
    int submittedDeposits;							// submitted deposit count
    NSData *htmlContent;                            // HTML content
    NSMutableArray *depositAccounts;                // list of deposit accounts
    NSInteger depositAccountSelected;               // selected account
    BOOL testMode;                                  // test mode
    BOOL loginProcessing;							// login processing flag
    BOOL isSmartScaled;                             // smart scaled
    
    // deposit submission
    DepositSubmitQueue *depositSubmitQueue;         // deposit submit queue
    NSString *ssoKey;                               // SSO key for images

    ResponseDictionary *dictMasterGeneral;			// deposit response dictionary - general
    ResponseDictionary *dictMasterFrontImage;		// deposit response dictionary - front image
    ResponseDictionary *dictMasterBackImage;		// deposit response dictionary - back image

    NSMutableDictionary *dictResultsGeneral;		// results - general
    NSMutableDictionary *dictResultsFrontImage;		// results - front image
    NSMutableDictionary *dictResultsBackImage;		// results - back image

    // DEBUG
    BOOL bDebugMode;
    NSMutableString *debugString;
}

// Properties
@property (readonly) NSDictionary *dictSettings;

@property (assign) CGRect rectViewPort;
@property (assign) CGRect rectFront;
@property (assign) CGRect rectBack;

@property (nonatomic, strong) NSString *routing;
@property (nonatomic, strong) NSString *requestor;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userEmail;
@property (nonatomic, strong) NSNumber *depositLimit;
@property (nonatomic, strong) NSNumber *depositAmount;
@property (nonatomic, strong) NSNumber *depositAmountCAR;
@property (assign) int registrationStatus;
@property (assign) int submittedDeposits;
@property (nonatomic, strong) NSData *htmlContent;
@property (nonatomic, strong) NSMutableArray *depositAccounts;
@property (assign) NSInteger depositAccountSelected;
@property (assign) BOOL testMode;

//===================================================================================
// IMPORTANT NOTE
// Allow Deposits Exceeding Limit is read from App Settings in this sample app.
// A Production app should NEVER make this a User settings!
// It might be something that is a build-time configuration enabled
// for a Financial Institution ... but don't allow a user to fiddle with this.
// Over limit deposits, even if allowed by the app, will always get held for
// review at the Vertifi back-end.
@property (assign) BOOL allowDepositsExceedingLimit;
//===================================================================================

// image properties
@property UIImage *frontImage;
@property (readonly) NSData *frontImageData;
@property (readonly) UIImage *frontImageThumb;
@property UIImage *frontImageColor;
@property (readonly) UIImage *frontImageColorThumb;
@property (readonly) NSData *frontImageColorData;
@property (readonly) BOOL frontImagePresent;

@property UIImage *backImage;
@property (readonly) NSData *backImageData;
@property (readonly) UIImage *backImageThumb;
@property UIImage *backImageColor;
@property (readonly) UIImage *backImageColorThumb;
@property (readonly) BOOL backImagePresent;

@property (assign) BOOL loginProcessing;
@property (assign) BOOL isSmartScaled;

@property (nonatomic, readonly) DepositSubmitQueue *depositSubmitQueue;
@property (nonatomic, strong) NSString *ssoKey;

@property (strong) ResponseDictionary *dictMasterGeneral;
@property (strong) ResponseDictionary *dictMasterFrontImage;
@property (strong) ResponseDictionary *dictMasterBackImage;

@property (strong) NSMutableDictionary *dictResultsGeneral;
@property (strong) NSMutableDictionary *dictResultsFrontImage;
@property (strong) NSMutableDictionary *dictResultsBackImage;

//===================================================================================
// IMPORTANT NOTE
// Debug properties are included in this sample app as an aid to help new integrators.
// This should NEVER be included in a Production app.
@property (assign) BOOL debugMode;
@property (strong) NSMutableString *debugString;
//===================================================================================

// Methods
+ (DepositModel *) sharedInstance;
- (id)init;
- (void) deleteFrontImage;
- (void) deleteBackImage;
- (void) deleteImage:(NSString *)filename;
- (void) clearDeposit;

// Login/Registration
- (void) registrationQuery;
- (void) parseRegistration:(NSXMLParser *)xml;

@end
