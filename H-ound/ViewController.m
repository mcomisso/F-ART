//
//  ViewController.m
//  H-ound
//
//  Created by Matteo Comisso on 10/07/14.
//  Copyright (c) 2014 Blue-Mate. All rights reserved.
//

#import "ViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    if ([PFUser currentUser]) {
        NSLog(@"[Login View Controller] Welcome back %@", [[PFUser currentUser] objectForKey:@"name"]);
        [self performSegueWithIdentifier:@"loginComplete" sender:self];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)facebookLoginButton {
    NSArray *permissionsArray = @[ @"user_about_me", @"user_location"];
    
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        //NSLog(@"%@", [user description]);
        if (!user) {
            if (!error) {
                NSLog(@"[Facebook utils] The user cancelled the Facebook login.");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"Uh oh. The user cancelled the Facebook login." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            } else {
                NSLog(@"[Facebook utils] An error occurred: %@", error);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
        }
        else if (user.isNew)
        {
            NSLog(@"user Signed up and logged through facebook");
            
            [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    //Saving data
                    user[@"facebookId"] = [result objectForKey:@"id"];
                    user[@"name"] = [result objectForKey:@"first_name"];
                    user[@"surname"] = [result objectForKey:@"last_name"];
                    user.email = [result objectForKey:@"email"];
                    [user saveInBackground];
                    
                    NSLog(@"Signup user description: %@", [user description]);

                    //Parse.com channels cannot start with a number
                    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                    currentInstallation[@"user"] = user;
                    NSString *channelUser = [@"ch" stringByAppendingString:user[@"username"]];
                    [currentInstallation addUniqueObject:channelUser forKey:@"channels"];
                    [currentInstallation addUniqueObject:@"all" forKey:@"channels"];
                    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        if (succeeded) {
                            [self performSegueWithIdentifier:@"loginComplete" sender:self];
                        }
                        else
                        {
                            NSLog(@"Error while saving installations: err %@, %@", [error localizedDescription], [error localizedFailureReason]);
                        }

                    }];
                }
                else
                {
                    //Error
                }
            }];
        }
        else
        {
            NSLog(@"[Login View Controller] Welcome back %@", user[@"name"]);
            [self performSegueWithIdentifier:@"loginComplete" sender:self];
        }
    }];
}

@end
