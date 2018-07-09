//
//  DepositModel.m
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

#import "DepositModel.h"

@implementation DepositModel

// Properties
@synthesize dictSettings;

@synthesize rectViewPort;
@synthesize rectFront;
@synthesize rectBack;

@synthesize routing;
@synthesize requestor;
@synthesize userName;
@synthesize userEmail;
@synthesize depositLimit;
@synthesize depositAmount;
@synthesize depositAmountCAR;
@synthesize registrationStatus;
@synthesize htmlContent;
@synthesize depositAccounts;
@synthesize depositAccountSelected;
@synthesize testMode;
@synthesize allowDepositsExceedingLimit;

@synthesize heldForReviewDepositsCount;
@synthesize depositHistory;

@synthesize endorsementThreshold;
@synthesize visionApiURL;
@synthesize visionApiKey;
@synthesize endorsements;
@synthesize iuRearEndorsement;

@synthesize isSmartScaled;

@synthesize networkQueue;
@synthesize ssoKey;

@synthesize depositId;
@synthesize depositDisposition;
@synthesize depositDispositionMessage;

@synthesize dictMasterGeneral;
@synthesize dictMasterFrontImage;
@synthesize dictMasterBackImage;

@synthesize resultsGeneral;
@synthesize resultsFrontImage;
@synthesize resultsBackImage;

@synthesize debugMode;
@synthesize debugString;

//--------------------------------------------------------------------------------------------
// Singleton model object
//--------------------------------------------------------------------------------------------

+ (DepositModel *) sharedInstance
{
	static DepositModel *instance = nil;
	
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (instance == nil)
        {
            instance = [[self alloc] init];
        }
    });
	
	return (instance);
}

//--------------------------------------------------------------------------------------------
// instance initialization
//--------------------------------------------------------------------------------------------

