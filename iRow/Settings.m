//
//  Settings.m
//  iRow
//
//  Created by David van Leeuwen on 26-09-11.
//  Copyright 2011 strApps. All rights reserved.
//

#import "Settings.h"

@implementation Settings

@synthesize courseData;
@synthesize moc;
@synthesize user, currentCourse, currentBoat;
@synthesize speedUnit;
@synthesize minSpeed;
@synthesize showStrokeProfile;
@synthesize backgroundTracking;
@synthesize hundredHzSampling, autoOrientation, autoSave;

// we can't init the courseDaa objet, because it needs the sharedSettings instace. 
// this would lead to a recursive loop. 
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        ud = [NSUserDefaults standardUserDefaults];
        id delegate = UIApplication.sharedApplication.delegate;
        moc = [delegate managedObjectContext];
        [self readCurrentCoreDataObjects];
        speedUnit = [ud integerForKey:@"speedUnit"];
        minSpeed = [ud doubleForKey:@"minSpeed"];
        showStrokeProfile = [ud boolForKey:@"showStrokeProfile"];
        backgroundTracking = [ud boolForKey:@"backgroundTracking"];
        hundredHzSampling = [ud boolForKey:@"hundredHzSampling"];
        autoOrientation = [ud boolForKey:@"autoOrientation"];
        autoSave = [ud boolForKey:@"autoSave"];
        [self reloadUserDefaults];
    }
    
    return self;
}

+(Settings*)sharedInstance {
	static Settings * settings = nil;
	if (settings==nil) {
		settings = [[Settings alloc] init];
	}
	return settings;
}

// these are settings that can be changed from the out-of-app settings
// we want to get rid of those...
-(void)reloadUserDefaults {
    if ([ud objectForKey:@"stroke_sensitivity"]==nil) logSensitivity = 1.4;
    else logSensitivity = [ud doubleForKey:@"stroke_sensitivity"];
    unitSystem = [ud integerForKey:@"unit_system"]; // default 0: metric    
}

-(void)readCurrentCoreDataObjects {
    currentCourse = [self loadManagedObject:@"current_course"];
    currentBoat = [self loadManagedObject:@"currentBoat"];
    user = [self loadManagedObject:@"user"];
}

-(void)setObject:(id)object forKey:(NSString *)key {
    [ud setObject:[NSKeyedArchiver archivedDataWithRootObject:object] forKey:key];
    [ud synchronize];
}

-(id)loadObjectForKey:(NSString *)key {
    NSData * data = [ud objectForKey:key];
    if (data==nil) return nil;
    id res=nil;
    @try {
        res = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    @catch (NSException * exception) {
        res = nil;
    }
    return res;
}

-(void)setManagedObject:(NSManagedObject*)mo forKey:(NSString*) key {
    [self setObject:[[mo objectID] URIRepresentation] forKey:key];
}

-(id)loadManagedObject:(NSString*)key {
    NSURL * uri = [self loadObjectForKey:key];
    if (uri==nil) return nil;
    NSManagedObjectID * moid = [moc.persistentStoreCoordinator managedObjectIDForURIRepresentation:uri];
	if (moid == nil) return nil;
	NSError * error;
	return [moc existingObjectWithID:moid error:&error];
}

-(NSData*)objectAsData:(NSManagedObject*)mo {
	return [NSKeyedArchiver archivedDataWithRootObject:[[mo objectID] URIRepresentation]];
}

// this will return an existing or a new instance of CourseData
-(CourseData*)courseData {
    if (courseData==nil) courseData = [self loadObjectForKey:@"courseData"]; // historical naming...
    if (courseData==nil) courseData = [[CourseData alloc] init];
    return courseData;
}

-(void)setCourseData:(CourseData *)cd {
    courseData = cd;
    [self setObject:courseData forKey:@"courseData"]; // historical name...
}

-(void)setCurrentCourse:(Course*)c {
    currentCourse = c;
    [self setManagedObject:c forKey:@"current_course"];
}

-(void)setUser:(Rower *)u {
    user = u;
    [self setManagedObject:u forKey:@"user"];
}

-(void)setSpeedUnit:(int)su {
    speedUnit = su;
    [ud setInteger:su forKey:@"speedUnit"];
    [ud synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"unitsChanged" object:nil];
}

-(void)setCurrentBoat:(Boat *)b {
    currentBoat = b;
    [self setManagedObject:b forKey:@"currentBoat"];
}

-(int)unitSystem {
    return unitSystem;
}

-(void)setUnitSystem:(int)us {
    unitSystem = us;
    [ud setInteger:us forKey:@"unit_system"];
    [ud synchronize];
    [[NSNotificationQueue defaultQueue] enqueueNotification:[NSNotification notificationWithName:@"unitsChanged" object:nil] postingStyle:NSPostWhenIdle];
}

-(double)logSensitivity {
    return logSensitivity;
}

-(void)setLogSensitivity:(double)ls {
    logSensitivity = ls;
    [ud setDouble:logSensitivity forKey:@"stroke_sensitivity"];
    [ud synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"sensitivityChanged" object:nil];
}

-(void)setMinSpeed:(double)ms {
    minSpeed = ms;
    [ud setDouble:minSpeed forKey:@"minSpeed"];
    [ud synchronize];
}

-(void)setShowStrokeProfile:(BOOL)s {
    showStrokeProfile = s;
    [ud setBool:showStrokeProfile forKey:@"showStrokeProfile"];
    [ud synchronize];
}

-(void)setBackgroundTracking:(BOOL)b {
    backgroundTracking = b;
    [ud setBool:backgroundTracking forKey:@"backgroundTracking"];
    [ud synchronize];
}

-(void)setHundredHzSampling:(BOOL)b {
    hundredHzSampling = b;
    [ud setBool:hundredHzSampling forKey:@"hundredHzSampling"];
    [ud synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hardwareSamplingRateChanged" object:nil];
}

-(void)setAutoOrientation:(BOOL)b {
    autoOrientation = b;
    [ud setBool:b forKey:@"autoOrientation"];
    [ud synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"autoOrientationChanged" object:nil];
}

-(void)setAutoSave:(BOOL)b {
    autoSave = b;
    [ud setBool:b forKey:@"autoSave"];
    [ud synchronize];
}

@end
