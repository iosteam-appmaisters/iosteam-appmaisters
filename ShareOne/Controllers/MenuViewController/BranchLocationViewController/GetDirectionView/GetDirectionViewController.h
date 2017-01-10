//
//  GetDirectionViewController.h
//  ShareOne
//
//  Created by Shahrukh Jamil on 9/28/16.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface GetDirectionViewController : BaseViewController
{
    
}
@property (nonatomic,strong)NSString *sourceAddress;
@property (nonatomic,strong)NSString *DestinationAddress;
@property (nonatomic,strong)NSArray *locationArr;
@property int selectedIndex;


@end
