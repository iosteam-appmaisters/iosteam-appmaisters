//
//  Services.h
//  THISWAY
//
//  Created by Sabika Batool on 2/4/16.
//  Copyright © 2016 Sabika Batool. All rights reserved.
//

#ifndef THISWAY_Services_h
#define THISWAY_Services_h


#define BASE_URL_CONFIGURATION   @"https://nsauth-extdev.ns3web.com/core"

#define BASE_URL_NSCONFIG @"https://nsconfig-extdev.ns3web.com"

#define NSCONFIG_GET_MODIFIEDSERVICES(CAID,VERSION_NUMBER) [NSString stringWithFormat:@"%@/api/ClientApplication/%@/ModifiedServices/%@",BASE_URL_NSCONFIG,CAID,VERSION_NUMBER]

#define BASE_URL_CONFIGURATION_NS_CONGIG_WITH_CLIENT_ID_AND_SERVICE_NAME(CONTROLLER,ID,SERVICE_NAME) [NSString stringWithFormat:@"%@/api/%@/%@/%@",BASE_URL_NSCONFIG,CONTROLLER,ID,SERVICE_NAME]

#define ACCESS_TOKEN           @"connect/token"

#define Grant_Type_Value       @"client_credentials"
#define Scope_value            @"content_file.read content_text_group.read content_text.read style_value.read client_setting.read menu_item.read nsapi_setting.read modified_service.read client_application.read"
#define Client_ID_value        @"nsmobile_nsconfig_read_client"
#define Client_Secret_value    @"202E8187-94DE-4CDA-8908-7A9436B21292"

#define CONFIG_MENU_ITEMS_SERVICE          @"MenuItems"
#define CONFIG_CLIENT_SETTINGS_SERVICE     @"ClientSettings"
#define CONFIG_STYLE_VALUES_SERVICE        @"StyleValues"
#define CONFIG_API_SETTINGS_SERVICE        @"NSAPISettings"
#define CLIENT_APP_CONTROLLER              @"ClientApplications"
#define CUSTOMER_CONTROLLER                @"Customers"
#define CONFIG_CLIENT_APP                  @"ClientApplications"



#define KWEB_SERVICE_LOGIN                              @"eft/memberLogin"

#define KWEB_SERVICE_MEMBER_VALIDATE                    @"eft/memberValidate"

#define KWEB_SERVICE_SIGN_OUT                           @"eft/memberLogout"

#define KWEB_SERVICE_MEMBER_ACCOUNT_NAME                @"eft/memberAccountName"

#define KWEB_SERVICE_KEEP_ALIVE                         @"eft/keepalive"

#define KWEB_SERVICE_PIN_RESET                          @"eft/memberPinReset"

#define KMEMBER_DEVICES                                 @"eft/memberDevices"

#define KQUICK_BALANCES                                 @"eft/quickBalances"

#define KQUICK_TRANSACTIONS                             @"eft/quickTransactions"

#define KSUFFIX_INFO                                    @"eft/suffixInfo"

#define kSUFFIZ_PREPHERENCES                            @"eft/suffixPreferences"

#define kKEEP_ALIVE                                     @"eft/keepalive"

#define KQUICK_TRANSACTION                              @"eft/quickTransactions"

#define KPIN_RESET                                      @"eft/memberPINReset"

#define KACCOUNT_NAME                                   @"eft/memberAccountName"

#define KSET_ACCOUNT_NAME                               @"eft/memberPreferences"

#define KBRANCH_LOCATIONS                               @"organization/branches"


#define kPASSWORD_EXPIRE_URL                            @"Credential/Rescue"

#define URL_JOIN_CREDIT_UNION                           @"https://nsmobiledemo.ns3web.com/NSJoin.html?id=48b9462bd306475fa32ddc28dd603faab9"
#define JOIN_CREDIT_UNION_TITLE                         @"Join Credit Union"
#define URL_APPLY_FOR_LOAN                              @"https://nsmobiledemo.ns3web.com/NSLoan.html?id=48b9462bd306475fa32ddc28dd603faab9"
#define APPLY_FOR_LOAN_TITLE                            @"Apply For A Loan"
#define URL_BRANCH_LOCATION                             @"https://nsmobiledemo.ns3web.com/BranchLocations.html?id=48b9462bd306475fa32ddc28dd603faab9"
#define BRANCH_LOCATION_TITLE                           @"Branch Location"
#define URL_CONTACT_US                                  @"https://nsmobiledemo.ns3web.com/ContactUs.html?id=48b9462bd306475fa32ddc28dd603faab9"
#define CONTACT_TITLE                                   @"Contact"
#define URL_PRIVACY_POLICY                              @"https://nsmobiledemo.ns3web.com/PrivacyPolicy.html?id=48b9462bd306475fa32ddc28dd603faab9"
#define PRIVACY_POLICY_TITLE                            @"Privacy Policy"