- (id)init
{
	if ((self = [super init]) != nil)
	{
        // application cache directory
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        cacheDirectory = [paths objectAtIndex:0];

        // load settings dictionary (Settings.plist)
        NSString *pathSettings = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
        dictSettings = [[NSDictionary alloc] initWithContentsOfFile:pathSettings];

        NSUserDefaults *defaults = [[NSUserDefaults alloc] init];

        self.rectViewPort = CGRectMake (0.005, 0.16, 0.99, 0.65);	// left: 0.5%, top: 16%, width: 99%, height: 65%
        self.rectFront = CGRectZero;
        self.rectBack = CGRectZero;

        // deposit model
        self.routing = nil;                                         // comes from account enumeration
        self.requestor = nil;
        self.userName = @"Joe User";
        self.userEmail = @"joe_user@gmail.com";

        self.ssoKey = nil;
        self.depositId = nil;
        self.depositDisposition = nil;
        self.depositDispositionMessage = nil;
        
        self.heldForReviewDepositsCount = 0;
        self.depositHistory = [NSMutableArray array];               // deposit history
        
        // some defaults to allow the program to work without credentials
        self.depositLimit = [NSNumber numberWithDouble:5000.00];    // should be 0
        self.depositAmount = [NSNumber numberWithDouble:0];
        self.depositAmountCAR = [NSNumber numberWithDouble:0];
        self.registrationStatus = kVIP_REGSTATUS_REGISTERED;        // should be -1 !!!
        
        // rear endorsement stuff
        self.endorsementThreshold = 85;
        self.visionApiURL = nil;
        self.visionApiKey = nil;
        self.endorsements = [NSMutableArray array];                 // rear endorsements
        self.iuRearEndorsement = IURearEndorsementNotTested;
        
        // create an initial default account to allow the program to partially function without credentials
        DepositAccount *accountDefault = [[DepositAccount alloc] init];
        accountDefault.name = @"Primary Checking";
        accountDefault.member = @"123456";
        accountDefault.account = @"123456-01";
        accountDefault.session = nil;
        accountDefault.timestamp = nil;
        accountDefault.accountType = @"1";
        accountDefault.MAC = nil;
        self.depositAccounts = [NSMutableArray arrayWithObject:accountDefault];
        self.depositAccountSelected = -1;
        
        // network processing
        self.networkQueue = [NetworkQueue sharedInstance];          // instantiate singleton
      
        self.testMode = YES;                                        // test mode!
        self.allowDepositsExceedingLimit = [defaults boolForKey:kVIP_PREFERENCE_ALLOW_DEPOSITS_EXCEEDING_LIMIT];    // allow deposits exceedinglimit

        //------------------------------------------------------------------------------------------
        //------------------------------------------------------------------------------------------
        // create and initialize master IQ/IU dictionaries
        //------------------------------------------------------------------------------------------
        //------------------------------------------------------------------------------------------

        //------------------------------------------------------------------------------------------
        // GENERAL ERRORS
        //------------------------------------------------------------------------------------------
        self.dictMasterGeneral = [[ResponseDictionary alloc] init];
        
        // from server
        [dictMasterGeneral addValues:@"InputValidation" value:@"Validation Error" help:@"" style:UITableViewCellAccessoryDetailButton];
        [dictMasterGeneral addValues:@"PreProcessing" value:@"Image Error" help:@"" style:UITableViewCellAccessoryDetailButton];
        [dictMasterGeneral addValues:@"SystemError" value:@"System Error" help:@"" style:UITableViewCellAccessoryDetailButton];

        // generated by App
        [dictMasterGeneral addValues:@"Pending" value:@"Pending" help:@"" style:UITableViewCellAccessoryNone];
        [dictMasterGeneral addValues:@"URLConnectionError" value:@"Connection Error" help:@"" style:UITableViewCellAccessoryDetailButton];
        [dictMasterGeneral addValues:@"IQFrontWarning" value:@"Front Image Quality Warning" help:@"There are warnings with the front image.  Please review the image, taking a new photo of the check if necessary. and re-submit your deposit." style:UITableViewCellAccessoryDetailButton];
        [dictMasterGeneral addValues:@"IQFrontError" value:@"Front Image Quality Error" help:@"There are errors with the front image.  Please take a new photo of the front and re-submit your deposit." style:UITableViewCellAccessoryDetailButton];
        [dictMasterGeneral addValues:@"IQBackError" value:@"Back Image Quality Error(s)" help:@"There are errors with the back image.  Please take a new photo of the back and re-submit your deposit." style:UITableViewCellAccessoryDetailButton];
        
        //------------------------------------------------------------------------------------------
        // FRONT IMAGE
        //------------------------------------------------------------------------------------------
        self.dictMasterFrontImage = [[ResponseDictionary alloc] init];

        // generated by App
        [dictMasterFrontImage addValues:@"NoError" value:@"No Errors" help:@"" style:UITableViewCellAccessoryCheckmark];
        [dictMasterFrontImage addValues:@"Pending" value:@"Pending" help:@"" style:UITableViewCellAccessoryNone];

        // from Deposit Init API or VIP Library
        [dictMasterFrontImage addValues:@"Recognition" value:@"General Recognition Error" help:@"The front image was not recognized as a check document." style:UITableViewCellAccessoryDetailButton];
        [dictMasterFrontImage addValues:@"ImageValidation" value:@"Image Error" help:@"The front image was not recognized as a check document." style:UITableViewCellAccessoryDetailButton];
        [dictMasterFrontImage addValues:@"OutOfMemory" value:@"Out of Memory" help:@"The device has insufficient memory for image processing" style:UITableViewCellAccessoryDetailButton];
        [dictMasterFrontImage addValues:@"FoldedCorners" value:@"Folded Corners" help:@"The front image appears to have folded or torn corners." style:UITableViewCellAccessoryDetailButton];
        [dictMasterFrontImage addValues:@"ExcessSkew" value:@"Excess Skew" help:@"The front image appears to be skewed." style:UITableViewCellAccessoryDetailButton];
        [dictMasterFrontImage addValues:@"TooDark" value:@"Image Too Dark" help:@"The front image is too dark." style:UITableViewCellAccessoryDetailButton];
        [dictMasterFrontImage addValues:@"TooLight" value:@"Image Too Light" help:@"The front image is too light." style:UITableViewCellAccessoryDetailButton];
        [dictMasterFrontImage addValues:@"BelowMinSize" value:@"Below Minimum Size" help:@"The front image is below the minimum file size." style:UITableViewCellAccessoryDetailButton];
        [dictMasterFrontImage addValues:@"AboveMaxSize" value:@"Above Maximum Size" help:@"The front image is above the maximum files size." style:UITableViewCellAccessoryDetailButton];
        [dictMasterFrontImage addValues:@"UndersizedImage" value:@"Image Too Small" help:@"The front image is too small in width and/or height." style:UITableViewCellAccessoryDetailButton];
        [dictMasterFrontImage addValues:@"OversizedImage" value:@"Image Too Large" help:@"The front image is too large in width and/or height." style:UITableViewCellAccessoryDetailButton];
        [dictMasterFrontImage addValues:@"SpotNoise" value:@"Excess Spot Noise" help:@"The front image has excess spot noise." style:UITableViewCellAccessoryDetailButton];
        [dictMasterFrontImage addValues:@"CropError" value:@"Cropping Error" help:@"The front image is not properly cropped. Use a solid colored contrasting surface for best results." style:UITableViewCellAccessoryDetailButton];
        [dictMasterFrontImage addValues:@"OutOfFocus" value:@"Out of Focus" help:@"The front image is out of focus." style:UITableViewCellAccessoryDetailButton];
        [dictMasterFrontImage addValues:@"MICRLocate" value:@"MICR Codeline Not Found" help:@"The MICR numbers along the bottom of the check image could not be located." style:UITableViewCellAccessoryDetailButton];
        
        [dictMasterFrontImage addValues:@"DateUsability" value:@"Date Missing" help:@"The check date could not be located on the image." style:UITableViewCellAccessoryDetailButton];
        [dictMasterFrontImage addValues:@"SignatureUsability" value:@"Signature Missing" help:@"The signature could not be located on the image." style:UITableViewCellAccessoryDetailButton];
        [dictMasterFrontImage addValues:@"PayeeUsability" value:@"Payee Name Missing" help:@"The payee name could not be located on the image." style:UITableViewCellAccessoryDetailButton];
        [dictMasterFrontImage addValues:@"PayorUsability" value:@"Payor Name Missing" help:@"The payor name could not be located on the image." style:UITableViewCellAccessoryDetailButton];
        [dictMasterFrontImage addValues:@"MICRUsability" value:@"MICR Codeline Unreadable" help:@"All or some of the MICR numbers along the bottom of the check image could not be read." style:UITableViewCellAccessoryDetailButton];
        
        //------------------------------------------------------------------------------------------
        // BACK IMAGE
        //------------------------------------------------------------------------------------------
        self.dictMasterBackImage = [[ResponseDictionary alloc] init];
        
        // generated by App
        [dictMasterBackImage addValues:@"NoError" value:@"No Errors" help:@"" style:UITableViewCellAccessoryCheckmark];
        [dictMasterBackImage addValues:@"Pending" value:@"Pending" help:@"" style:UITableViewCellAccessoryNone];

        // from Deposit Commit API or VIP Library
        [dictMasterBackImage addValues:@"Recognition" value:@"General Recognition Error" help:@"The front image was not recognized as a check document." style:UITableViewCellAccessoryDetailButton];
        [dictMasterBackImage addValues:@"ImageValidation" value:@"Image Error" help:@"The back image was not recognized as a check document." style:UITableViewCellAccessoryDetailButton];
        [dictMasterBackImage addValues:@"OutOfMemory" value:@"Out of Memory" help:@"The device has insufficient memory for image processing" style:UITableViewCellAccessoryDetailButton];
        [dictMasterBackImage addValues:@"FoldedCorners" value:@"Folded Corners" help:@"The back image appears to have folded or torn corners." style:UITableViewCellAccessoryDetailButton];
        [dictMasterBackImage addValues:@"ExcessSkew" value:@"Excess Skew" help:@"The back image appears to be skewed." style:UITableViewCellAccessoryDetailButton];
        [dictMasterBackImage addValues:@"TooDark" value:@"Image Too Dark" help:@"The back image is too dark." style:UITableViewCellAccessoryDetailButton];
        [dictMasterBackImage addValues:@"TooLight" value:@"Image Too Light" help:@"The back image is too light." style:UITableViewCellAccessoryDetailButton];
        [dictMasterBackImage addValues:@"BelowMinSize" value:@"Below Minimum Size" help:@"The back image is below the minimum file size." style:UITableViewCellAccessoryDetailButton];
        [dictMasterBackImage addValues:@"AboveMaxSize" value:@"Above Maximum Size" help:@"The back image is above the maximum files size." style:UITableViewCellAccessoryDetailButton];
        [dictMasterBackImage addValues:@"UndersizedImage" value:@"Image Too Small" help:@"The back image is too small in width and/or height." style:UITableViewCellAccessoryDetailButton];
        [dictMasterBackImage addValues:@"OversizedImage" value:@"Image Too Large" help:@"The back image is too large in width and/or height." style:UITableViewCellAccessoryDetailButton];
        [dictMasterBackImage addValues:@"OutOfScale" value:@"Back Image Not in Scale" help:@"The back image is a different size than the front. One or the other is improperly cropped. Please review the front photo and re-take if it appears improperly cropped." style:UITableViewCellAccessoryDetailButton];
        [dictMasterBackImage addValues:@"CropError" value:@"Cropping Error" help:@"The back image is not properly cropped. Use a solid colored contrasting surface for best results." style:UITableViewCellAccessoryDetailButton];
        [dictMasterBackImage addValues:@"OutOfFocus" value:@"Out of Focus" help:@"The back image is out of focus." style:UITableViewCellAccessoryDetailButton];
        [dictMasterBackImage addValues:@"MICRLocate" value:@"Wrong Side" help:@"This appears to be a front check image, please flip the check over." style:UITableViewCellAccessoryDetailButton];
        [dictMasterBackImage addValues:@"RearEndorsement" value:@"Missing Endorsement" help:@"The endorsement on the back of the check appears to be missing or incomplete." style:UITableViewCellAccessoryDetailButton];

        // error arrays
        self.resultsGeneral = [NSMutableArray array];
        self.resultsFrontImage = [[NSMutableArray alloc] initWithCapacity:10];
        self.resultsBackImage = [[NSMutableArray alloc] initWithCapacity:10];
     
        // Debug
        self.debugMode = [defaults boolForKey:kVIP_PREFERENCE_DEBUG];
	}
	return (self);
}

