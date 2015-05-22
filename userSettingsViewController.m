//
//  userSettingsViewController.m
//  H-ound
//
//  Created by Matteo Comisso on 10/07/14.
//  Copyright (c) 2014 Blue-Mate. All rights reserved.
//

#import "userSettingsViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <UIImage+BlurredFrame/UIImage+BlurredFrame.h>

#import "ViewController.h"

#import <NGAParallaxMotion/NGAParallaxMotion.h>
@interface userSettingsViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *profilePicture;
@property (strong, nonatomic) IBOutlet UILabel *profileName;
@property (strong, nonatomic) IBOutlet UILabel *profileSurname;

@end

@implementation userSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // NavigationBar
    self.navigationController.navigationBar.barTintColor = FlatSkyBlueDark;
    self.navigationController.navigationBar.tintColor = FlatWhite;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:FlatWhite}];
    self.navigationController.navigationBarHidden = NO;
    self.title = @"Profile";

    // Do any additional setup after loading the view.
    _profilePicture.layer.cornerRadius = 40.f;
    _profilePicture.layer.borderWidth = 3.f;
    _profilePicture.layer.borderColor = FlatSkyBlueDark.CGColor;
    _profilePicture.layer.masksToBounds = YES;
    
    _profilePicture.parallaxIntensity = 15.f;
    _profileSurname.parallaxIntensity = 10.f;
    _profileName.parallaxIntensity = 5.f;
    
    _profileName.text = [[PFUser currentUser]objectForKey:@"name"];
    _profileSurname.text = [[PFUser currentUser]objectForKey:@"surname"];
    
    [FBRequestConnection
     startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
         if (!error) {
             NSString *facebookId = [result objectForKey:@"id"];
             
             NSURL *profilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", facebookId]];

             [self.profilePicture sd_setImageWithURL:profilePictureURL
                               placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
         }
         else
         {
             DLog(@"userSettings: %@, %@", [error localizedDescription], [error localizedFailureReason]);
         }
     }];
    
    // Background setup
    self.view.backgroundColor = FlatSkyBlue;
}

- (IBAction)logout:(id)sender {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Logout" message:@"Are you sure?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *iamsure = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        [PFUser logOut];
        
        [self.tabBarController setSelectedIndex:0];
//        [self.navigationController popToRootViewControllerAnimated:YES];

    }];
    
    UIAlertAction *abort = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleDefault handler:nil];
    
    [alertController addAction:abort];
    [alertController addAction:iamsure];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
