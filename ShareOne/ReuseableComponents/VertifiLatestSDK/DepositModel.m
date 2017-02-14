//
//  DepositModel.m
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

#import "DepositModel.h"
#import "FormPostHandler.h"
#import "XmlSimpleParser.h"

#define REQUESTER_VALUE             @"700000465-Shareone"
#define ROUTING_VALUE               @"700000465"
#define ACCOUNT                     @"666"
#define KEY_VALUE                   @"f481c1cf086a89dd9018b515525021f5"


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
@synthesize submittedDeposits;
@synthesize htmlContent;
@synthesize depositAccounts;
@synthesize depositAccountSelected;
@synthesize ssoKey;
@synthesize testMode;

@synthesize loginProcessing;

@synthesize dictMasterGeneral;
@synthesize dictMasterFrontImage;
@synthesize dictMasterBackImage;

@synthesize dictResultsGeneral;
@synthesize dictResultsFrontImage;
@synthesize dictResultsBackImage;

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

        self.rectViewPort = CGRectMake (0.005, 0.16, 0.99, 0.65);	// left: 0.5%, top: 16%, width: 99%, height: 65%
        self.rectFront = CGRectZero;
        self.rectBack = CGRectZero;

        // deposit model
        self.routing = ROUTING_VALUE;                                         // comes from account enumeration
        self.requestor = REQUESTER_VALUE;
        self.userName = @"spike";
        self.userEmail = @"ggwyn@shareone.com";

        // some defaults to allow the program to work without credentials
        self.depositLimit = [NSNumber numberWithDouble:5000.00];    // should be 0
        self.depositAmount = [NSNumber numberWithDouble:0];
        self.depositAmountCAR = [NSNumber numberWithDouble:0];
        self.registrationStatus = kVIP_REGSTATUS_REGISTERED;        // should be -1
        self.submittedDeposits = 0;
        self.loginProcessing = NO;
        
        // create an initial default account to allow the program to partially function without credentials
        DepositAccount *accountDefault = [[DepositAccount alloc] init];
        accountDefault.name = @"Primary Checking";
        accountDefault.member = ACCOUNT;
        accountDefault.account = @"666";
        accountDefault.session = @"Klko4DmW3CAW2oJai4Iz1TUyD3YiR4V8wv5o89SHYDSq29rTmnNfcCtoGaxakbMXOKNvPZ97AoNFUx9m";
        accountDefault.timestamp = nil;
        accountDefault.accountType = @"1";
        accountDefault.MAC = nil;
        self.depositAccounts = [NSMutableArray arrayWithObject:accountDefault];
        self.depositAccountSelected = -1;
        
        // deposit submission
        depositSubmitQueue = nil;                                   // instantiate on demand
        self.ssoKey = nil;
        self.testMode = YES;                                        // test mode!
        
        // create and initialize master IQ/IU dictionaries
        self.dictMasterGeneral = [[ResponseDictionary alloc] init];
        [dictMasterGeneral addValues:@"URLConnectionError" value:@"Connection Error" help:@"" style:UITableViewCellAccessoryDetailButton];
        [dictMasterGeneral addValues:@"InputValidation" value:@"Validation Error" help:@"" style:UITableViewCellAccessoryDetailButton];
        [dictMasterGeneral addValues:@"PreProcessing"	value:@"Image Error" help:@"" style:UITableViewCellAccessoryDetailButton];
        [dictMasterGeneral addValues:@"Database"	value:@"Validation Error" help:@"" style:UITableViewCellAccessoryDetailButton];
        [dictMasterGeneral addValues:@"SystemError" value:@"System Error" help:@"" style:UITableViewCellAccessoryDetailButton];
        [dictMasterGeneral addValues:@"SessionError" value:@"Session Expired" help:@"Your login session has expired" style:UITableViewCellAccessoryDetailButton];
        [dictMasterGeneral addValues:@"IQFrontWarning" value:@"Front Image Quality Warning" help:@"There are warnings with the front image.  Please review the image, taking a new photo of the check if necessary. and re-submit your deposit." style:UITableViewCellAccessoryDetailButton];
        [dictMasterGeneral addValues:@"IQFrontError" value:@"Front Image Quality Error" help:@"There are errors with the front image.  Please take a new photo of the front and re-submit your deposit." style:UITableViewCellAccessoryDetailButton];
        [dictMasterGeneral addValues:@"IQBackError" value:@"Back Image Quality Error(s)" help:@"There are errors with the back image.  Please take a new photo of the back and re-submit your deposit." style:UITableViewCellAccessoryDetailButton];
        [dictMasterGeneral addValues:@"IQError" value:@"Image Quality Errors" help:@"There are errors with the front and back images.  Please take new photos and re-submit your deposit." style:UITableViewCellAccessoryDetailButton];
        
        [dictMasterGeneral addValues:@"DepositID"	value:@"" help:@"" style:UITableViewCellAccessoryCheckmark];
        [dictMasterGeneral addValues:@"DepositDisposition" value:@"" help:@"" style:UITableViewCellAccessoryCheckmark];
        
        self.dictMasterFrontImage = [[ResponseDictionary alloc] init];
        [dictMasterFrontImage addValues:@"NoError" value:@"No Errors" help:@"" style:UITableViewCellAccessoryCheckmark];
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
        
        [dictMasterFrontImage addValues:@"DateUsability" value:@"Date Missing" help:@"The check date could not be located on the image." style:UITableViewCellAccessoryDetailButton];
        [dictMasterFrontImage addValues:@"SignatureUsability" value:@"Signature Missing" help:@"The signature could not be located on the image." style:UITableViewCellAccessoryDetailButton];
        [dictMasterFrontImage addValues:@"PayeeUsability" value:@"Payee Name Missing" help:@"The payee name could not be located on the image." style:UITableViewCellAccessoryDetailButton];
        [dictMasterFrontImage addValues:@"PayorUsability" value:@"Payor Name Missing" help:@"The payor name could not be located on the image." style:UITableViewCellAccessoryDetailButton];
        [dictMasterFrontImage addValues:@"MICRUsability" value:@"MICR Codeline Unreadable" help:@"The MICR numbers along the bottom of the check image could not be read." style:UITableViewCellAccessoryDetailButton];
        
        self.dictMasterBackImage = [[ResponseDictionary alloc] init];
        [dictMasterBackImage addValues:@"NoError" value:@"No Errors" help:@"" style:UITableViewCellAccessoryCheckmark];
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
        
        self.dictResultsGeneral = [[NSMutableDictionary alloc] initWithCapacity:2];
        self.dictResultsFrontImage = [[NSMutableDictionary alloc] initWithCapacity:10];
        self.dictResultsBackImage = [[NSMutableDictionary alloc] initWithCapacity:10];
        
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
    [dictResultsGeneral removeAllObjects];
    [dictResultsFrontImage removeAllObjects];
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
        [dictResultsGeneral removeAllObjects];
        [dictResultsFrontImage removeAllObjects];
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
    [dictResultsBackImage removeAllObjects];
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
        [dictResultsBackImage removeAllObjects];
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
    [depositSubmitQueue onSubmitCancel];

    [self deleteFrontImage];
    [self deleteBackImage];
    
    self.depositAmount = [NSNumber numberWithDouble:0];
    self.depositAmountCAR = [NSNumber numberWithDouble:0];
    self.ssoKey = nil;

    [self.dictResultsGeneral removeAllObjects];
    [self.dictResultsFrontImage removeAllObjects];
    [self.dictResultsBackImage removeAllObjects];
}

