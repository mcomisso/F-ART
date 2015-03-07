//
//  PushNotificationMaster.h
//  H-ound Fart Ed.
//
//  Created by Matteo Comisso on 19/11/14.
//  Copyright (c) 2014 Blue-Mate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PushNotificationMaster : NSObject

/**
 Send a push notification to the selected target
 */
-(void)sendPushNotificationViaCloudCode:(NSString *)userTarget;

@end
