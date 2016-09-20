//
//  SignInModuleConstants.h
//  UserSignInModule
//
//  Created by Aliakber Hussain on 02/11/2013.
//  Copyright (c) 2013 Aliakber Hussain. All rights reserved.
//

#ifndef UserSignInModule_SignInModuleConstants_h
#define UserSignInModule_SignInModuleConstants_h

typedef enum CellIdentifiers{
    TextFieldInputCell,
    LabelTextFieldInputCell,
    ImageLabelTextFieldInputCell,
    MultiTextFieldInputCell,
    LabelRadioCell,
    ImageLabelRadioCell,
    ValueButtonCell,
    LabelValueButtonCell,
    ImageValueButtonCell,
    RegisterButtonCell,
    UserImageInputCell,
    EmptyPlaceholderCell,
    RadioCell,
    ImageLabelSwitchCell,
}PrototypeCellIdentifiers;


typedef enum VerificationKey{
    Username=1,
    Email,
    Both,
}VerificationKey;

#define MINIMUM_PASSWORD_LENGTH 6
#define MAXIMUM_TEXT_LENGTH 18

#define SERVER_NOT_RESPONDING_ERROR                 @"Network Error Occured. Please try again!"

#define REGISTRATION_FORM_DATABASE_KEY                  @"DatabaseKey"
#define REGISTRATION_FORM_DATABASE_KEY_MULTITEXT1       @"MultiTextField1DatabaseKey"
#define REGISTRATION_FORM_DATABASE_KEY_MULTITEXT2       @"MultiTextField2DatabaseKey"

#define REGISTRATION_FIELD_TITLE                    @"Title"
#define REGISTRATION_FIELD_CELLIDENTIFIER           @"CellIdentifier"
#define REGISTRATION_FIELD_CELLIHEIGHT              @"CellHeight"
#define REGISTRATION_FIELD_CELL_BACKGROUNDIMAGE     @"CellBackgroundImage"
#define REGISTRATION_FIELD_ICON_IMAGENAME           @"IconImageName"
#define REGISTRATION_FIELD_MULTITEXTFIELD_1_TITLE   @"MultiTextField1Title"
#define REGISTRATION_FIELD_MULTITEXTFIELD_2_TITLE   @"MultiTextField2Title"
#define REGISTRATION_FIELD_OPTION1_TITLE            @"Option1Title"
#define REGISTRATION_FIELD_OPTION2_TITLE            @"Option2Title"
#define REGISTRATION_FIELD_OPTION_SELECTEDIMAGE     @"OptionSelectedImageName"
#define REGISTRATION_FIELD_OPTION_DESELECTEDIMAGE   @"OptionDeselectedImageName"

#define REGISTRATION_FIELD_PASSWORD                 @"password"
#define REGISTRATION_FIELD_CONFIRM_PASSWORD         @"confirmPassword"
#define REGISTRATION_FIELD_EMAIL                    @"email"
#define REGISTRATION_FIELD_PHONE                    @"phone"

#define DEVICE_TOKEN                                @"DeviceToken"
#define COUNTRY_NAME                                @"Country"
#define CITY_NAME                                   @"City"
#define STATE_NAME                                  @"State"
#define USER_TYPE                                   @"UserType"

#define CURRENCY                                    @"Currency"
#define Image                                    @"Image"
#define COUNTRY_NAME_TITLE                         @"CountryName"
#define CITY_NAME_TITLE                         @"CityName"
#define STATE_NAME_TITLE                         @"StateName"

#define PLACE_ID                                    @"ID"

#endif
