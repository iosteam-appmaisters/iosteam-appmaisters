
//  UtilitiesHelper.m
//
// 
//
//



#import "UtilitiesHelper.h"
#import "Services.h"
#import "ConstantsShareOne.h"
//#import "BlockAlertView.h"
#import "AppDelegate.h"
#import<CoreGraphics/CoreGraphics.h>
#import <CoreLocation/CoreLocation.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import "User.h"
#import "ShareOneUtility.h"


#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>

#import <sys/utsname.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
//#define IOS_VPN       @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"


@implementation UtilitiesHelper
{
    dispatch_source_t _timer;

    
}


dispatch_source_t CreateDispatchTimer(double interval, dispatch_queue_t queue, dispatch_block_t block)
{
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    if (timer)
    {
        dispatch_source_set_timer(timer, dispatch_time(DISPATCH_TIME_NOW, interval * NSEC_PER_SEC), interval * NSEC_PER_SEC, (1ull * NSEC_PER_SEC) / 10);
        dispatch_source_set_event_handler(timer, block);
        dispatch_resume(timer);
    }
    return timer;
}
+ (id)shareUtitlities
{
    static dispatch_once_t once;
    static UtilitiesHelper *shareUtilities;
    dispatch_once(&once, ^ { shareUtilities = [[self alloc] init];  });
    return shareUtilities;
}

+ (id)getUserDefaultForKey:(NSString*)key
{
    
    return [[NSUserDefaults standardUserDefaults] valueForKey:key];
    
}


+ (void)setUserDefaultForKey:(NSString*)key  value:(NSString*)value
{
   NSUserDefaults *usrDef =    [NSUserDefaults standardUserDefaults];
   [usrDef setObject:value forKey:key];
   [usrDef synchronize];
}


+ (id)returnUserDefaultForKey:(NSString*)key
{
    
    return [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
}


+(void)showLoader:(NSString *)title forView:(UIView *)view  setMode:(MBProgressHUDMode)mode delegate:(id)vwDelegate
{
    
    AppDelegate *objDele = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    
    
  __block  MBProgressHUD *progressHUD;
    dispatch_async(dispatch_get_main_queue(), ^{

        progressHUD = [MBProgressHUD showHUDAddedTo:[[objDele.window subviews] lastObject] animated:YES];    });

    
    [progressHUD setMode:mode];
//    [progressHUD setDimBackground:YES];
//    [progressHUD setLabelText:title];
    [progressHUD setMinShowTime:1.0];
    

}

+(void)hideLoader:(UIView *)forView
{
    /*
    AppDelegate *objDele = (AppDelegate *)[[UIApplication sharedApplication]delegate];

    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideAllHUDsForView:[[objDele.window subviews] lastObject] animated:YES];
    });
     */

}


+(NSString *) addSuffixToNumber:(NSInteger) number
{
    NSString *suffix;
    int ones = number % 10;
    int temp = floor(number/10.0);
    int tens = temp%10;
    
    if (tens ==1) {
        suffix = @"th";
    } else if (ones ==1){
        suffix = @"st";
    } else if (ones ==2){
        suffix = @"nd";
    } else if (ones ==3){
        suffix = @"rd";
    } else {
        suffix = @"th";
    }
    
    NSString *completeAsString = [NSString stringWithFormat:@"%ld%@",(long)number,suffix];
    return completeAsString;
}




//^\+?\d+(-\d+)*$

+(BOOL) checkForEmptySpaces : (UITextField *)textField  {
 

    
    NSString *rawString = textField.text;
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
    if ([trimmed length] == 0) {
//        textField.text = textField.placeholder;
//        textField.textColor = [UIColor redColor];
        // Text was empty or only whitespace.
    
        textField.text = @"";
        return NO;
    }
    
    return YES;
    
}

+(BOOL) checkForEmptySpacesInString : (NSString *)rawString  {
    
    
       NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
    if ([trimmed length] == 0) {
        return NO;
    }
    return YES;
    
}
+(BOOL) checkForEmptySpacesInTextView : (UITextView *)textView  {
    
    
    NSString *rawString = textView.text;
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
    if ([trimmed length] == 0) {
        // Text was empty or only whitespace.
        
        textView.text = @"";
        return NO;
    }
    
    return YES;
    
}




+(void)showPromptAlertforTitle:(NSString *)title withMessage:(NSString *)message forDelegate:(id)deleg
{
    

//    BlockAlertView  *alertBlock = [[BlockAlertView alloc]initWithTitle:title message:message];
//    [alertBlock setCancelButtonWithTitle:@"Ok" block:^{
//        
//    }];
//    [alertBlock show];
    
    
}

+(BOOL) validateUsername:(NSString*)checkUsername {
    
    NSString *regex = @"^[a-z0-9_-]{5,15}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [predicate evaluateWithObject:checkUsername];
    
}


+(BOOL)validateURL:(NSString *)checkURL
{
    NSString *urlRegEx =
    @"(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+";
    NSPredicate *urlPredic = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", urlRegEx];
    return [urlPredic evaluateWithObject:checkURL];
}

+(BOOL) validateEmail:(NSString *)checkEmail
{
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkEmail];
}

