//
//  UtilitiesHelper.h
//
// 
//
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"
//#import "LMAlertView.h"
//#import "BlocksKit.h"




//#ifndef IS_IPHONE_5
//#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
//#endif
//
//#ifndef IS_IPAD
//#define IS_IPAD    (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad)
//#endif

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define NSNullIfNil(v) (v ? v : [NSNull null])


@interface UtilitiesHelper : NSObject
{
    
    
    __block UIView *objLoaderView;

    
}


+ (id)shareUtitlities;
+ (id)getUserDefaultForKey:(NSString*)key;
+ (void)setUserDefaultForKey:(NSString*)key  value:(NSString*)value;
+(void)showLoader:(NSString *)title forView:(UIView *)view  setMode:(MBProgressHUDMode)mode delegate:(id)vwDelegate;
+(void)hideLoader:(UIView*)forView;
+(void)showLMAlertforTitle:(NSString *)title withMessage:(NSString *)message forDelegate:(id)deleg;
+(void)showPromptAlertforTitle:(NSString *)title withMessage:(NSString *)message forDelegate:(id)deleg;
+(BOOL) validateEmail:(NSString *)checkEmail;
+(BOOL)validateURL:(NSString *)checkURL;
+(NSURL *)imageURLMaker :(NSString *)imgUrl;
+(BOOL) checkForEmptySpaces:(UITextField *)textField;
+(void)writeJsonToFile:(id)responseString withFileName:(NSString*)fileName;
//+(id)writeJsonToFile:(NSString*)fileName;
+(id)readJsonFromFile:(NSString*)fileName;
+(BOOL) validateFullName:(NSString *)checkFullName;
+(BOOL) checkForEmptySpacesInTextView : (UITextView *)textView;
+(BOOL) checkAlphabets:(NSString *)text;
+(BOOL) checkForEmptySpacesInString : (NSString *)rawString;
+(BOOL) checkPassword:(NSString *)text;
+(BOOL) checkPhoneNumber:(NSString *)text;
+(BOOL) checkFaxNumber:(NSString *)text;
+(BOOL) validateUsername:(NSString*)checkUsername;
+ (id)loadNibNamed:(NSString *)nibName ofClass:(Class)objClass;
+(NSString *) addSuffixToNumber:(NSInteger) number;
+(void)createLayerWithRoundRect:(UIView*)view;
+(NSString *) getStringFromObject:(NSObject *) object;
+(NSString *) getEmptyStringFromObjectIfNull:(NSObject *) object;
+(void)createLayerWithRoundRect:(UIView*)view radius:(float)radius;


+ (NSDate *) getDateFromString : (NSString *)dateString;
+ (NSDate *) getUTCDateFromString : (NSString *)dateString;

+ (NSString *) getDateFromSQLDate : (NSString *)datePlusTime;
+ (NSString *) getLocalDateFromUTCDate :(NSString *)gmtDateStr;
+ (NSString *) getTimeFromSQLDate : (NSString *)datePlusTime;
+ (NSString *) getCurrentDateTimeAsString;

+(NSString *)getDateFromString:(NSString *)string withDateFormat:(NSString*)format withFormat:(NSString*)formatString;
+(NSString*)getCurrentDateInGmt;
+(NSString *) jsonFragmentOfArray:(NSArray *)array;
+(NSString *) stringByStrippingHTML:(NSString*) htmlString;

+(NSString *) getDurationFromTime:(NSString *) source;

-(void)showToastWithMessage:(NSString*)message title:(NSString*)title delegate:(id)delegate;
-(void)showToastWithMessage:(NSString*)message title:(NSString*)title delegate:(id)delegate completion:(void (^)(bool completed))block;
-(void)showAlertWithMessage:(NSString*)message title:(NSString*)title delegate:(id)delegate;
-(void)showAlertWithMessage:(NSString*)message title:(NSString*)title delegate:(id)delegate completion:(void (^)(bool completed))block;
-(void)showOptionWithMessage:(NSString*)message title:(NSString*)title delegate:(id)delegate completion:(void (^)(bool completed))block;
+(void)addActivityIndicatorToView:(UIView*)view;
+(void)removeActivityIndicatorToView:(UIView*)view;

+(NSString*)getDeviceIdentifier;
+(BOOL)isGpsOn;
+ (BOOL) isFaceIDAvailable;
-(void)showLAContextWithDelegate:(id)delegate completionBlock:(void(^)(BOOL success))block;
+(void)isTouchIDAvailableWithDelegate:(id)delegate completionBlock:(void(^)(BOOL success))block;


- (void)startTimerWithCompletionBlock:(void(^)(BOOL  sucess))block;
- (void)cancelTimer;

+(void)shouldHideTouchID:(id)delegate completionBlock:(void(^)(BOOL success))block;

+ (NSString *)GetOurIpAddress ;
+ (NSString *)deviceModel ;
+ (NSString*) getSystemLanguageCode ;
@end