//#define KSINGLE_SIGN_ON                                 @"api/SSO/SignOn"

#define KSINGLE_SIGN_ON                                 @"SSO/SignOn"

#define kNO_OF_TRANSACTION                              @"5"


#define kVERTIFY_MONEY_REGISTER                         @"rdc/sso/mobdep_regquery.ashx"
//#define kVERTIFY_MONEY_REGISTER_TEST                    @"https://test.vertifi.com/rdc/sso/mobdep_regquery.ashx"


#define kVERTIFI_ACCEPTANCE                             @"rdc/sso/mobdep_regaccept.ashx"
//#define kVERTIFI_ACCEPTANCE_TEST                        @"https://test.vertifi.com/rdc/sso/mobdep_regaccept.ashx"


#define kVERTIFI_DEP_ININT                              @"rdc/sso/mobdep_init.ashx"
//#define kVERTIFI_DEP_ININT_TEST                         @"https://test.vertifi.com/rdc/sso/mobdep_init.ashx"


#define kVERTIFI_COMMIT                                 @"rdc/sso/mobdep_commit.ashx"
//#define kVERTIFI_COMMIT_TEST                            @"https://test.vertifi.com/rdc/sso/mobdep_commit.ashx"

#define kVERTIFI_DEP_LIST                               @"rdc/sso/mobdep_reviewquery.ashx"
//#define kVERTIFI_DEP_LIST_TEST                          @"https://test.vertifi.com/rdc/sso/mobdep_reviewquery.ashx"

#define KVERTIFY_DEP_DETAILS                            @"rdc/sso/mobdep_reviewreport.ashx"
//#define KVERTIFY_DEP_DETAILS_TEST                       @"https://test.vertifi.com/rdc/sso/mobdep_reviewreport.ashx"


//#define kVERTIFY_ALL_DEP_LIST                           @"https://www.member-data.com/rdc/sso/mobdep_historyaudit.ashx"
//#define kVERTIFY_ALL_DEP_LIST_TEST                      @"https://test.vertifi.com/rdc/sso/mobdep_historyaudit.ashx"

#define kVERTIFY_ALL_DEP_LIST                           @"rdc/sso/mobdep_reviewquery.ashx"
//#define kVERTIFY_ALL_DEP_LIST_TEST                      @"https://test.vertifi.com/rdc/sso/mobdep_reviewquery.ashx"


#define kVERTIFI_DELETE_DEPOSIT                         @"rdc/sso/mobdep_reviewdelete.ashx"
//#define kVERTIFI_DELETE_DEPOSIT_TEST                    @"https://test.vertifi.com/rdc/sso/mobdep_reviewdelete.ashx"


//#define VERTIFI_MODE_TEST                               @"test"
//#define VERTIFI_MODE                                    @"prod"


#define CAR_MISMATCH_PASSED                             @"Passed"
#define CAR_MISMATCH_FAILED                             @"Failed"
#define CAR_MISMATCH_NOT_TESTED                         @"Not Tested"


#define kLOCATION_API                                   @"http://api.co-opfs.org/locator/proximitySearch"

// ShareOne
//#define kLOCATION_API_KEY                               @"4LobSNzzwp4DKnp"

// c2c
//#define kLOCATION_API_KEY                               @"kDfLB3iqJzz7pBy"




//#define kLOCATION_API_KEY                               @"7vrmEHdjhlSnMOX"





#define RequestType_PUT                                 @"PUT"
#define RequestType_POST                                @"POST"
#define RequestType_GET                                 @"GET"
#define RequestType_DELETE                              @"DELETE"


#define REQ_URL                                         @"REQ_URL"
#define REQ_TYPE                                        @"REQ_TYPE"
#define REQ_HEADER                                      @"REQ_HEADER"
#define REQ_PARAM                                       @"REQ_PARAM"
#define REQ_HEADER_CONFIGURATION                        @"REQ_HEADER_CONFIGURATION"
#define ETAG_HEADER                                     @"ETAG_HEADER"


#endif