+(BOOL) validateFullName:(NSString *)checkFullName
{
    NSString *regex = @"[a-zA-Z]{2,}+(\\s{1}[a-zA-Z]{2,}+)+";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:checkFullName];
}
+(BOOL) checkAlphabets:(NSString *)text
{
    NSString *regex = @"[a-zA-Z][a-zA-Z ]+";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:text];
}
+(BOOL) checkFaxNumber:(NSString *)text
{
    NSString *regex = @"^[0-9\\-\\+]{6,12}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:text];
}

///[\+? *[1-9]+]?[0-9 ]+/

+(BOOL) checkPhoneNumber:(NSString *)text
{
    NSString *regex = @"^[0-9\\-\\+]{9,15}$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:text];
}
+(BOOL) checkPassword:(NSString *)text
{
    NSString *regex = @"^\\w*(?=\\w*\\d)(?=\\w*[a-z])(?=\\w*[A-Z])\\w*$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:text];
}

+(NSURL *)imageURLMaker :(NSString *)imgUrl
{
    
  return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",[ShareOneUtility getBaseUrl],imgUrl]];
    
}


+(void)showLMAlertforTitle:(NSString *)title withMessage:(NSString *)message forDelegate:(id)deleg {
    
//    LMAlertView *alertView = [[LMAlertView alloc] initWithTitle:title
//                                                        message:message
//                                                       delegate:deleg
//                                              cancelButtonTitle:@"Ok"
//                                              otherButtonTitles:nil];
//    [alertView show];
    
}



+ (id)loadNibNamed:(NSString *)nibName ofClass:(Class)objClass {
    if (nibName && objClass) {
        NSArray *objects = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
        
        for (id currentObject in objects ){
            if ([currentObject isKindOfClass:objClass])
                return currentObject;
        }
    }
    
    return nil;
}

+(void)writeJsonToFile:(id)responseString withFileName:(NSString*)fileName
{
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, fileName];
    NSLog(@"filePath %@", filePath);

    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) { // if file is not exist, create it.
         NSError *error;
        [responseString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        
    }
    else
    {
        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath: filePath error: &error];

        [responseString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    }
    
}
+(id)readJsonFromFile:(NSString*)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:fileName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:myPathDocs])
    {
//        NSString *myPathInfo = [[NSBundle mainBundle] pathForResource:@"myfile" ofType:@"txt"];
//        NSFileManager *fileManager = [NSFileManager defaultManager];
//        [fileManager copyItemAtPath:myPathInfo toPath:myPathDocs error:NULL];
        return NULL;
    }
    
    //Load from File
    NSString *myString = [[NSString alloc] initWithContentsOfFile:myPathDocs encoding:NSUTF8StringEncoding error:NULL];
    NSLog(@"string ===> %@",myString);
    return myString;
}


+(void)showAlert:(NSString*)message {
    
    //[UtilitiesHelper showLMAlertforTitle:@"Message" withMessage:message forDelegate:nil];


    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Message" message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    
    [alertView show];
    
    
}