//----------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------
// Image properties
//----------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------

#pragma mark Image properties

//--------------------------------------------------------------------------------------------
// front image
//--------------------------------------------------------------------------------------------

- (UIImage *) frontImage
{
    // load front image from cached file (if exists)
    NSString *cacheFile = [NSString stringWithFormat:@"%@/%@", cacheDirectory, kVIP_FRONT_IMAGE];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFile])
    {
        UIImage *image = [UIImage imageWithContentsOfFile:cacheFile];
        rectFront = CGRectMake(0,0,image.size.width,image.size.height);
        return (image);
    }
    
    rectFront = CGRectZero;
    [resultsGeneral removeAllObjects];
    [resultsFrontImage removeAllObjects];
    return (nil);
}

- (NSData *) frontImageData
{
    // load front image from cached file (if exists)
    NSString *cacheFile = [NSString stringWithFormat:@"%@/%@", cacheDirectory, kVIP_FRONT_IMAGE];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFile])
        return ([NSData dataWithContentsOfFile:cacheFile]);
    return (nil);
}

- (UIImage *) frontImageThumb
{
    return ([self createThumb:self.frontImage]);
}

- (void) setFrontImage:(UIImage *)image
{
    // Save images to file system
    NSString *cacheFile = [NSString stringWithFormat:@"%@/%@", cacheDirectory, kVIP_FRONT_IMAGE];
    
    if (image == nil)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:cacheFile])
            [fileManager removeItemAtPath:cacheFile error:NULL];
        rectFront = CGRectZero;
        [resultsGeneral removeAllObjects];
        [resultsFrontImage removeAllObjects];
    }
    else
    {
        [UIImagePNGRepresentation(image) writeToFile:cacheFile atomically:NO];
        rectFront = CGRectMake(0,0,image.size.width,image.size.height);
    }
    return;
}

