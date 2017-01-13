//
//  CashDeposit.m
//  ShareOne
//
//  Created by Qazi Naveed on 10/10/2016.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//
#import "SharedUser.h"
#import "CashDeposit.h"
#import "XMLDictionary.h"
#import "VertifiObject.h"
#import "ShareOneUtility.h"
#import "User.h"

@implementation CashDeposit
+(void)getRegisterToVirtifi:(NSDictionary*)param delegate:(id)delegate url:(NSString *)vertifiUrl AndLoadingMessage:(NSString *)message completionBlock:(void(^)(NSObject *user,BOOL succes))block failureBlock:(void(^)(NSError* error))failBlock{

    
    [[AppServiceModel sharedClient] postRequestForVertifiWithParam:param progressMessage:message urlString:vertifiUrl delegate:delegate completionBlock:^(NSObject *response,BOOL success) {
        
        if(response && success){
            NSData * data = (NSData *)response;
            
            NSDictionary *xmlDoc = [NSDictionary dictionaryWithXMLData:data];
            NSLog(@"Response string: %@", [NSString stringWithCString:[data bytes] encoding:NSISOLatin1StringEncoding]);
//            NSString *responseString = [NSString stringWithCString:[data bytes] encoding:NSISOLatin1StringEncoding];
            

            NSString *InputValidation = [xmlDoc valueForKeyPath:@"MessageValidation.InputValidation"];
            NSString *LoginValidation = [xmlDoc valueForKeyPath:@"UserValidation.LoginValidation"];
            NSString *SSOKey = [xmlDoc valueForKeyPath:@"DepositStatus.SSOKey"];
            NSString *Deposit_ID = [xmlDoc valueForKeyPath:@"Deposit.Deposit_ID"];
            NSString *URL = [xmlDoc valueForKeyPath:@"Report.URL"];
            NSString *DepositStatus = [xmlDoc valueForKeyPath:@"DepositStatus.DepositDispositionMessage"];
            NSString *EUAContents = [xmlDoc valueForKeyPath:@"UserValidation.EUAContents"];

            NSArray *DepositArray = [xmlDoc arrayValueForKeyPath:@"Deposit"];
            NSDictionary *imageDictionary = [xmlDoc valueForKeyPath:@"Deposit.Deposit_Item"];


            VertifiObject *obj = [[VertifiObject alloc] init];
            obj.InputValidation=InputValidation;
            obj.LoginValidation=LoginValidation;
            obj.SSOKey=SSOKey;
            obj.Deposit_ID=Deposit_ID;
            obj.URL=URL;
            obj.DepositStatus=DepositStatus;
            if(EUAContents)
                obj.EUAContents= [ShareOneUtility decodeBase64ToStirng:EUAContents];
            obj.depositArr=[VertifiObject parseAllDepositsWithObject:DepositArray];
            
            obj.imageDictionary=imageDictionary;
            User *user = [ShareOneUtility getUserObject];
            user.vertifyEUAContents= obj.EUAContents;
            
            [ShareOneUtility getSavedObjectOfCurrentLoginUser:user];

            
            block(obj,TRUE);
        }
        else{
            block(response,FALSE);
        }
        
    } failureBlock:^(NSError *error) {
        
    }];
}

@end
