//
//  Photo.h
//  ShareOne
//
//  Created by Qazi Naveed on 12/19/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Photos : NSObject

@property(nonatomic,strong) NSNumber *Branchphotoid;
@property(nonatomic,strong) NSString *Name;
@property(nonatomic,strong) NSString *Description;
@property(nonatomic,strong) NSString *Data;
@property(nonatomic,strong) NSString *Filetype;



+(NSMutableArray *) parsePhotos:(NSArray *)photosArr;



@end
