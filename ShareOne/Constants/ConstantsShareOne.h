//
//  Constants.h
//  FastDeals
//
//  Created by Aliakber Hussain on 12/12/2013.
//  Copyright (c) 2013 Aliakber Hussain. All rights reserved.
//

#ifndef FastDeals_Constants_h
#define FastDeals_Constants_h

    
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)


#define APPC_IS_IPAD        (UI_USER_INTERFACE_IDIOM()== UIUserInterfaceIdiomPad) ? YES : NO

#define APPC_IS_IOS7         ([[[[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."] objectAtIndex:0] intValue] < 7) ? NO:YES
#define IS_IOS7_OR_LESS         ([[UIDevice currentDevice].systemVersion intValue] < 8) ? YES : NO

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))
#define IS_ZOOMED (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)
#define IS_IPHONE_X (IS_IPHONE && SCREEN_MAX_LENGTH == 812.0)

//#define IS_IPHONE_4 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )480 ) < DBL_EPSILON )
//#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

#define DEFAULT_COLOR_WHITE [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]
#define DEFAULT_COLOR_GRAY  [UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:235.0/255.0 alpha:1.0]
#define DEFAULT_THEME_COLOR [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0]
#define DEFAULT_RED_COLOR [UIColor colorWithRed:168.0/255.0 green:6.0/255.0 blue:0.0/255.0 alpha:1.0]


//#define VERTIFI_DEPOSIT_LIMIT(value) @"Amount exceeds the limit, Deposit limit is $ %@ Only", value

#define VERTIFI_DEPOSIT_LIMIT(value) [NSString stringWithFormat:@"Amount exceeds the limit. Deposit limit is $%@ Only.",value]
#define VERTIFI_AMOUNT_MISMATCH(carAmount,texFeildAmount) [NSString stringWithFormat:@"Amount return from Vertifi is $%.2f, mismatch to the input amount $%.2f",carAmount,texFeildAmount]


#define DATE_TIME_FORMAT_FOR_ADD_MARKER @"MMMM d, YYYY"
#define DATE_TIME_FORMAT_FOR_EMAIL      @"MMMM d, YYYY HH:mm:ss"
#define DATE_TIME_FORMAT_FOR_SQL          @"yyyy-MM-dd HH:mm:ss"
//#define DATE_TIME_FORMAT_FOR_DISPLAY      @"yyyy-MM-dd"
#define DATE_TIME_FORMAT_FOR_DISPLAY      @"MMM dd,yy"
#define REFRESH_HOME    @"RefreshHome"
#define DATE_TIME_FORMAT                @"MMM dd, YYYY HH:mm a"

#define FrameX(_frame) _frame.origin.x
#define FrameY(_frame) _frame.origin.x
#define FrameWidth(A) A.size.width
#define FrameHeight(A) A.size.height

#define Color(R,G,B,A) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]
#define startThreadInBackground dispatch_async(kBgQueue, ^{
#define endThreadInBackground });

#define startMainThread  dispatch_async(dispatch_get_main_queue(), ^{
#define endMainThread });

#define FACEBOOK_APP_ID_KEY         @"173630532983736"
#define FACEBOOK_APP_PERMISSION     @[@"email",@"user_about_me",@"user_birthday",@"user_location"]
#define FACEBOOK_APP_PERMISSION_EXTENDED     @[@"email",@"user_friends",@"read_stream",@"publish_actions"]

#define INSTAGRAM_CLIENT_ID @"7b9ddacd6fe74692808a4a8ffa3df761"
#define DEVICE_TOKEN        @"device_token"

#define kFbFriends                   @"https://graph.facebook.com/me/friends"
#define FeatureMissingAlert             @"This feature will be implemented in beta!"

#define ALERT_FIELD_EMPTY                   @"%@ field can't be left empty!"
#define ALERT_ALPHABETS_ALLOWED             @"Only alphabets are allowed!"
#define ALERT_INVALID_EMAIL                 @"Invalid email address!"
#define ALERT_INVLALID_CONTACT              @"Phone Number is not valid!"
#define ALERT_PASSWORD_MINIMUM_CHARACTERS   @"There Must be minimum %d characters!"
#define ALERT_PASSWORD_MAXIMUM_CHARACTERS   @"There Must be maximum %d characters!"
#define ALERT_PASSWORD_MISMATCH             @"Password and confirm password mismatch!"
#define ALERT_ALL_FIELDS_EMPTY              @"All fields are empty"

#define kPackagePurchased @"kPackagePurchased"

// tableView section identifiers
#define SECTION_FRONT_IMAGE         0
#define SECTION_BACK_IMAGE          1

// control tags
#define kFRONT_BUTTON_TAG            1
#define kBACK_BUTTON_TAG             2
#define kFRONT_IMAGE_VIEW_TAG        10
#define kBACK_IMAGE_VIEW_TAG         11



#define PRIVATE_KEY_SSO             @"1c4d379e533945a8a0c23525ddd85e89"

//#define H_MAC_TYPE                  @"SHA256"
//#define SECURITY_VERSION            @"1.1"
#define HOST_ADDRESS                @"nsmobile.ns3web.com"

//PLIST CONSTANT
#define PLIST_NAME                  @"SlideMenu"
#define CONFIGURATION_PLIST_NAME    @"ConfigurationSettings"

#define FILE_TYPE                   @"plist"
#define HAS_SECTIONS                @"isSection"
#define MAIN_CAT_TITLE              @"DisplayText"
#define MAIN_CAT_IMAGE              @"Name"
#define CONTROLLER_NAME             @"Name"
#define CONTROLLER_TITLE            @"detailVCTitle"
#define MAIN_CAT_SUB_CATEGORIES     @"subCategories"
#define WEB_URL                     @"LinkURL"