- (UIImage *) frontImageColor
{
    // load front image from cached file (if exists)
    NSString *cacheFile = [NSString stringWithFormat:@"%@/%@", cacheDirectory, kVIP_FRONT_IMAGE_COLOR];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFile])
    {
        UIImage *image = [UIImage imageWithContentsOfFile:cacheFile];
        return (image);
    }
    
    return (nil);
}

- (NSData *) frontImageColorData
{
    // load front color image from cached file (if exists)
    NSString *cacheFile = [NSString stringWithFormat:@"%@/%@", cacheDirectory, kVIP_FRONT_IMAGE_COLOR];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFile])
        return ([NSData dataWithContentsOfFile:cacheFile]);
    return (nil);
}

- (UIImage *) frontImageColorThumb
{
    return ([self createThumb:self.frontImageColor]);
}

- (void) setFrontImageColor:(UIImage *)imageColor
{
    // Save image to file system
    NSString *cacheFileColor = [NSString stringWithFormat:@"%@/%@", cacheDirectory, kVIP_FRONT_IMAGE_COLOR];
    
    if (imageColor == nil)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:cacheFileColor])
            [fileManager removeItemAtPath:cacheFileColor error:NULL];
    }
    else
    {
        // 30% lossy!
        [UIImageJPEGRepresentation(imageColor,0.3f) writeToFile:cacheFileColor atomically:NO];
    }
    return;
}

