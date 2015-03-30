//
//  AppDelegate.m
//  H-ound
//
//  Created by Matteo Comisso on 10/07/14.
//  Copyright (c) 2014 Blue-Mate. All rights reserved.
//

#import "AppDelegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <MoPub/MoPub.h>

#import "UAObfuscatedString.h"

#import <CWStatusBarNotification/CWStatusBarNotification.h>

#import "PushNotificationMaster.h"

@import AVFoundation;

@interface AppDelegate() <AVAudioPlayerDelegate>

@property (nonatomic, strong) CWStatusBarNotification *notification;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    [Fabric with:@[CrashlyticsKit, MoPubKit]];

    /*
     applicationId: PM1r1PUPWT8Ea5RfUFjuhoV1fcvlEiyJeT39DyKV
     clientKey:     my7EHEbViYEbzUIUJH07SiRGcxwALaY0PBiY2lST
     */
    
    //Parse Initialization
    [Parse setApplicationId:Obfuscate.P.M._1.r._1.P.U.P.W.T._8.E.a._5.R.f.U.F.j.u.h.o.V._1.f.c.v.l.E.i.y.J.e.T._3._9.D.y.K.V
                  clientKey:Obfuscate.m.y._7.E.H.E.b.V.i.Y.E.b.z.U.I.U.J.H._0._7.S.i.R.G.c.x.w.A.L.a.Y._0.P.B.i.Y._2.l.S.T];
    
    [PFAnalytics trackAppOpenedWithLaunchOptionsInBackground:launchOptions block:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            
        }
        else
        {
            DLog(@"%@ - %@", error.localizedDescription, error.localizedFailureReason);
        }
    }];
    
    if (IS_OS_8_OR_LATER) {
        UIMutableUserNotificationAction *action1 = [[UIMutableUserNotificationAction alloc]init];
        
        [action1 setActivationMode:UIUserNotificationActivationModeBackground];
        [action1 setTitle:@"Refart"];
        [action1 setIdentifier:@"REFART"];
        [action1 setDestructive:YES];
        [action1 setAuthenticationRequired:NO];
        
        UIMutableUserNotificationCategory *category = [[UIMutableUserNotificationCategory alloc]init];
        [category setIdentifier:@"actionable"];
        [category setActions:@[action1] forContext:UIUserNotificationActionContextDefault];

        // iOS 8 Notifications
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:[NSSet setWithObject:category]]];
        
        [application registerForRemoteNotifications];
    }
    
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    [PFFacebookUtils initializeFacebook];
    
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

#pragma mark - Notifications delegates methods
-(void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"fart" ofType:@"mp3"];
    NSURL *soundUrl = [NSURL fileURLWithPath:path];

    
    NSError *error;
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    
    NSError *sessionAudioError = nil;
    
    [session setCategory:AVAudioSessionCategoryPlayback error:&sessionAudioError];
    
    _audioPlayer = [[AVAudioPlayer alloc]
                    initWithContentsOfURL:soundUrl
                    error:&error];
    if (error)
    {
        DLog(@"Error in audioPlayer: %@",
              [error localizedDescription]);
    } else {
        _audioPlayer.delegate = self;
        [_audioPlayer prepareToPlay];
        _audioPlayer.numberOfLoops = 1;
        
        [_audioPlayer play];
    }
    
    _notification = [CWStatusBarNotification new];
    
    [_notification displayNotificationWithMessage:[[userInfo objectForKey:@"title"]stringByAppendingString:@" 💨"]
                                       completion:nil];
    
    _notification.notificationStyle = CWNotificationStyleStatusBarNotification;

    _notification.notificationAnimationInStyle = CWNotificationAnimationStyleTop;
    _notification.notificationAnimationOutStyle = CWNotificationAnimationStyleTop;
    
    __weak typeof(self) weakSelf = self;
    _notification.notificationTappedBlock = ^(void){
        if (!weakSelf.notification.notificationIsDismissing) {
            [weakSelf.notification dismissNotification];
        }
    };
    
}

-(void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}

-(void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler
{
    PushNotificationMaster *pushMaster = [PushNotificationMaster new];
    
    if ([identifier isEqualToString:@"REFART"]) {
        NSString *userChannel = [userInfo objectForKey:@"senderId"];
        [pushMaster sendPushNotificationViaCloudCode:userChannel];
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