#define MOBILE_DEPOSIT              @"mobileDeposit"

#define HOME_WEB_VIEW_URL           @"/Account/Summary"

#define SHOULD_SHOW                 @"shouldShow"

#define SUB_CAT_TITLE               @"title"
#define SUB_CAT_IMAGE               @"icon"

#define CHANGE_PIN                  @"PINChange"
#define CHANGE_ACCOUNT_USER_NAME    @"AccountName"
#define SIGN_UP                     @"Signup"

//#define SUB_CAT_CONTROLLER          @"detailVCIdentifier"
#define SUB_CAT_CONTROLLER_TITLE    @"DisplayText"
#define IS_OPEN_NEW_TAB             @"OpenInNewTab"

#define LOG_OFF                     @"Log Off"
#define WEB_VIEWCONTROLLER_ID       @"WebViewController"
#define SESSION_KEY_LOGGED_IN       @"SessionKeyLoggedIn"
// ShareOne
//#define googleApiKey                 @"AIzaSyBtowmB1r1XTOD4CjheliFm_cuxdPgLQZE"


// Coast2Coast
//#define googleApiKey                 @"AIzaSyCZkSrAFGWnDYiSb1GTuXeQ8UcLcCRcjjY"

//






//#define ADVERTISMENT_URL (AccountNumber,Width,Height) @"https://olb2.deeptarget.com/shareone/trgtframes.ashx?Method=M&DTA=%@&Channel=Mobile&Width=%@&Height=%@", AccountNumber,Width,Height



#define PROVIDER_TYPE_VALUE            @"1"     // FOR iOS =1 ; 2= GOOGLE

#define RESTRICT_TOUCH_ID               @"RESTRICT_TOUCH_ID"
#define OVERRIDE_TOUCH_ID               @"OVERRIDE_TOUCH_ID"
#define QUICK_BAL_SETTINGS              @"QUICK_BAL_SETTINGS"
#define SHOW_OFFERS_SETTINGS            @"SHOW_OFFERS_SETTINGS"
#define TOUCH_ID_SETTINGS               @"TOUCH_ID_SETTINGS"
#define RETINA_SCAN_SETTINGS            @"RETINA_SCAN_SETTINGS"
#define PUSH_NOTIF_SETTINGS             @"PUSH_NOTIF_SETTINGS"
#define RE_SKIN_SETTINGS                @"RE_SKIN_SETTINGS"
#define USER_KEY                        @"USER_KEY"
#define VERTIFI_AGREEMANT_KEY           @"VERTIFI_AGREEMANT_KEY"
#define VERTIFI_AGREEMENT_DECLINED      @"VERTIFI_AGREEMENT_DECLINED"
#define ALL_USER_OBJECTS                @"ALL_USER_OBJECTS"
#define NOTIFICATION_SETTINGS_UPDATION  @"NOTIFICATION_SETTINGS_UPDATION"
#define TOUCH_ID_SETTINGS_UPDATION      @"TOUCH_ID_SETTINGS_UPDATION"
#define DEFAULT_QB_SETTINGS             @"DEFAULT_QB_SETTINGS"
#define USER_INTERACTED_SHOW_OFFER      @"USER_INTERACTED_SHOW_OFFER"

#define ERROR_MESSAGE                  @"The service is temporarily unavailable, please try again later."
#define RESPONSE_TIME_OUT              60.0
#define RESPONSE_TIME_OUT_WEB_VIEW     30.0

#define CURRENT_LANG @"CURRENT_LANG"
#define SHOULD_SSO @"SHOULD_SSO"
#define LOGOUT_BEGIN @"LOGOUT_BEGIN"
#define NORMAL_LOGOUT @"NORMAL_LOGOUT"
#define TECHNICAL_LOGOUT @"TECHNICAL_ERROR_LOGOUT"
#define SESSION_ACTIVE_LOGOUT @"SESSION_ACTIVE_LOGOUT"
#define TEMP_DISABLE_TOUCH_ID @"TEMP_DISABLE_TOUCH_ID"
#define ADVERTISMENT_WEBVIEW_TAG    1122334
#define AFTER_LOGIN_VERSION_NUMBER    @"GET_VERSION_AFTER_LOGIN"

#define SIDEMENU_HIDDEN @"SIDEMENU_HIDDEN"

//#define KEY_VALUE                   @"ad4c74ff05a8d4fd5ec8674121bf745c"

#define SHOW_MENU_NOTIFICATION      @"SHOW_MENU_NOTIFICATION"


//#define REQUESTER_VALUE             @"263183117-Shareone"
//#define ROUTING_VALUE               @"263183117"

#define SYSTEM_VERSION_GRATERTHAN_OR_EQUALTO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)



//#define VERTIFY_LOGIN_VALIDATION                        @"User Registration Pending Approval"
//#define VERTIFY_LOGIN_VALIDATION_MESSAGE                @"User registration pending for approval"
#define VERTIFY_CAR_MISMATCH_NOT_TESTED_MESSAGE         @"Vertfiti was unable to test the scanned check, Please re-scan."

#define VERTIFY_DEL_DEP_MESSAGE                         @"Are you sure, you want to delete ?"



#define EXPIRED_PASSWORD_MESSAGE                @"A temporary password has been emailed"

#define PASSWORD_EXPIRED_ERROR_CODE     5162

#define CO_OP_API_KEY_INVALID_ERROR_CODE     1006
#define CO_OP_API_KEY_INVALID_ERROR_MSG     @"The Co-Op API key is not valid."
#define CO_OP_NO_DATA_MSG     @"The Co-Op is not returning any locations."
#define CO_OP_GENERAL_ERROR_MSG     @"The Co-Op is not returning correct data."




#endif