- (BOOL) frontImagePresent
{
    // test for existence
    NSString *cacheFile = [NSString stringWithFormat:@"%@/%@", cacheDirectory, kVIP_FRONT_IMAGE];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:cacheFile])
        return (YES);
    
    return (NO);
}

//--------------------------------------------------------------------------------------------
// back image
//--------------------------------------------------------------------------------------------

- (UIImage *) backImage
{
    // load back image from cached file (if exists)
    NSString *cacheFile = [NSString stringWithFormat:@"%@/%@", cacheDirectory, kVIP_BACK_IMAGE];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFile])
    {
        UIImage *image = [UIImage imageWithContentsOfFile:cacheFile];
        rectBack = CGRectMake(0,0,image.size.width,image.size.height);
        return (image);
    }
    
    rectBack = CGRectZero;
    [resultsBackImage removeAllObjects];
    return (nil);
}

- (NSData *) backImageData
{
    // load back image from cached file (if exists)
    NSString *cacheFile = [NSString stringWithFormat:@"%@/%@", cacheDirectory, kVIP_BACK_IMAGE];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFile])
        return ([NSData dataWithContentsOfFile:cacheFile]);
    return (nil);
}

// new to v7.5
- (NSData *) backImageColorData
{
    // load back color image from cached file (if exists)
    NSString *cacheFile = [NSString stringWithFormat:@"%@/%@", cacheDirectory, kVIP_BACK_IMAGE_COLOR];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFile])
        return ([NSData dataWithContentsOfFile:cacheFile]);
    return (nil);
}

- (UIImage *) backImageThumb
{
    return ([self createThumb:self.backImage]);
}

- (void) setBackImage:(UIImage *)image
{
    // Save images to file system
    NSString *cacheFile = [NSString stringWithFormat:@"%@/%@", cacheDirectory, kVIP_BACK_IMAGE];
    
    if (image == nil)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:cacheFile])
            [fileManager removeItemAtPath:cacheFile error:NULL];
        rectBack = CGRectZero;
        [resultsBackImage removeAllObjects];
    }
    else
    {
        [UIImagePNGRepresentation(image) writeToFile:cacheFile atomically:NO];
        rectBack = CGRectMake(0,0,image.size.width,image.size.height);
    }
    return;
}

- (UIImage *) backImageColor
{
    // load back image from cached file (if exists)
    NSString *cacheFile = [NSString stringWithFormat:@"%@/%@", cacheDirectory, kVIP_BACK_IMAGE_COLOR];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFile])
    {
        UIImage *image = [UIImage imageWithContentsOfFile:cacheFile];
        return (image);
    }
    
    return (nil);
}

- (UIImage *) backImageColorThumb
{
    return ([self createThumb:self.backImageColor]);
}

- (void) setBackImageColor:(UIImage *)imageColor
{
    // Save image to file system
    NSString *cacheFileColor = [NSString stringWithFormat:@"%@/%@", cacheDirectory, kVIP_BACK_IMAGE_COLOR];
    
    if (imageColor == nil)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:cacheFileColor])
            [fileManager removeItemAtPath:cacheFileColor error:NULL];
    }
    else
    {
        // 30% lossy!
        [UIImageJPEGRepresentation(imageColor,0.3f) writeToFile:cacheFileColor atomically:NO];
    }
    return;
}

