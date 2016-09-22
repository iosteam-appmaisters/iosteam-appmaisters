//
//  ShareOneUtility.m
//  ShareOne
//
//  Created by Qazi Naveed on 20/09/2016.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import "ShareOneUtility.h"

#import "Constants.h"
@implementation ShareOneUtility

+ (NSArray *)getSideMenuDataFromPlist{
    
    NSArray *arrPlist = nil;
    
    NSString* plistPath = [[NSBundle mainBundle] pathForResource:PLIST_NAME ofType:FILE_TYPE];
    arrPlist = [NSArray arrayWithContentsOfFile:plistPath];
    return   [self manipulateArray:arrPlist];
;
}

+(NSMutableArray *)manipulateArray:(NSArray *)arr{
    
    NSMutableArray *arrayToreturn = [[NSMutableArray alloc] init];
    [arr enumerateObjectsUsingBlock:^(NSArray *arr, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if([arr isKindOfClass:[NSArray class]]){
            [arrayToreturn addObject:arr[0]];
        }
    }];
    return arrayToreturn;
}

+ (NSArray *)getDummyDataForQB{
    
    
    NSArray *tranDetailArr = [NSArray arrayWithObjects:
                    [NSDictionary dictionaryWithObjectsAndKeys:@"Transaction 1",@"tran_title",@"MM/DD/YYYY",@"tran_date",@"$100.00",@"tran_amt", nil],
                    [NSDictionary dictionaryWithObjectsAndKeys:@"Transaction 2",@"tran_title",@"MM/DD/YYYY",@"tran_date",@"$300.00",@"tran_amt", nil],
                    [NSDictionary dictionaryWithObjectsAndKeys:@"Transaction 3",@"tran_title",@"MM/DD/YYYY",@"tran_date",@"$200.00",@"tran_amt", nil],
                    [NSDictionary dictionaryWithObjectsAndKeys:@"Transaction 4",@"tran_title",@"MM/DD/YYYY",@"tran_date",@"$100.00",@"tran_amt", nil]
                    , nil];
    
    
    return [NSArray arrayWithObjects:
            [NSDictionary dictionaryWithObjectsAndKeys:@"Share",@"section_title",@"$157.50",@"section_amt",tranDetailArr,@"section_details", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"Checking",@"section_title",@"$23157.50",@"section_amt",tranDetailArr,@"section_details", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"Home Loan",@"section_title",@"$14872.14",@"section_amt",tranDetailArr,@"section_details", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"Car Loan",@"section_title",@"$1347.20",@"section_amt",tranDetailArr,@"section_details", nil],
            [NSDictionary dictionaryWithObjectsAndKeys:@"Medical Loan",@"section_title",@"$4745.32",@"section_amt",tranDetailArr,@"section_details", nil]
            ,nil];
}

@end
