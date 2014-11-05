//
//  AppDelegate.m
//  H-ound
//
//  Created by Matteo Comisso on 10/07/14.
//  Copyright (c) 2014 Blue-Mate. All rights reserved.
//

#import "AppDelegate.h"
#define HFARMBEACONREGION @"B70D40BA-A3B1-49BD-8671-6D47AE275F50"

@import CoreLocation;

@interface AppDelegate() <CLLocationManagerDelegate>

//Regioni da monitorare
@property (nonatomic, strong) NSMutableArray *allRegionsToMonitor;
@property (nonatomic, strong) CLBeaconRegion *hfarmBeaconRegion;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSUUID *hfarmUUID;

@property (nonatomic, strong) NSDictionary *zonesDictionary;

@property int enteredTimes;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //VARS
    _enteredTimes = 0;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:
                      @"parseData" ofType:@"plist"];
    NSMutableDictionary *parseData = [[NSMutableDictionary alloc]initWithContentsOfFile:path];
    
    //Parse Initialization
    [Parse setApplicationId:[parseData objectForKey:@"applicationId"]
                  clientKey:[parseData objectForKey:@"clientKey"]];
    
    UIMutableUserNotificationAction *action1 = [[UIMutableUserNotificationAction alloc]init];
    
    [action1 setActivationMode:UIUserNotificationActivationModeBackground];
    [action1 setTitle:@"Refart"];
    [action1 setIdentifier:@"REFART"];
    [action1 setDestructive:YES];
    [action1 setAuthenticationRequired:NO];
    
    UIMutableUserNotificationCategory *category = [[UIMutableUserNotificationCategory alloc]init];
    [category setIdentifier:@"actionable"];
    [category setActions:@[action1] forContext:UIUserNotificationActionContextDefault];
    
    
    //-- Set Notification
    if ([application respondsToSelector:@selector(isRegisteredForRemoteNotifications)])
    {
        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:[NSSet setWithObject:category]]];
        
        [application registerForRemoteNotifications];
    }
    else
    {
        // iOS < 8 Notifications
        [application registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    }
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    [PFFacebookUtils initializeFacebook];

    //LOCATION MANAGER PARTS
    _hfarmUUID = [[NSUUID alloc]initWithUUIDString:HFARMBEACONREGION];
    self.locationManager = [[CLLocationManager alloc]init];
    _locationManager.delegate = self;
    
    // Generico ID di monitoring
    _hfarmBeaconRegion = [[CLBeaconRegion alloc]initWithProximityUUID:_hfarmUUID identifier:@"com.blueMate.H-oundFartEd"];

    [_locationManager startMonitoringForRegion:_hfarmBeaconRegion];

    BOOL monitoringAvailable = [CLLocationManager isMonitoringAvailableForClass:[CLBeaconRegion class]];
    
    if (monitoringAvailable) {
        NSLog(@"Monitoring Available");
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized) {
                [_locationManager startMonitoringForRegion:_hfarmBeaconRegion];
        }
        else
        {
            NSLog(@"Auth status: not available");
        }
    }
    else
    {
        NSLog(@"Monitoring not available");
    }
    
    //DONE!
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [application cancelAllLocalNotifications];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    // Logs 'install' and 'app activate' App Events.
    [FBAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - LocationMangager delegate methods
-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    //Send notification to parse of exit
    //Tell parse that i'm entered the region => user has a major number
    if (_enteredTimes == 0) {

        //Show local notification
        _enteredTimes++;
        
        NSLog(@"LocationManager entered in region %@", [region description]);
        
        PFUser *user = [PFUser currentUser];
        user[@"inside"] = [NSNumber numberWithBool:YES];
        [user saveInBackground];

        //Comunicate to all people watching
        PFPush *userEnteredInZone = [[PFPush alloc]init];
        [userEnteredInZone setChannels:@[@"all"]];
        
        [userEnteredInZone setData:@{@"t": @"l",
                                     @"id": [PFUser currentUser].objectId,
                                     @"title": [[PFUser currentUser]objectForKey:@"name"],
                                     @"alert": @"WEI",
                                     @"s": @"o"}];

        //        [userEnteredInZone setData:@{@"title": [[PFUser currentUser]objectForKey:@"name"]}];
        //[userEnteredInZone setMessage:@"Arrivato"];
        
        [userEnteredInZone sendPushInBackground];
    }
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    //Send notification to parse of exit
    //Delete major number from user
    
    PFUser *user = [PFUser currentUser];
    user[@"inside"] = [NSNumber numberWithBool:NO];
    [user saveInBackground];
    
    UILocalNotification *goodbyeNotification = [[UILocalNotification alloc]init];
    goodbyeNotification.alertBody = [NSString stringWithFormat:@"Arrivederci %@ e grazie della visita", [user objectForKey:@"name"]];
    goodbyeNotification.soundName = @"fart.caf";
    
    [[UIApplication sharedApplication] presentLocalNotificationNow:goodbyeNotification];
}