+(void)createLayerWithRoundRect:(UIView*)view{
    CALayer * l = [view layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:view.frame.size.width/2.0];
    [l setBorderWidth:3.0];
    [l setBorderColor:[[UIColor whiteColor] CGColor]];
}


+(NSString *) getStringFromObject:(NSObject *) object
{
    if ([object isKindOfClass:[NSNull class]] || object==nil) {
        return @"NA";
    }
    return (NSString *)object;
}

+(NSString *) getEmptyStringFromObjectIfNull:(NSObject *) object
{
    if ([object isKindOfClass:[NSNull class]] || object==nil) {
        return @"";
    }
    return (NSString *)object;
}

+(void)createLayerWithRoundRect:(UIView*)view radius:(float)radius{
    CALayer * l = [view layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:radius];
    [l setBorderWidth:3.0];
    [l setBorderColor:[[UIColor clearColor] CGColor]];
}

+ (NSDate *) getUTCDateFromString:(NSString *)dateString {
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormat setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    
    NSDate *date = [dateFormat dateFromString:dateString];
    dateFormat = nil;
    
    return date;
}


//+ (NSDate *) getDateFromString:(NSString *)dateString {
//
//    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//
//    NSDate *date = [dateFormat dateFromString:dateString];
//    dateFormat = nil;
//
//    return date;
//}
/*
+ (NSString *) getDateFromSQLDate:(NSString *)datePlusTime{
    
    NSDateFormatter *formatter;
    NSString        *dateString;
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:DATE_TIME_FORMAT_FOR_DISPLAY];
    
    dateString = [formatter stringFromDate:[self getDateFromString:datePlusTime]];
    
    formatter = nil;
    return dateString;
//    NSString *localDateTimeInStringFormat = [self getLocalDateFromUTCDate:dateString];
//    return localDateTimeInStringFormat;
}

+ (NSString *) getLocalDateFromUTCDate :(NSString *)gmtDateStr {
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:DATE_TIME_FORMAT_FOR_DISPLAY];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [formatter setTimeZone:gmt];
    
    NSDate *localDate = [formatter dateFromString:gmtDateStr]; // get the date
    NSTimeInterval timeZoneOffset = [[NSTimeZone systemTimeZone] secondsFromGMT]; // You could also use the systemTimeZone method
    
    NSTimeInterval gmtTimeInterval = [localDate timeIntervalSinceReferenceDate] + timeZoneOffset;
    NSDate *gmtCurrentDate = [NSDate dateWithTimeIntervalSinceReferenceDate:gmtTimeInterval];
    return [formatter stringFromDate:gmtCurrentDate];
}
 */


+ (NSString *) getDateFromSQLDate:(NSString *)datePlusTime{
    
    NSDateFormatter *formatter;
    NSString        *dateString;
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:DATE_TIME_FORMAT_FOR_DISPLAY];
    
    dateString = [formatter stringFromDate:[self getDateFromString:datePlusTime]];
    
    formatter = nil;
    
    NSString *localDateTimeInStringFormat = [self getLocalDateFromUTCDate:dateString];
    return localDateTimeInStringFormat;
}

+ (NSString *) getLocalDateFromUTCDate :(NSString *)gmtDateStr {
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:DATE_TIME_FORMAT_FOR_DISPLAY];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [formatter setTimeZone:gmt];
    
    NSDate *localDate = [formatter dateFromString:gmtDateStr]; // get the date
    NSTimeInterval timeZoneOffset = [[NSTimeZone systemTimeZone] secondsFromGMT]; // You could also use the systemTimeZone method
    
    NSTimeInterval gmtTimeInterval = [localDate timeIntervalSinceReferenceDate] + timeZoneOffset;
    NSDate *gmtCurrentDate = [NSDate dateWithTimeIntervalSinceReferenceDate:gmtTimeInterval];
    return [formatter stringFromDate:gmtCurrentDate];
}

