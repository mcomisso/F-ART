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

#import <NGAParallaxMotion/NGAParallaxMotion.h>

@interface userSettingsViewController ()
@property (strong, nonatomic) IBOutlet UISwitch *canReceiveNotifications;
@property (strong, nonatomic) IBOutlet UIImageView *profilePicture;
@property (strong, nonatomic) IBOutlet UIImageView *backgroundProfilePicture;
@property (strong, nonatomic) IBOutlet UILabel *profileName;
@property (strong, nonatomic) IBOutlet UILabel *profileSurname;
@property (strong, nonatomic) IBOutlet UIView *nameBackgroundView;

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
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation[@"canReceiveNotification"]) {
        _canReceiveNotifications.selected = YES;
    }else
    {
        _canReceiveNotifications.selected = NO;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _profilePicture.layer.cornerRadius = 40.f;
    _profilePicture.layer.borderWidth = 3.f;
    _profilePicture.layer.borderColor = [[UIColor flatAlizarinColor]CGColor];
    _profilePicture.layer.masksToBounds = YES;
    
    _nameBackgroundView.backgroundColor = [UIColor flatAlizarinColor];
    _backgroundProfilePicture.contentMode = UIViewContentModeScaleAspectFill;
    
    _profilePicture.parallaxIntensity = 15.f;
    _profileSurname.parallaxIntensity = 15.f;
    _profileName.parallaxIntensity = 15.f;
    _nameBackgroundView.parallaxIntensity = 15.f;
    
    _profileName.text = [[PFUser currentUser]objectForKey:@"name"];
    _profileSurname.text = [[PFUser currentUser]objectForKey:@"surname"];
    
    [FBRequestConnection
     startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
         if (!error) {
             NSString *facebookId = [result objectForKey:@"id"];
             
             NSURL *profilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", facebookId]];

             [self.profilePicture sd_setImageWithURL:profilePictureURL
                               placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
             [self.backgroundProfilePicture sd_setImageWithURL:profilePictureURL];
             self.backgroundProfilePicture.image = [self.backgroundProfilePicture.image applyBlurWithRadius:20.f tintColor:[UIColor clearColor] saturationDeltaFactor:1.f maskImage:nil atFrame:CGRectMake(0, 0, self.backgroundProfilePicture.image.size.width, self.backgroundProfilePicture.image.size.height)];
         }
         else
         {
             NSLog(@"userSettings: %@, %@", [error localizedDescription], [error localizedFailureReason]);
         }
     }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)toggleNotifications:(id)sender {
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
