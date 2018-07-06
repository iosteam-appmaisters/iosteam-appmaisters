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
    
    NSMutableDictionary *dict = [param mutableCopy];
    [dict setValue:[Configuration getVertifiRDCTestMode] forKey:@"mode"];
    [dict setValue:@"true" forKey:@"scaled"];
//    NSLog(@"param vertify : %@",param);

    
    [[AppServiceModel sharedClient] postRequestForVertifiWithParam:dict progressMessage:message urlString:vertifiUrl delegate:delegate completionBlock:^(NSObject *response,BOOL success) {
        
        if(response && success){
            NSData * data = (NSData *)response;
            
            NSDictionary *xmlDoc = [NSDictionary dictionaryWithXMLData:data];
            NSLog(@"Response string: %@", [NSString stringWithCString:[data bytes] encoding:NSISOLatin1StringEncoding]);
//            NSString *responseString = [NSString stringWithCString:[data bytes] encoding:NSISOLatin1StringEncoding];
            

            NSString *InputValidation = [xmlDoc valueForKeyPath:@"MessageValidation.InputValidation"];
            NSString *LoginValidation = [xmlDoc valueForKeyPath:@"UserValidation.LoginValidation"];
            NSString *DepositLimit = [xmlDoc valueForKeyPath:@"UserValidation.DepositLimit"];

            NSString *SSOKey = [xmlDoc valueForKeyPath:@"DepositStatus.SSOKey"];
            NSString *Deposit_ID = [xmlDoc valueForKeyPath:@"Deposit.Deposit_ID"];
            NSString *URL = [xmlDoc valueForKeyPath:@"Report.URL"];
            NSString *DepositStatus = [xmlDoc valueForKeyPath:@"DepositStatus.DepositDispositionMessage"];
            NSString *DepositID = [xmlDoc valueForKeyPath:@"DepositStatus.DepositID"];

            NSString *EUAContents = [xmlDoc valueForKeyPath:@"UserValidation.EUAContents"];
            
            NSString *CARMismatch = [xmlDoc valueForKeyPath:@"ImageValidation.CARMismatch"];

            NSString *CARAmount = [xmlDoc valueForKeyPath:@"ImageValidation.CARAmount"];

            NSArray *DepositArray = [xmlDoc arrayValueForKeyPath:@"Deposit"];
            NSDictionary *imageDictionary = [xmlDoc valueForKeyPath:@"Deposit.Deposit_Item"];
            NSString *deletedError = [xmlDoc valueForKeyPath:@"Status.Error"];


            VertifiObject *obj = [[VertifiObject alloc] init];
            obj.InputValidation=InputValidation;
            obj.LoginValidation=LoginValidation;
            obj.SSOKey=SSOKey;
            obj.Deposit_ID=Deposit_ID;
            obj.URL=URL;
            obj.DepositLimit=DepositLimit;
            obj.DepositStatus=DepositStatus;
            obj.DepositIDCurrentCheck=DepositID;
            obj.CARAmount=CARAmount;
            obj.CARMismatch=CARMismatch;
            obj.deletedError=deletedError;

            
            if(EUAContents)
                obj.EUAContents= [ShareOneUtility decodeBase64ToStirng:EUAContents];
            obj.depositArr=[VertifiObject parseAllDepositsWithObject:DepositArray];
            
            obj.imageDictionary=imageDictionary;
            User *user = [ShareOneUtility getUserObject];
            user.vertifyEUAContents= obj.EUAContents;
            
            if(LoginValidation)
                user.LoginValidation=LoginValidation;
            [ShareOneUtility getSavedObjectOfCurrentLoginUser:user];
            block(obj,TRUE);
        }
        else{
            block(response,FALSE);
        }
    } failureBlock:^(NSError *error) {}];
}
@end