//
//+ (NSString *) getTimeFromSQLDate:(NSString *)datePlusTime{
//
//    NSDateFormatter *formatter;
//    NSString        *dateString;
//
//    formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"h:mm a"];
//
//    dateString = [formatter stringFromDate:[self getDateFromString:datePlusTime]];
//
//    formatter = nil;
//
//    return dateString;
//}

+ (NSString *) getCurrentDateTimeAsString {
    
    NSDateFormatter *formatter;
    NSString        *dateString;
    
    NSDate *now = [[NSDate alloc] init];
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:DATE_TIME_FORMAT_FOR_SQL];
    dateString = [formatter stringFromDate:now];
    
    formatter = nil;
    
    return dateString;
}
+ (NSString *) getCurrentDateTimeAsStringWithFormat:(NSString*)dateFormat {
    
    NSDateFormatter *formatter;
    NSString        *dateString;
    
    NSDate *now = [[NSDate alloc] init];
    
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:dateFormat];
    dateString = [formatter stringFromDate:now];
    
    formatter = nil;
    return dateString;
}

/*
+ (NSString *) getTimeFromSQLDate:(NSString *)datePlusTime{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"h:mm a"];
    formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:[NSTimeZone localTimeZone].secondsFromGMT];
    NSString* strDate = [formatter stringFromDate:[self getDateFromString:datePlusTime]];
    
    return strDate;
}


+ (NSDate *) getDateFromString:(NSString *)dateString {
    
    NSDateFormatter *currentFormat = [[NSDateFormatter alloc] init];
    [currentFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    currentFormat.timeZone = [NSTimeZone defaultTimeZone];
    NSDate* date = [currentFormat dateFromString:dateString];
    
    return date;
}
*/
+ (NSString *) getTimeFromSQLDate:(NSString *)datePlusTime{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"h:mm a"];
    formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:[NSTimeZone localTimeZone].secondsFromGMT];
    NSString* strDate = [formatter stringFromDate:[self getDateFromString:datePlusTime]];
    
    return strDate;
}


+ (NSDate *) getDateFromString:(NSString *)dateString {
    
    NSDateFormatter *currentFormat = [[NSDateFormatter alloc] init];
    [currentFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    currentFormat.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDate* date = [currentFormat dateFromString:dateString];
    
    return date;
}


+(NSString *) getDurationFromTime:(NSString *) source
{
    /*
    NSDate *sourceDate;
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *foramtter = [[NSDateFormatter alloc] init];
    [foramtter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [foramtter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    //    [foramtter setFormatterBehavior:NSDateFormatterBehavior10_4];
    //    [foramtter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];
    //[foramtter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    sourceDate = [foramtter dateFromString:source];
    
    NSCalendar * gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit | NSDayCalendarUnit| NSHourCalendarUnit| NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents* dateComponentsNow = [gregorian components:unitFlags fromDate:sourceDate toDate:currentDate options:0];
    
    int day     = (int)dateComponentsNow.day;
    int weeks   = (int)dateComponentsNow.week;
    int hours   = (int)dateComponentsNow.hour;
    int minutes = (int)dateComponentsNow.minute;
    int second  = (int)dateComponentsNow.second;
    int month   = (int)dateComponentsNow.month;
    int year    = (int)dateComponentsNow.year;
    NSString *timeString = @"0 second ago";
    if (year > 0)
    {
        timeString = [self timeStringByCheck:year timeString:@"Year"];
    }
    else if(month > 0)
    {
        timeString = [self timeStringByCheck:month timeString:@"Month"];
    }
    else if(weeks > 0)
    {
        timeString = [self timeStringByCheck:weeks timeString:@"Week"];
    }
    else if(day > 0)
    {
        timeString = [self timeStringByCheck:day timeString:@"Day"];
    }
    else if(hours > 0)
    {
        timeString = [self timeStringByCheck:hours timeString:@"Hour"];
    }
    else if(minutes > 0)
    {
        timeString = [self timeStringByCheck:minutes timeString:@"Minute"];
    }
    else if(second > 0)
    {
        timeString = [self timeStringByCheck:second timeString:@"Second"];
    }
    foramtter = nil;
    gregorian = nil;
    return [timeString lowercaseString];
     */
    return @"";
     
}

+(NSString *) timeStringByCheck:(int)time timeString:(NSString *)timeName
{
    NSString *s = nil;
    if (time > 1)
    {
        s = @"s";
    }
    else
    {
        s = @"";
    }
    NSString *timeString = [NSString stringWithFormat:@"%d %@%@ ago", time, timeName, s];
    return timeString;
}

+(NSString *)getDateFromString:(NSString *)string withDateFormat:(NSString*)format withFormat:(NSString*)formatString
{
    
    NSString * dateString = [NSString stringWithFormat:@"%@",string];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:format];
    
    NSDate* myDate = [dateFormatter dateFromString:dateString];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:formatString];
    NSString *stringFromDate = [formatter stringFromDate:myDate];
    
    return stringFromDate;
}


