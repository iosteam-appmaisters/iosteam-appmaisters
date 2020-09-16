//
//  RegistrationValidUser.h
//  ShareOne
//
//  Created by Ahmed Baloch on 16/09/2020.
//  Copyright © 2020 Ali Akbar. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface RegistrationValidUser : NSObject
-(id) initWithDictionary:(NSDictionary *)registrationValidUser;
@property (nonatomic,strong) NSString *opId;
@property (nonatomic,strong) NSArray *responseDataList;
@property (nonatomic,strong) NSString *apiVersion;
@property (nonatomic,strong) NSString *responseCode;
@property (nonatomic,strong) NSString *messageCode;
@property (nonatomic,strong) NSString *operationTraceId;
@property (nonatomic,strong) NSString *FI_NAME;
@property (nonatomic,strong) NSString *APPLICATION_NAME;
@property (nonatomic,strong) NSString *FI_CONTACT;
@end


