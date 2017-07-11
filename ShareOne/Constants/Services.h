//
//  Services.h
//  THISWAY
//
//  Created by Sabika Batool on 2/4/16.
//  Copyright © 2016 Sabika Batool. All rights reserved.
//

#ifndef THISWAY_Services_h
#define THISWAY_Services_h

//#define KWEB_SERVICE_BASE_URL                           @"https://nsmobile.ns3web.com"

//#define KWEB_SERVICE_BASE_URL                           @"https://coast2coast.ns3web.com"
//
//#define KWEB_SERVICE_BASE_URL                           @"https://preprod.ns3web.com/Coast2Coast_5a6a434123b1409293e4da1a8dac4cb9/NSHome"


//#define KWEB_SERVICE_BASE_URL                           @"https://coast2coastpp.ns3web.com"



//ShareOne
//#define PUBLIC_KEY                  @"bea351786c074347a0528acf729d0b8f"
//#define PRIVATE_KEY                 @"3b185aa994d2408091714536c28e324b"

//C2C
//#define PUBLIC_KEY                  @"b5000c29263d4f0fa3b8115de4694f8e"
//#define PRIVATE_KEY                 @"1597c0dbf23647e49c6e658be7d293c9"


//#define KWEB_SERVICE_BASE_URL_SSO                       @"https://nsmobilecp.ns3web.com"
//#define KWEB_SERVICE_BASE_URL_SSO                       @"https://preprod.ns3web.com/Coast2Coast_5a6a434123b1409293e4da1a8dac4cb9/NSHome"



#define BASE_URL_CONFIGURATION_NS_CONGIG_WITH_CLIENT_ID_AND_SERVICE_NAME(ID,SERVICE_NAME) [NSString stringWithFormat:@"https://nsconfig-extdev.ns3web.com/api/ClientApplications/%@/%@",ID,SERVICE_NAME]


#define CONFIG_MENU_ITEMS_SERVICE          @"MenuItems"
#define CONFIG_CLIENT_SETTINGS_SERVICE     @"ClientSettings"
#define CONFIG_STYLE_VALUES_SERVICE        @"StyleValues"
#define CONFIG_API_SETTINGS_SERVICE        @"NSAPISettings"


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


#define kVERTIFY_MONEY_REGISTER                         @"https://www.member-data.com/rdc/sso/mobdep_regquery.ashx"
#define kVERTIFY_MONEY_REGISTER_TEST                    @"https://test.vertifi.com/rdc/sso/mobdep_regquery.ashx"


#define kVERTIFI_ACCEPTANCE                             @"https://www.member-data.com/rdc/sso/mobdep_regaccept.ashx"
#define kVERTIFI_ACCEPTANCE_TEST                        @"https://test.vertifi.com/rdc/sso/mobdep_regaccept.ashx"


#define kVERTIFI_DEP_ININT                              @"https://www.member-data.com/rdc/sso/mobdep_init.ashx"
#define kVERTIFI_DEP_ININT_TEST                         @"https://test.vertifi.com/rdc/sso/mobdep_init.ashx"


#define kVERTIFI_COMMIT                                 @"https://www.member-data.com/rdc/sso/mobdep_commit.ashx"
#define kVERTIFI_COMMIT_TEST                            @"https://test.vertifi.com/rdc/sso/mobdep_commit.ashx"

#define kVERTIFI_DEP_LIST                               @"https://www.member-data.com/rdc/sso/mobdep_reviewquery.ashx"
#define kVERTIFI_DEP_LIST_TEST                          @"https://test.vertifi.com/rdc/sso/mobdep_reviewquery.ashx"

#define KVERTIFY_DEP_DETAILS                            @"https://www.member-data.com/rdc/sso/mobdep_reviewreport.ashx"
#define KVERTIFY_DEP_DETAILS_TEST                       @"https://test.vertifi.com/rdc/sso/mobdep_reviewreport.ashx"


//#define kVERTIFY_ALL_DEP_LIST                           @"https://www.member-data.com/rdc/sso/mobdep_historyaudit.ashx"
//#define kVERTIFY_ALL_DEP_LIST_TEST                      @"https://test.vertifi.com/rdc/sso/mobdep_historyaudit.ashx"

#define kVERTIFY_ALL_DEP_LIST                           @"https://www.member-data.com/rdc/sso/mobdep_reviewquery.ashx"
#define kVERTIFY_ALL_DEP_LIST_TEST                      @"https://test.vertifi.com/rdc/sso/mobdep_reviewquery.ashx"


#define kVERTIFI_DELETE_DEPOSIT                         @"https://www.member-data.com/rdc/sso/mobdep_reviewdelete.ashx"
#define kVERTIFI_DELETE_DEPOSIT_TEST                    @"https://test.vertifi.com/rdc/sso/mobdep_reviewdelete.ashx"


#define VERTIFI_MODE_TEST                               @"test"
#define VERTIFI_MODE                                    @"prod"


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