-(void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
    NSLog(@"Starting monitoring for region %@", [region identifier]);
    [_locationManager startRangingBeaconsInRegion:_hfarmBeaconRegion];
}

-(void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    NSString *stringState = [[NSString alloc]init];

    switch (state) {
        case 0:
            stringState = @"Unknown";
            break;
        case 1:
            stringState = @"Inside";
            break;
        case 2:
            stringState = @"Outside";
            break;
        default:
            stringState = @"default case";
            break;
    }
    NSLog(@"Determined state for region %@, as %@", [region identifier], stringState);
}

#pragma mark - Notifications delegates methods
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    //Local Notification income
    NSLog(@"[AppDelegate] Local notification received");
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"AppDelegate did receive Remote Notification. %@", [userInfo description]);
    if ([[userInfo objectForKey:@"t"] isEqualToString:@"l"]) {
        NSString *username = [userInfo objectForKey:@"title"];
        NSString *alertText = [userInfo objectForKey:@"alert"];
        NSString *concatStrings = [username stringByAppendingString:@" in "];
        NSString *concat2 = [concatStrings stringByAppendingString:alertText];
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:username
                                                       message:concat2
                                                      delegate:self
                                             cancelButtonTitle:@"O-WEI"
                                             otherButtonTitles:nil, nil];
        [alert show];
        
        
    }
    else if ([[userInfo objectForKey:@"t"]isEqualToString:@"m"])
    {
        UIAlertView *messageNotification = [[UIAlertView alloc]initWithTitle:[userInfo objectForKey:@"title"]
                                                                     message:[userInfo objectForKey:@"alert"]
                                                                    delegate:self
                                                           cancelButtonTitle:@"OK"
                                                           otherButtonTitles:nil, nil];
        [messageNotification show];
    }
    else if ([[userInfo objectForKey:@"t"]isEqualToString:@"a"])
    {
        //iOS 7 notification to communicate the entrance in area.
        //Delegate shoud turn IN/OUT label in tableview on - off
    }
}

-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}

-(void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler
{
    if ([identifier isEqualToString:@"REFART"]) {
        //Refart
        NSLog(@"%@",[userInfo description]);
        
        NSString *userChannel = [userInfo objectForKey:@"senderId"];

        PFPush *sendPush = [[PFPush alloc]init];
        [sendPush setData:@{@"title": [[PFUser currentUser]objectForKey:@"name"],
                            @"alert":@"💨",
                            @"sound":@"fart.caf",
                            @"category":@"actionable",
                            @"senderId":[[NSString stringWithFormat:@"ch"]stringByAppendingString:[[PFUser currentUser] objectForKey:@"username"]],
                            @"t":@"m"}];
        //    [sendPush setMessage:[[PFUser currentUser]objectForKey:@"name"]];
        [sendPush setChannel:userChannel];
        
        //NSLog(@"Username: %@", usernameOfTouchedUser);
        [sendPush sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                NSLog(@"Push notification sent!");
            }
            else
            {
                NSLog(@"Errors while sending push: %@, %@", [error localizedDescription], [error localizedFailureReason]);
            }
        }];
    }

    completionHandler();
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
    
}

@end
