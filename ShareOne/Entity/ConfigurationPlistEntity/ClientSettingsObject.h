//
//  ClientSettingsObject.h
//  ShareOne
//
//  Created by Qazi Naveed on 5/9/17.
//  Copyright © 2017 Ali Akbar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClientSettingsObject : NSObject

@property (nonatomic,strong) NSString *deeptargetid;
@property (nonatomic,strong) NSNumber *disableadsglobally;
@property (nonatomic,strong) NSString *sociallinkfacebook;
@property (nonatomic,strong) NSString *sociallinktwitter;
@property (nonatomic,strong) NSString *sociallinklinkedin;
@property (nonatomic,strong) NSString *routingnumber;
@property (nonatomic,strong) NSString *maintenanceverbiage;
@property (nonatomic,strong) NSString *joinculink;
@property (nonatomic,strong) NSString *applyloanlink;
@property (nonatomic,strong) NSString *branchlocationlink;
@property (nonatomic,strong) NSString *contactculink;
@property (nonatomic,strong) NSString *rateslink;
@property (nonatomic,strong) NSString *privacylink;

@property (nonatomic,strong) NSString *coopid;
@property (nonatomic,strong) NSString *basewebviewurl;


@property (nonatomic,strong) NSString *vertifirdcsecretkey;
@property (nonatomic,strong) NSString *vertifirdcrequestorkey;
@property (nonatomic,strong) NSString *vertifirdctestmode;
@property (nonatomic,strong) NSString *vertifirdcurl;

+(ClientSettingsObject *)parseClientSettings:(NSArray *)array;

@end
