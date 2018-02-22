//
//  Location.h
//  ShareOne
//
//  Created by Qazi Naveed on 19/10/2016.
//  Copyright © 2016 Ali Akbar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Photos.h"
#import "Hours.h"
#import "Address.h"

@interface Location : NSObject

+(void)getAllBranchLocations:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(NSArray *locations))block failureBlock:(void(^)(NSError* error))failBlock;

+(void)getShareOneBranchLocations:(NSDictionary*)param delegate:(id)delegate completionBlock:(void(^)(NSArray *locations))block failureBlock:(void(^)(NSError* error))failBlock;



-(id) initWithDictionary:(NSDictionary *)locationDict;


@property(nonatomic,strong) NSNumber *acceptCash;
@property(nonatomic,strong) NSNumber *acceptDeposit;
@property(nonatomic,strong) NSNumber *access;
@property(nonatomic,strong) NSString *accessNote;
//@property(nonatomic,strong) NSString *address;
@property(nonatomic,strong) NSString *cashless;
@property(nonatomic,strong) NSString *city;
@property(nonatomic,strong) NSString *comment;
@property(nonatomic,strong) NSString *country;
@property(nonatomic,strong) NSString *countryabbreviation;
@property(nonatomic,strong) NSString *countryId;
@property(nonatomic,strong) NSString *countryname;
@property(nonatomic,strong) NSString *county;
@property(nonatomic,strong) NSString *cuForKids;
@property(nonatomic,strong) NSString *displayCU;
@property(nonatomic,strong) NSString *distance;
@property(nonatomic,strong) NSNumber *driveThru;
@property(nonatomic,strong) NSString *driveThruOnly;
@property(nonatomic,strong) NSString *envelopeRequired;
@property(nonatomic,strong) NSString *fax;
@property(nonatomic,strong) NSString *fridayClose;
@property(nonatomic,strong) NSString *fridayDriveThruClose;
@property(nonatomic,strong) NSString *fridayDriveThruOpen;
@property(nonatomic,strong) NSString *fridayOpen;
@property(nonatomic,strong) NSString *handicapAccess;
@property(nonatomic,strong) NSString *hoursAvailable;
@property(nonatomic,strong) NSString *hoursId;
@property(nonatomic,strong) NSString *hours_open_value;
@property(nonatomic,strong) NSString *id;
@property(nonatomic,strong) NSString *installationType;
@property(nonatomic,strong) NSString *installationTypeId;
@property(nonatomic,strong) NSString *institutionname;
@property(nonatomic,strong) NSString *institutionRtn;
@property(nonatomic,strong) NSString *latitude;
@property(nonatomic,strong) NSString *limitedTransactions;
@property(nonatomic,strong) NSString *locatortype;
@property(nonatomic,strong) NSString *longitude;
@property(nonatomic,strong) NSString *militaryIdRequired;
@property(nonatomic,strong) NSString *mondayClose;
@property(nonatomic,strong) NSString *mondayDriveThruClose;
@property(nonatomic,strong) NSString *mondayDriveThruOpen;
@property(nonatomic,strong) NSString *mondayOpen;
@property(nonatomic,strong) NSString *onMilitaryBase;
@property(nonatomic,strong) NSString *onPremise;
@property(nonatomic,strong) NSNumber *open24Hours;
@property(nonatomic,strong) NSString *publish;
@property(nonatomic,strong) NSString *restrictedAccess;
@property(nonatomic,strong) NSString *retailOutlet;
@property(nonatomic,strong) NSString *saturdayClose;
@property(nonatomic,strong) NSString *saturdayDriveThruClose;
@property(nonatomic,strong) NSString *saturdayDriveThruOpen;
@property(nonatomic,strong) NSString *saturdayOpen;
@property(nonatomic,strong) NSString *secondaryStructure;
@property(nonatomic,strong) NSString *selfServiceDevice;
@property(nonatomic,strong) NSString *selfServiceOnly;
@property(nonatomic,strong) NSString *singleMap;
@property(nonatomic,strong) NSString *state;
@property(nonatomic,strong) NSString *stateAbbreviation;
@property(nonatomic,strong) NSString *stateId;
@property(nonatomic,strong) NSString *sundayClose;
@property(nonatomic,strong) NSString *sundayDriveThruClose;
@property(nonatomic,strong) NSString *sundayDriveThruOpen;
@property(nonatomic,strong) NSString *sundayOpen;
@property(nonatomic,strong) NSString *surcharge;
@property(nonatomic,strong) NSString *terminalId;
@property(nonatomic,strong) NSString *thursdayClose;
@property(nonatomic,strong) NSString *thursdayDriveThruClose;
@property(nonatomic,strong) NSString *thursdayDriveThruOpen;
@property(nonatomic,strong) NSString *thursdayOpen;
@property(nonatomic,strong) NSString *tuesdayClose;
@property(nonatomic,strong) NSString *tuesdayDriveThruClose;
@property(nonatomic,strong) NSString *tuesdayDriveThruOpen;
@property(nonatomic,strong) NSString *tuesdayOpen;
@property(nonatomic,strong) NSString *vCom;
@property(nonatomic,strong) NSString *walkUp;
@property(nonatomic,strong) NSString *webAddress;
@property(nonatomic,strong) NSString *wednesdayClose;
@property(nonatomic,strong) NSString *wednesdayDriveThruClose;
@property(nonatomic,strong) NSString *wednesdayDriveThruOpen;
@property(nonatomic,strong) NSString *wednesdayOpen;
@property(nonatomic,strong) NSString *zip;
@property(nonatomic,strong) NSString *zip4;



@property(nonatomic,strong) NSNumber *Branchid;
@property(nonatomic,strong) NSString *Name;
@property(nonatomic,strong) NSNumber *Code;
@property(nonatomic,strong) NSString *Timezone;
@property(nonatomic,strong) NSString *Phonenumber;
@property(nonatomic,strong) NSNumber *Routingnumber;
@property(nonatomic,strong) NSNumber *Gpslatitude;
@property(nonatomic,strong) NSNumber *Gpslongitude;
@property(nonatomic,strong) Address *address;
@property(nonatomic,strong) NSMutableArray *hours;
@property(nonatomic,strong) NSMutableArray *photos;

@property(nonatomic,strong) NSNumber *Drivethruisopen;
@property(nonatomic,strong) NSNumber *Lobbyisopen;



@end