- (BOOL) backImagePresent
{
    // test for existence
    NSString *cacheFile = [NSString stringWithFormat:@"%@/%@", cacheDirectory, kVIP_BACK_IMAGE];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:cacheFile])
        return (YES);
    
    return (NO);
}

//----------------------------------------------------------------------------------------------
// Core Graphics create thumbnail
//----------------------------------------------------------------------------------------------

- (UIImage *) createThumb:(UIImage *)image
{
    if (image == nil)
        return (nil);
    
    UIScreen *screen = [UIScreen mainScreen];
    CGFloat width = screen.bounds.size.width * screen.scale;
    CGFloat height = (width / image.size.width) * image.size.height;
    
    CGRect rectScale = CGRectMake(0,0,width,height);
    CGContextRef bitmap = CGBitmapContextCreate(NULL, rectScale.size.width, rectScale.size.height, CGImageGetBitsPerComponent(image.CGImage),0,CGImageGetColorSpace(image.CGImage),CGImageGetBitmapInfo(image.CGImage));
    CGContextSetInterpolationQuality(bitmap, kCGInterpolationMedium);
    CGContextDrawImage(bitmap, rectScale, image.CGImage);
    CGImageRef scaledImageRef = CGBitmapContextCreateImage(bitmap);
    UIImage *scaledImage = [UIImage imageWithCGImage:scaledImageRef];
    CGContextRelease(bitmap);
    CGImageRelease(scaledImageRef);
    
    return (scaledImage);
}

//----------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------
// Deposit maintenance
//----------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------

#pragma mark Maintenance

//--------------------------------------------------------------------------------------------
// delete front image
//--------------------------------------------------------------------------------------------

- (void) deleteFrontImage
{
    [self deleteImage:kVIP_FRONT_IMAGE];
    [self deleteImage:kVIP_FRONT_IMAGE_COLOR];
    self.rectFront = CGRectZero;
}

//--------------------------------------------------------------------------------------------
// delete back image
//--------------------------------------------------------------------------------------------

- (void) deleteBackImage
{
    [self deleteImage:kVIP_BACK_IMAGE];
    [self deleteImage:kVIP_BACK_IMAGE_COLOR];
    self.rectBack = CGRectZero;
}

//--------------------------------------------------------------------------------------------
// delete image helper
//--------------------------------------------------------------------------------------------

- (void) deleteImage:(NSString *)filename
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *cacheFile = [NSString stringWithFormat:@"%@/%@", cacheDirectory,filename];
    if ([fileManager fileExistsAtPath:cacheFile])
        [fileManager removeItemAtPath:cacheFile error:NULL];
    
}

//----------------------------------------------------------------------------------------------
// Clear deposit
//----------------------------------------------------------------------------------------------

- (void) clearDeposit
{
    [self deleteFrontImage];
    [self deleteBackImage];
    
    self.depositAmount = [NSNumber numberWithDouble:0];
    self.depositAmountCAR = [NSNumber numberWithDouble:0];
    self.ssoKey = nil;
    self.depositId = nil;
    self.depositDisposition = nil;
    self.depositDispositionMessage = nil;

    [self.resultsGeneral removeAllObjects];
    [self.resultsFrontImage removeAllObjects];
    [self.resultsBackImage removeAllObjects];
}

//----------------------------------------------------------------------------------------------
// Clear held for review deposit
//----------------------------------------------------------------------------------------------

- (void) clearHeldForReviewDeposits
{
    self.depositHistory = [NSMutableArray array];
}

//-----------------------------------------------------------------------------
// Has Error - checks error dictionary
//-----------------------------------------------------------------------------

- (BOOL) hasError:(NSArray *)results
{
    if (results.count > 0)                                          // error array
    {
        for (NSString *key in results)
        {
            if (![key hasSuffix:@"Usability"])                      // doesn't end in "Usability"
                return (YES);
        }
    }
    return (NO);
}

//-----------------------------------------------------------------------------
// Has Warning - checks error dictionary
//-----------------------------------------------------------------------------

- (BOOL) hasWarning:(NSArray *)results
{
    if (results.count > 0)                                         // error dictionary
    {
        for (NSString *key in results)
        {
            if ([key hasSuffix:@"Usability"])                      // ends in "Usability"
                return (YES);
        }
    }
    return (NO);
}

@end
