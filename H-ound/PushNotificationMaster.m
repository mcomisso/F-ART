//
//  PushNotificationMaster.m
//  H-ound Fart Ed.
//
//  Created by Matteo Comisso on 19/11/14.
//  Copyright (c) 2014 Blue-Mate. All rights reserved.
//

#import "PushNotificationMaster.h"
#import "CWStatusBarNotification.h"

@implementation PushNotificationMaster


-(void)sendPushNotificationToUserChannel:(NSString *)userChannel
{
    PFPush *sendPush = [[PFPush alloc]init];
    [sendPush setData:@{@"title": [[PFUser currentUser]objectForKey:@"name"],
                        @"alert":@"💨",
                        @"sound":@"fart.caf",
                        @"category":@"actionable",
                        @"senderId":[[NSString stringWithFormat:@"ch"]stringByAppendingString:[[PFUser currentUser] objectForKey:@"username"]]}];
    [sendPush setChannel:userChannel];
    
    //NSLog(@"Username: %@", usernameOfTouchedUser);
    [sendPush sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            
            NSArray *fartMessage = @[@"PROOOOT", @"Farted Sent!", @"Wow, that was huge.", @"You farted your friend"];
            int selector = arc4random() % [fartMessage count];
            
            NSLog(@"Push notification sent!");
            CWStatusBarNotification *statusBarNotification = [CWStatusBarNotification new];
            
            [statusBarNotification displayNotificationWithMessage:fartMessage[selector]
                                                  forDuration:1.5f];
        }
        else
        {
            NSLog(@"Errors while sending push: %@, %@", [error localizedDescription], [error localizedFailureReason]);
        }
    }];

}

@end