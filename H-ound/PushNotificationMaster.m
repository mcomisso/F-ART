//
//  PushNotificationMaster.m
//  H-ound Fart Ed.
//
//  Created by Matteo Comisso on 19/11/14.
//  Copyright (c) 2014 Blue-Mate. All rights reserved.
//

#import "PushNotificationMaster.h"
#import "CWStatusBarNotification.h"

@interface PushNotificationMaster()

@property (nonatomic, strong) NSArray *fartMessage;

@end

@implementation PushNotificationMaster

-(void)sendPushNotificationToUserChannel:(NSString *)userChannel
{
    PFPush *sendPush = [[PFPush alloc]init];
    
    NSString *alert = [[@"" stringByAppendingString:[[PFUser currentUser]objectForKey:@"name"]]stringByAppendingString:@" 💨"];
    
    [sendPush setData:@{@"title": [[PFUser currentUser]objectForKey:@"name"],
                        @"alert":alert,
                        @"sound":@"fart.caf",
                        @"category":@"actionable",
                        @"senderId":[[NSString stringWithFormat:@"ch"]stringByAppendingString:[[PFUser currentUser] objectForKey:@"username"]]}];
    [sendPush setChannel:userChannel];
    
    //NSLog(@"Username: %@", usernameOfTouchedUser);
    [sendPush sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSArray *fartMessage = @[@"PROOOOT",
                                     @"Farted Sent!",
                                     @"Wow, that was huge.",
                                     @"You farted your friend"];
            
            int selector = arc4random() % [fartMessage count];
            
            NSLog(@"Push notification sent!");
            CWStatusBarNotification *statusBarNotification = [CWStatusBarNotification new];
            
            [statusBarNotification displayNotificationWithMessage:fartMessage[selector]
                                                  forDuration:1.5f];
            
            [self increaseCounterOfSentFarts];
        }
        else
        {
            NSLog(@"Errors while sending push: %@, %@", [error localizedDescription], [error localizedFailureReason]);
        }
    }];
}

-(void)sendPushNotificationViaCloudCode:(NSString *)userTarget
{
    [PFCloud callFunctionInBackground:@"sendPushToUser"
                       withParameters:@{@"targetID":userTarget}
                                block:^(id object, NSError *error) {
        if (!error) {
            // Push was successfully sent
            NSArray *fartMessage = @[@"PROOOOT",
                                     @"Farted Sent!",
                                     @"Wow, that was huge.",
                                     @"You farted your friend"];
            
            int selector = arc4random() % [fartMessage count];
            
            DLog(@"Push notification sent!");
            CWStatusBarNotification *statusBarNotification = [CWStatusBarNotification new];
            
            [statusBarNotification displayNotificationWithMessage:fartMessage[selector]
                                                      forDuration:1.5f];
            
        } else {
            DLog(@"Error with %@ | %@", [error localizedDescription], [error localizedFailureReason]);
        }
    }];
}

#pragma mark - self user defaults
-(void)increaseCounterOfSentFarts
{
    NSUserDefaults *sharedDefaults = [[NSUserDefaults alloc]initWithSuiteName:@"group.com.matcom.fartdefaults"];
    NSInteger actualCounter = [sharedDefaults integerForKey:@""];
    DLog(@"%ld", (long)actualCounter);
}

@end
