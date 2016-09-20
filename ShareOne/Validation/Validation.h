//
//  SignInModuleValidation.h
//  UserSignInModule
//
//  Created by Aliakber Hussain on 31/10/2013.
//  Copyright (c) 2013 Aliakber Hussain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface Validation : NSObject

+(BOOL)ValidateNumber:(NSString*)myStr fieldName:(NSString*)fieldName controller:(id)viewController;
+(BOOL) isEmpty:(NSString *)string ;
+(BOOL) isEmpty:(NSString *)string fieldName:(NSString*)fieldName controller:(id)viewController;
+ (BOOL) isValidEmailAddress:(NSString *)emailAddress controller:(id)viewController;
+ (BOOL)isPasswordLength:(NSString*)password fieldName:(NSString*)fieldName minCharacters:(int)minCharacters controller:(id)viewController;
+(BOOL)isLength:(NSString*)password maxCharacters:(int)maxCharacters fieldName:(NSString*)fieldName controller:(id)viewController;
+(BOOL)containsAlphabetOnly:(NSString*)str fieldName:(NSString*)fieldName controller:(id)viewController;
+(BOOL)isValidPassword:(NSString*)password confirmPassword:(NSString*)confirmPassword controller:(id)viewController;


+(BOOL) isBlanked:(NSString *)string fieldName:(NSString*)fieldName controller:(id)viewController;

+ (BOOL)textFieldEmptyValidation:(NSArray *)fieldsArr controller:(id)viewController;

@end
