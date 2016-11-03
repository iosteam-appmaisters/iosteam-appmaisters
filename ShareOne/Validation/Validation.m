//
//  SignInModuleValidation.m
//  UserSignInModule
//
//  Created by Aliakber Hussain on 31/10/2013.
//  Copyright (c) 2013 Aliakber Hussain. All rights reserved.
//


#import "Validation.h"
#import "ConstantsShareOne.h"
#import "UtilitiesHelper.h"

@implementation Validation

+(BOOL)ValidateNumber:(NSString*)myStr fieldName:(NSString*)fieldName controller:(id)viewController{
    
    NSString *strMatchstring=@"\\b([0-9%_.+\\-]+)\\b";
    NSPredicate *textpredicate=[NSPredicate predicateWithFormat:@"SELF MATCHES %@", strMatchstring];
    BOOL result = [textpredicate evaluateWithObject:myStr];
    if(!result){
        [[UtilitiesHelper shareUtitlities]showToastWithMessage:ALERT_INVLALID_CONTACT title:[NSString stringWithFormat:@"%@ Field",fieldName] delegate:viewController];

    }
    return result;
}

+(BOOL) isEmpty:(NSString *)string fieldName:(NSString*)fieldName controller:(id)viewController
{
	if(string == nil || [string isKindOfClass:[NSNull class]] || [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0){
        [[UtilitiesHelper shareUtitlities]showToastWithMessage:[NSString stringWithFormat:ALERT_FIELD_EMPTY,fieldName] title:[NSString stringWithFormat:@"%@ Field",fieldName] delegate:viewController];
		return TRUE;
    }
	else{
        return FALSE;
    }
	
}

+(BOOL) isEmpty:(NSString *)string
{
	if(string == nil || [string isKindOfClass:[NSNull class]] || [[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] == 0){
		return TRUE;
    }
	else{
        return FALSE;
    }
	
}

+(BOOL) isBlanked:(NSString *)string fieldName:(NSString*)fieldName controller:(id)viewController
{
	if(string == nil || [string isKindOfClass:[NSNull class]] || [string isEqualToString:@""]){
        [[UtilitiesHelper shareUtitlities]showToastWithMessage:[NSString stringWithFormat:ALERT_FIELD_EMPTY,fieldName] title:[NSString stringWithFormat:@"%@ Field",fieldName] delegate:viewController];

		return TRUE;
    }
	else{
        return FALSE;
    }
	
}

+ (BOOL) isValidEmailAddress:(NSString *)emailAddress controller:(id)viewController{
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL result = [emailTest evaluateWithObject:emailAddress];
    if(!result){
        [[UtilitiesHelper shareUtitlities]showToastWithMessage:ALERT_INVALID_EMAIL title:@"Email Address Field" delegate:viewController];
    }
    return result;
}

+(BOOL)isPasswordLength:(NSString*)password fieldName:(NSString*)fieldName minCharacters:(int)minCharacters controller:(id)viewController{
    BOOL result= ([password length]>=minCharacters);
    if(!result){
        [[UtilitiesHelper shareUtitlities]showToastWithMessage:[NSString stringWithFormat:ALERT_PASSWORD_MINIMUM_CHARACTERS,minCharacters] title:fieldName delegate:viewController];

    }
    return result;
}

+(BOOL)isLength:(NSString*)password maxCharacters:(int)maxCharacters fieldName:(NSString*)fieldName controller:(id)viewController{
    BOOL result= ([password length]<=maxCharacters);
    if(!result){
        [[UtilitiesHelper shareUtitlities]showToastWithMessage:[NSString stringWithFormat:ALERT_PASSWORD_MAXIMUM_CHARACTERS,maxCharacters] title:[NSString stringWithFormat:@"%@ Field",fieldName] delegate:viewController];

    }
    return result;
}

+(BOOL)containsAlphabetOnly:(NSString*)str fieldName:(NSString*)fieldName controller:(id)viewController{
    NSString *regex = @"[a-zA-Z ]+";
    NSPredicate *test = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL result = [test evaluateWithObject:str];
    if(!result){
        [[UtilitiesHelper shareUtitlities]showToastWithMessage:[NSString stringWithFormat:ALERT_ALPHABETS_ALLOWED] title:[NSString stringWithFormat:@"%@ Field",fieldName]delegate:viewController];

    }
    return result;
}

+(BOOL)isValidPassword:(NSString*)password confirmPassword:(NSString*)confirmPassword controller:(id)viewController{
    
    if(![password isEqualToString:confirmPassword]){
        [[UtilitiesHelper shareUtitlities]showToastWithMessage:[NSString stringWithFormat:ALERT_PASSWORD_MISMATCH] title:@"Error" delegate:viewController];

        return NO;
    }
    return YES;
}

+ (BOOL)textFieldEmptyValidation:(NSArray *)fieldsArr controller:(id)viewController{
    
    for (UITextField* mytextfield in fieldsArr){
        
        NSString *rawString = [mytextfield text];
        NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
        if ([trimmed length] == 0 || [rawString isEqualToString:@""]) {
            [[UtilitiesHelper shareUtitlities]showToastWithMessage:ALERT_ALL_FIELDS_EMPTY title:@"" delegate:viewController];
            return NO;
        }
    }
    return YES;
}

@end
