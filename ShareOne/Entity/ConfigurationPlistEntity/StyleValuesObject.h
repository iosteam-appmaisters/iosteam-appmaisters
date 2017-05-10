//
//  StyleValuesObject.h
//  ShareOne
//
//  Created by Qazi Naveed on 5/9/17.
//  Copyright © 2017 Ali Akbar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StyleValuesObject : NSObject

@property (nonatomic,strong) NSString *buttoncolortop;
@property (nonatomic,strong) NSString *buttoncolorbottom;
@property (nonatomic,strong) NSString *buttoncolorhover;
@property (nonatomic,strong) NSString *buttoncolorborder;
@property (nonatomic,strong) NSString *buttontextcolor;
@property (nonatomic,strong) NSString *textcolor;
@property (nonatomic,strong) NSString *menubackgroundcolor;
@property (nonatomic,strong) NSString *menutextcolor;


+(StyleValuesObject *)parseStyleValues:(NSArray *)array;
@end