+(NSString*)getCurrentDateInGmt{
    
    NSDateFormatter *dateFormatterGMT = [[NSDateFormatter alloc] init];
    //    :2014-05-14 01:00:00
    [dateFormatterGMT setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone *gmt = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];
    [dateFormatterGMT setTimeZone:gmt];
    NSString *timeStamp = [dateFormatterGMT stringFromDate:[NSDate date]];
    
    return timeStamp;

}


+(NSString *) jsonFragmentOfArray:(NSArray *)array
{
    //    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:nil];
    //    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    //   //NSLog(@"jsonData as string:\n%@", jsonString);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:nil];
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    //NSLog(@"jsonData as string:\n%@", jsonString);
    
    return jsonString;
}

+(NSString *) stringByStrippingHTML:(NSString*) htmlString {
    NSRange r;
    while ((r = [htmlString rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
        htmlString = [htmlString stringByReplacingCharactersInRange:r withString:@""];
    return htmlString;
}

-(void)showAlertWithMessage:(NSString*)message title:(NSString*)title delegate:(id)delegate{
  
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   [alertController dismissViewControllerAnimated:YES completion:nil];
                               }];
    
    [alertController addAction:okAction];
        
    [delegate presentViewController:alertController animated:YES completion:nil];

}

-(void)showAlertWithMessage:(NSString*)message title:(NSString*)title delegate:(id)delegate completion:(void (^)(bool completed))block{
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   [alertController dismissViewControllerAnimated:YES completion:^{
                                       
                                 
                                   }];
                                   block(YES);

                               }];
    
    [alertController addAction:okAction];
    
    [delegate presentViewController:alertController animated:YES completion:nil];
    
}

-(void)showOptionWithMessage:(NSString*)message title:(NSString*)title delegate:(id)delegate completion:(void (^)(bool completed))block{
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:title
                                          message:message
                                          preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   [alertController dismissViewControllerAnimated:YES completion:^{
                                       
                                       
                                   }];
                                   block(YES);
                                   
                               }];
    
    [alertController addAction:okAction];
    
    UIAlertAction *cancelAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                               style:UIAlertActionStyleCancel
                               handler:^(UIAlertAction *action)
                               {
                                   [alertController dismissViewControllerAnimated:YES completion:^{
                                       
                                       
                                   }];
                                   block(NO);
                                   
                               }];
    
    [alertController addAction:cancelAction];
    
    [delegate presentViewController:alertController animated:YES completion:nil];
    
}


-(void)showToastWithMessage:(NSString*)message title:(NSString*)title delegate:(id)delegate{
    
    UIAlertController* alert=[UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:@"OK"
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action){
                                   [alert dismissViewControllerAnimated:YES completion:^{
                                   }];
                               }];
    
    [alert addAction:okAction];

    [delegate presentViewController:alert animated:YES completion:nil];
    
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(3*NSEC_PER_SEC) ), dispatch_get_main_queue(), ^{
//        [alert dismissViewControllerAnimated:YES completion:^{
//        }];
//    });
}

