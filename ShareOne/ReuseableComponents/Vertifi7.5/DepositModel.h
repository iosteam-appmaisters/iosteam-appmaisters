//
//  DepositModel.h
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

#import <Foundation/Foundation.h>
#import "DepositAccount.h"
#import "NetworkQueue.h"
#import "ResponseDictionary.h"
#import "DepositHistory.h"

#import <VIPLibrary/VIPLibrary.h>

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

// keys
static NSString *kVIP_KEY_DELETED_ROW = @"key.rowDeleted";
static NSString *kVIP_KEY_ERROR = @"key.error";
static NSString *kVIP_KEY_REPORT_URL = @"key.reportUrl";

// deposit history Status
static NSString *kVIP_DEPOSIT_STATUS_HELD_FOR_REVIEW = @"Held for Review";
static NSString *kVIP_DEPOSIT_STATUS_ACCEPTED = @"Accepted";
static NSString *kVIP_DEPOSIT_STATUS_DELETED = @"Deleted";

// notifications
static NSString *kVIP_NOTIFICATION_DEPOSIT_REGISTRATION_QUERY_COMPLETE = @"VIPDepositRegistrationQueryComplete";
static NSString *kVIP_NOTIFICATION_DEPOSIT_INIT_COMPLETE = @"VIPDepositInitComplete";
static NSString *kVIP_NOTIFICATION_DEPOSIT_COMMIT_COMPLETE = @"VIPDepositCommitComplete";
static NSString *kVIP_NOTIFICATION_DEPOSIT_SUBMIT_COMPLETE = @"VIPDepositSubmitComplete";
static NSString *kVIP_NOTIFICATION_HISTORY_AUDIT_QUERY_COMPLETE = @"VIPDepositHistoryAuditQueryComplete";
static NSString *kVIP_NOTIFICATION_HELD_FOR_REVIEW_DELETE_COMPLETE = @"VIPDepositHeldForReviewDeleteComplete";
static NSString *kVIP_NOTIFICATION_DEPOSIT_REPORT_COMPLETE = @"VIPDepositDepositReportComplete";

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
    NSData *htmlContent;                            // HTML content
    NSMutableArray *depositAccounts;                // list of deposit accounts
    NSInteger depositAccountSelected;               // selected account
    BOOL testMode;                                  // test mode
    BOOL isSmartScaled;                             // smart scaled

    NSString *ssoKey;                               // SSO key for images
    NSNumber *depositId;                            // deposit ID
    NSString *depositDisposition;                   // deposit disposition
    NSString *depositDispositionMessage;            // deposit disposition message

    // deposits held for review
    int heldForReviewDepositsCount;                 // held for review deposit count
    NSMutableArray<DepositHistory *> *depositHistory;  // deposit history
    
    // rear endorsement testing
    int endorsementThreshold;                       // rear endorsement scoring threshold
    NSString *visionApiURL;                         // Google Vision API URL
    NSString *visionApiKey;                         // Google Vision API key
    NSMutableArray<NSString *> *endorsements;       // valid endorsement strings
    IURearEndorsement iuRearEndorsement;            // rear endorsement test
    
    // Networking
    NetworkQueue *networkQueue;                     // network NSOperationQueue

    // Errors
    ResponseDictionary *dictMasterGeneral;			// deposit response dictionary - general
    ResponseDictionary *dictMasterFrontImage;		// deposit response dictionary - front image
    ResponseDictionary *dictMasterBackImage;		// deposit response dictionary - back image

    NSMutableArray<NSString *> *resultsGeneral;		// results - general
    NSMutableArray<NSString *> *resultsFrontImage;	// results - front image
    NSMutableArray<NSString *> *resultsBackImage;	// results - back image

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
@property (nonatomic, strong) NSData *htmlContent;
@property (nonatomic, strong) NSMutableArray *depositAccounts;
@property (assign) NSInteger depositAccountSelected;
@property (assign) BOOL testMode;

@property (nonatomic, strong) NSString *ssoKey;
@property (nonatomic, strong) NSNumber *depositId;
@property (nonatomic, strong) NSString *depositDisposition;
@property (nonatomic, strong) NSString *depositDispositionMessage;

@property (assign) int heldForReviewDepositsCount;
@property (nonatomic, strong) NSMutableArray<DepositHistory *> *depositHistory;

@property (assign) int endorsementThreshold;
@property (nonatomic, strong) NSString *visionApiURL;
@property (nonatomic, strong) NSString *visionApiKey;
@property (nonatomic, strong) NSMutableArray<NSString *> *endorsements;
@property (assign) IURearEndorsement iuRearEndorsement;

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
@property (readonly) NSData *frontImageColorData;
@property (readonly) UIImage *frontImageColorThumb;
@property (readonly) BOOL frontImagePresent;

@property UIImage *backImage;
@property (readonly) NSData *backImageData;
@property (readonly) UIImage *backImageThumb;
@property UIImage *backImageColor;
@property (readonly) NSData *backImageColorData;
@property (readonly) UIImage *backImageColorThumb;
@property (readonly) BOOL backImagePresent;

@property (assign) BOOL isSmartScaled;

@property (nonatomic, strong) NetworkQueue *networkQueue;

@property (strong) ResponseDictionary *dictMasterGeneral;
@property (strong) ResponseDictionary *dictMasterFrontImage;
@property (strong) ResponseDictionary *dictMasterBackImage;

@property (strong) NSMutableArray<NSString *> *resultsGeneral;
@property (strong) NSMutableArray<NSString *> *resultsFrontImage;
@property (strong) NSMutableArray<NSString *> *resultsBackImage;

//===================================================================================
// IMPORTANT NOTE
// Debug properties are included in this sample app as an aid to help new integrators.
// This should NEVER be included in a Production app.
@property (assign) BOOL debugMode;
@property (strong) NSMutableString *debugString;
//===================================================================================

// Methods
+ (instancetype) sharedInstance;
- (instancetype) init;
- (UIImage *) createThumb:(UIImage *)image;
- (void) deleteFrontImage;
- (void) deleteBackImage;
- (void) deleteImage:(NSString *)filename;
- (void) clearDeposit;
- (void) clearHeldForReviewDeposits;
- (BOOL) hasError:(NSArray *)results;
- (BOOL) hasWarning:(NSArray *)results;

@end
