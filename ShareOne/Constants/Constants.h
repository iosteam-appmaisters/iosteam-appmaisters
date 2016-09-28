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

#define IS_IPHONE_4 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )480 ) < DBL_EPSILON )
#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

#define DEFAULT_COLOR_WHITE [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0]
#define DEFAULT_COLOR_GRAY  [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0]



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




#define PUBLIC_KEY                  @"bea351786c074347a0528acf729d0b8f"
#define PRIVATE_KEY                 @"3b185aa994d2408091714536c28e324b"
#define H_MAC_TYPE                  @"SHA256"
#define SECURITY_VERSION            @"1.1"
#define HOST_ADDRESS                @"nsmobile.ns3web.com"

//PLIST CONSTANT
#define PLIST_NAME                  @"SlideMenu"
#define FILE_TYPE                   @"plist"
#define HAS_SECTIONS                @"isSection"
#define MAIN_CAT_TITLE              @"title"
#define MAIN_CAT_IMAGE              @"icon"
#define CONTROLLER_NAME             @"detailVCIdentifier"
#define CONTROLLER_TITLE            @"detailVCTitle"
#define MAIN_CAT_SUB_CATEGORIES     @"subCategories"

#define SHOULD_SHOW                 @"shouldShow"

#define SUB_CAT_TITLE               @"title"
#define SUB_CAT_IMAGE               @"icon"
//#define SUB_CAT_CONTROLLER          @"detailVCIdentifier"
//#define SUB_CAT_CONTROLLER_TITLE    @"detailVCTitle"

#define googleApiKey               @"AIzaSyCk9jJ7SBm7NMTJNHXMxippS6LZ0MQxymw"

#endif