-(void)showToastWithMessage:(NSString*)message title:(NSString*)title delegate:(id)delegate completion:(void (^)(bool completed))block{
    
    UIAlertController* alert=[UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [delegate presentViewController:alert animated:YES completion:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(3*NSEC_PER_SEC) ), dispatch_get_main_queue(), ^{
        [alert dismissViewControllerAnimated:YES completion:^{
            block(YES);
        }];
    });
}

//+(void)addActivityIndicatorToView:(UIView*)view{
//    UIActivityIndicatorView* indicator=[[UIActivityIndicatorView alloc]init];
//    [indicator setTag:1000];
//    [indicator setCenter:CGPointMake(view.frame.size.width/2, view.frame.size.height/2)];
//    [indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
//    [indicator startAnimating];
//    [view addSubview:indicator];
//
//}
//+(void)removeActivityIndicatorToView:(UIView*)view{
//    @try {
//        for(UIView* view in view.subviews){
//            if([view isKindOfClass:[UIActivityIndicatorView class]]){
//                if(view.tag==1000){
//                    UIActivityIndicatorView* indicator=(UIActivityIndicatorView*)view;
//                    [indicator stopAnimating];
//                    [indicator removeFromSuperview];
//                }
//            }
//        }
//    }
//    @catch (NSException *exception) {
//        NSLog(@"EXCEPTION: %@",exception.description);
//    }
//    @finally {
//        NSLog(@"finally block called");
//
//    }
// 
//
//}


+(void)addActivityIndicatorToView:(UIView*)view{
    __weak __typeof(UIView*)weakView=view;
    BOOL isHavingIndicatorView=NO;
    
        for(UIView* tmpView in [weakView subviews]){
            if([tmpView isKindOfClass:[UIActivityIndicatorView class]]){
                isHavingIndicatorView=YES;
                UIActivityIndicatorView* indicator=(UIActivityIndicatorView*)tmpView;
                [indicator setCenter:CGPointMake(weakView.frame.size.width/2, weakView.frame.size.height/2)];
                [indicator startAnimating];
                [weakView bringSubviewToFront:indicator];
            }
        }
        if(!isHavingIndicatorView){
            UIActivityIndicatorView* indicator=[[UIActivityIndicatorView alloc]init];
            [indicator setCenter:CGPointMake(weakView.frame.size.width/2, weakView.frame.size.height/2)];
            [indicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
            [indicator startAnimating];
            [weakView addSubview:indicator];
            [weakView bringSubviewToFront:indicator];
        }
    

    
}
+(void)removeActivityIndicatorToView:(UIView*)view{
   __block UIActivityIndicatorView* indicator;
    __weak __typeof(UIView*)weakView=view;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        @try {
            if([weakView subviews].count>0){
                for(UIView* tmpView in [weakView subviews]){
                    if([tmpView isKindOfClass:[UIActivityIndicatorView class]])
                        indicator=(UIActivityIndicatorView*)tmpView;
                }
            }
            
            
        }
        @catch (NSException *exception) {
            NSLog(@"EXCEPTION: %@",exception.description);
        }
        @finally {
            if (indicator) {
                dispatch_async(dispatch_get_main_queue(), ^{ // 2
                    [indicator stopAnimating];
                    [indicator removeFromSuperview];
                });
                
            }
        }

    });
    
    
}

+(NSString*)getDeviceIdentifier{
    
    NSString* deviceIdentifier;
    
    NSUUID *deviceId;
    
#if TARGET_IPHONE_SIMULATOR
    deviceId = [[NSUUID alloc] initWithUUIDString:@"0000"];
#else
    deviceId = [UIDevice currentDevice].identifierForVendor;
#endif
    
    deviceIdentifier = deviceId.UUIDString;
    
    return deviceIdentifier;
}