//----------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------
// Registration query processing
//----------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------

#pragma mark Registration query

//----------------------------------------------------------------------------------------------
// Registration query
//----------------------------------------------------------------------------------------------

- (void)registrationQuery
{
    DepositAccount *account = [depositAccounts objectAtIndex:depositAccountSelected];

    // perform login
    if ((account != nil) && (account.MAC != nil) && (self.loginProcessing == NO))
    {
        self.loginProcessing = YES;

        // initialize values
        self.registrationStatus = -1;
        self.htmlContent = nil;
        self.depositLimit = 0;
        self.submittedDeposits = 0;
        
        [self clearDeposit];                            // clear the deposit data
        
        FormPostHandler *postHandler = [[FormPostHandler alloc] init];
        NSURL *postURL = [postHandler getURLFromHost:[dictSettings valueForKey:@"URL_RDCHost"] withPath:[dictSettings valueForKey:@"Path_RegistrationQuery"]];
        
        MultipartForm *form = [[MultipartForm alloc] initWithURL:postURL];
        
        // fields
        [form addFormField:@"requestor" withStringData:self.requestor];
        [form addFormField:@"session" withStringData:account.session];
        [form addFormField:@"timestamp" withStringData:account.timestamp];
        [form addFormField:@"routing" withStringData:self.routing];
        [form addFormField:@"member" withStringData:account.member];
        [form addFormField:@"account" withStringData:account.account];
        [form addFormField:@"MAC" withStringData:account.MAC];
        [form addFormField:@"membername" withStringData:self.userName];
        [form addFormField:@"email" withStringData:self.userEmail];
        [form addFormField:@"mode" withStringData:self.testMode ? @"test" : @"prod"];
        
        // Post the message
        [postHandler postBackgroundFormWithRequest:form toURL:postURL completion:^(BOOL success, NSData *data, NSError *error)
        {
             self.loginProcessing = NO;
             
             if (success)
             {
                 NSXMLParser *xml = [[NSXMLParser alloc] initWithData:data];
                 [self parseRegistration:xml];
             }
             else
             {
                 NSLog(@"%@ connection failed: %@ ; %@", self.class, [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
                 
             }
        }];
        
    }
    
}

//-----------------------------------------------------------------------------
// parseRegistration
//-----------------------------------------------------------------------------

- (void) parseRegistration:(NSXMLParser *)xml
{
    NSString *strValue;
    
    XmlSimpleParser *parser = [[XmlSimpleParser alloc] initXmlParser];
    
    [xml setDelegate:parser];
    [xml parse];
    {
        strValue = (NSString *)[parser.dictElements valueForKey:@"LoginValidation"];
        if (strValue != nil)
        {
            if ([strValue isEqualToString:@"OK"])
            {
                self.registrationStatus = kVIP_REGSTATUS_REGISTERED;
            }
            else if ([strValue isEqualToString:@"User Registration Pending Approval"])
            {
                self.registrationStatus = kVIP_REGSTATUS_PENDING;
            }
            else if ([strValue isEqualToString:@"User Not Registered"])
            {
                self.registrationStatus = kVIP_REGSTATUS_UNREGISTERED;
            }
            else if ([strValue isEqualToString:@"User Registration Disabled"])
            {
                self.registrationStatus = kVIP_REGSTATUS_DISABLED;
            }
        }
        
        strValue = (NSString *)[parser.dictElements valueForKey:@"EUAContents"];
        if (strValue != nil)
        {
            self.htmlContent = [[NSData alloc] initWithBase64EncodedString:strValue options:0];
        }
        
        strValue =(NSString *)[parser.dictElements valueForKey:@"PendingContents"];
        if (strValue != nil)
        {
            self.htmlContent = [[NSData alloc] initWithBase64EncodedString:strValue options:0];
        }
        
        strValue =(NSString *)[parser.dictElements valueForKey:@"DeniedContents"];
        if (strValue != nil)
        {
            self.htmlContent = [[NSData alloc] initWithBase64EncodedString:strValue options:0];
        }
        
        strValue = (NSString *)[parser.dictElements valueForKey:@"DepositLimit"];
        if (strValue != nil)
            self.depositLimit = [NSNumber numberWithDouble:[strValue doubleValue]];
        
        strValue = (NSString *)[parser.dictElements valueForKey:@"SubmittedDeposits"];
        if (strValue != nil)
            self.submittedDeposits = [strValue intValue];
        
        // send notification
        [[NSNotificationCenter defaultCenter] postNotificationName:kVIP_NOTIFICATION_DEPOSIT_LOGIN object:self];
        
    }
}

//----------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------
// Deposit Submission
//----------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------

#pragma mark Deposit submission

//--------------------------------------------------------------------------------------------
// deposit submit queue
//--------------------------------------------------------------------------------------------

- (DepositSubmitQueue *) depositSubmitQueue
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (depositSubmitQueue == nil)
            depositSubmitQueue = [[DepositSubmitQueue alloc] init];
    });

    return (depositSubmitQueue);
}

@end
