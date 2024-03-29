//
//  ViewController.m
//  H-ound
//
//  Created by Matteo Comisso on 10/07/14.
//  Copyright (c) 2014 Blue-Mate. All rights reserved.
//

#import "ViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SVProgressHUD/SVProgressHUD.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    
    [SVProgressHUD show];
    
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user, NSError *error) {
        //DLog(@"%@", [user description]);
        if (!user) {
            if (!error) {
                DLog(@"[Facebook utils] The user cancelled the Facebook login.");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:@"Uh oh. The user cancelled the Facebook login." delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            } else {
                DLog(@"[Facebook utils] An error occurred: %@", error);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Log In Error" message:[error description] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
        }
        else if (user.isNew)
        {
            DLog(@"user Signed up and logged through facebook");
            
            [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    //Saving data
                    user[@"facebookId"] = [result objectForKey:@"id"];
                    user[@"name"] = [result objectForKey:@"first_name"];
                    user[@"surname"] = [result objectForKey:@"last_name"];
                    user.email = [result objectForKey:@"email"];
                    [user saveInBackground];
                    
                    DLog(@"Signup user description: %@", [user description]);
                    
                    [self setupInstallationToParse];
                }
                else
                {
                    //Error
                    DLog(@"Error while registering with new user: %@ %@", [error localizedDescription], [error localizedFailureReason]);
                }
            }];
        }
        else
        {
            DLog(@"[Login View Controller] Welcome back %@", user[@"name"]);
            [self setupInstallationToParse];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    
    [SVProgressHUD dismiss];
    
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
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else
        {
            DLog(@"Error while saving installations: err %@, %@", [error localizedDescription], [error localizedFailureReason]);
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