+(BOOL)isGpsOn{
    BOOL isGpsOn=NO;
    
    if([CLLocationManager locationServicesEnabled] &&
       [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
        isGpsOn=YES;
    } else {
        isGpsOn=NO;
    }
    
    return isGpsOn;
}

-(void)showLAContextWithDelegate:(id)delegate completionBlock:(void(^)(BOOL success))block{
 
    LAContext *myContext = [[LAContext alloc] init];
    NSError *authError = nil;
    NSString *myLocalizedReasonString = @"Logging in with Touch ID";
    
    if ([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
        [myContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                  localizedReason:myLocalizedReasonString
                            reply:^(BOOL success, NSError *error) {
                                if (success) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        block(success);
                                    });
                                } else {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        
//                                        [[UtilitiesHelper shareUtitlities] showToastWithMessage:error.localizedDescription title:@"Error" delegate:delegate];
                                        NSLog(@"Switch to fall back authentication - ie, display a keypad or password entry box");

                                        block(success);

                                    });
                                }
                            }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UtilitiesHelper showTouchIDError:authError :delegate];
            block(FALSE);

        });
    }

}

+(void)isTouchIDAvailableWithDelegate:(id)delegate completionBlock:(void(^)(BOOL success))block{
    
    __block BOOL flag= TRUE;
    LAContext *myContext = [[LAContext alloc] init];
    NSError *authError = nil;
    
    if (![myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]){
        dispatch_async(dispatch_get_main_queue(), ^{
            flag = FALSE;
            [UtilitiesHelper showTouchIDError:authError :delegate];
            block(FALSE);
        });
    }
    else{
        block(TRUE);
    }
}

+(void)showTouchIDError:(NSError*)authError : (id)delegate {
    
    NSString *errorMessage = authError.localizedDescription;
    
    switch ([authError code]) {
        case -1:{
            NSLog(@"authenticationFailed");
        }
            break;
            
        case -2:{
            NSLog(@"userCancel");
        }
            break;
            
        case -3:{
            NSLog(@"userFallback");
        }
            break;
            
        case -4:{
            NSLog(@"systemCancel");
        }
            break;
            
        case -5:{
            NSLog(@"passcodeNotSet");
        }
            break;
            
        case -6:{
            NSLog(@"touchIDNotAvailable");
        }
            break;
            
        case -7:{
            NSLog(@"touchIDNotEnrolled");
        }
            break;
            
        case -8:{
            NSLog(@"touchIDLockout");
            errorMessage = @"Touch ID is locked out.  Please lock your device and re-enter your security code to unlock";
        }
            break;
            
        case -9:{
            NSLog(@"appCancel");
        }
            break;
            
        case -10:{
            NSLog(@"invalidContext");
        }
            break;
            /*default:
             errorMessage = authError.localizedDescription;
             break;*/
    }
    [[UtilitiesHelper shareUtitlities] showToastWithMessage:errorMessage title:@"Error" delegate:delegate];
    
}

+(void)shouldHideTouchID:(id)delegate completionBlock:(void(^)(BOOL success))block{
    
    __block BOOL flag= FALSE;
    LAContext *myContext = [[LAContext alloc] init];
    NSError *authError = nil;
    
    if (![myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]){
        dispatch_async(dispatch_get_main_queue(), ^{
            
            flag = FALSE;
            switch ([authError code]) {
                    
                case -6:{
                    flag = TRUE;
                    NSLog(@"touchIDNotAvailable");
                }
                    break;
                    
                default:
                    break;
            }
            
            block(flag);
        });
    }
    else{
        block(flag);
    }

}
- (void)startTimerWithCompletionBlock:(void(^)(BOOL  sucess))block
{
    if(!_timer){
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        double secondsToFire = 300.000f; //300.000f
        
        _timer = CreateDispatchTimer(secondsToFire, queue, ^{
            NSLog(@"keepAlive");
            
            [User keepAlive:nil delegate:nil completionBlock:^(BOOL sucess) {
                
                if(!sucess){
                    block(YES);
                }
                
            } failureBlock:^(NSError *error) {
                
            }];
        });
    }
}

- (void)cancelTimer
{
    if (_timer) {
        dispatch_source_cancel(_timer);
        // Remove this if you are on a Deployment Target of iOS6 or OSX 10.8 and above
        _timer = nil;
    }
}


// Get IP Address
+ (NSString *)GetOurIpAddress {
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

+ (NSString *)deviceModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString: systemInfo.machine encoding: NSUTF8StringEncoding];
}

@end

