//
//  VertifiAgreemantController.m
//  ShareOne
//
//  Created by Qazi Naveed on 11/24/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "VertifiAgreemantController.h"
#import "MobileDepositController.h"
#import "User.h"
#import "CashDeposit.h"
#import "VertifiObject.h"

@implementation VertifiAgreemantController

-(void)viewDidLoad{
    [super viewDidLoad];
    

    User *user = [ShareOneUtility getUserObject];
    [_webView loadHTMLString:user.vertifyEUAContents baseURL:nil];
}


-(IBAction)goAcceptAgreemant:(id)sender{

    
    [self VertifiRegAcceptance];
}

-(void)VertifiRegAcceptance{
    
    __weak VertifiAgreemantController *weakSelf = self;
    
    [ShareOneUtility showProgressViewOnView:self.view];

    [CashDeposit getRegisterToVirtifi:[NSDictionary dictionaryWithObjectsAndKeys:[ShareOneUtility getSessionnKey],@"session",REQUESTER_VALUE,@"requestor",[NSString stringWithFormat:@"%d",[ShareOneUtility getTimeStamp]],@"timestamp",ROUTING_VALUE,@"routing",[ShareOneUtility getMemberValue],@"member",[ShareOneUtility getAccountValue],@"account",[ShareOneUtility  getMacForVertifiForSuffix:nil],@"MAC",[ShareOneUtility getMemberName],@"membername",[ShareOneUtility getMemberEmail],@"email", nil] delegate:weakSelf url:kVERTIFI_ACCEPTANCE_TEST AndLoadingMessage:nil completionBlock:^(NSObject *user,BOOL success) {
        
        [ShareOneUtility hideProgressViewOnView:weakSelf.view];

        VertifiObject *obj = (VertifiObject *)user;
        if([obj.InputValidation isEqualToString:@"OK"]){
            [weakSelf proceedToVertifyWithObject:weakSelf];
            User *user = [ShareOneUtility getUserObject];
            user.vertifyEUAContents=nil;
            [ShareOneUtility saveUserObject:user];
        }
        else
            [[ShareOneUtility shareUtitlities] showToastWithMessage:obj.LoginValidation title:@"Status" delegate:weakSelf];
        
    } failureBlock:^(NSError *error) {
        
    }];
    
}

-(void)proceedToVertifyWithObject:(VertifiAgreemantController *)obj{
    
    [ShareOneUtility saveSettingsWithStatus:TRUE AndKey:VERTIFI_AGREEMANT_KEY];
    
    MobileDepositController *objMobileDepositController = [obj.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([MobileDepositController class])];
    objMobileDepositController.navigationItem.title=[ShareOneUtility getTitleOfMobileDeposit];
    [obj.navigationController pushViewController:objMobileDepositController animated:YES];
}


-(IBAction)goDeclineAgreemant:(id)sender{

    
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
}

@end
