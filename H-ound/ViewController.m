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
    NSArray *permissionsArray = @[ @"user_about_me", @"user_location", @"user_friends"];
    
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
                    
                    [self setupInstallationToParse];
                }
                else
                {
                    //Error
                    NSLog(@"Error while registering with new user: %@ %@", [error localizedDescription], [error localizedFailureReason]);
                }
            }];
        }
        else
        {
            NSLog(@"[Login View Controller] Welcome back %@", user[@"name"]);
            [self setupInstallationToParse];
            [self performSegueWithIdentifier:@"loginComplete" sender:self];
        }
    }];
    
}

-(void)setupInstallationToParse
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    PFUser *user = [PFUser currentUser];
    
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
/*
// Issue a Facebook Graph API request to get your user's friend list
[FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
    if (!error) {
        // result will contain an array with your user's friends in the "data" key
        NSArray *friendObjects = [result objectForKey:@"data"];
        NSMutableArray *friendIds = [NSMutableArray arrayWithCapacity:friendObjects.count];
        // Create a list of friends' Facebook IDs
        for (NSDictionary *friendObject in friendObjects) {
            [friendIds addObject:[friendObject objectForKey:@"id"]];
        }
        
        // Construct a PFUser query that will find friends whose facebook ids
        // are contained in the current user's friend list.
        PFQuery *friendQuery = [PFUser query];
        [friendQuery whereKey:@"fbId" containedIn:friendIds];
        
        // findObjects will return a list of PFUsers that are friends
        // with the current user
        NSArray *friendUsers = [friendQuery findObjects];
    }*/


@end
