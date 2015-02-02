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
#import <GKBarGraph.h>
@interface userSettingsViewController () <GKBarGraphDataSource>

@property (strong, nonatomic) IBOutlet UIImageView *profilePicture;
@property (strong, nonatomic) IBOutlet UILabel *profileName;
@property (strong, nonatomic) IBOutlet UILabel *profileSurname;
@property (weak, nonatomic) IBOutlet GKBarGraph *barGraph;


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
    [self test];
    
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
             NSLog(@"userSettings: %@, %@", [error localizedDescription], [error localizedFailureReason]);
         }
     }];
    
    // Background setup
    self.view.backgroundColor = FlatSkyBlue;
    self.barGraph.backgroundColor = FlatSkyBlue;
    [self buildGraph];
}

-(void)test
{
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    NSDate *startOfTheWeek;
    NSDate *endOfWeek;
    NSTimeInterval interval;
    [cal rangeOfUnit:NSCalendarUnitWeekday
           startDate:&startOfTheWeek
            interval:&interval
             forDate:now];
    
    endOfWeek = [startOfTheWeek dateByAddingTimeInterval:interval-1];
    
    NSLog(@"Description %@", [cal description] );
    
    
}

-(void)buildGraph {
    self.barGraph.dataSource = self;
//    [self.barGraph draw];
}

- (IBAction)logout:(id)sender {
    [PFUser logOut];
    
    UIStoryboard *storyboard = [self storyboard];
    ViewController *loginViewController =
    [storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
    
    [self presentViewController:loginViewController
                       animated:YES
                     completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - BarGraphView
-(NSInteger)numberOfBars{
    return 7;
}

-(NSNumber *)valueForBarAtIndex:(NSInteger)index {
    return @2;
}

-(UIColor *)colorForBarAtIndex:(NSInteger)index {
    return FlatSkyBlue;
}

-(UIColor *)colorForBarBackgroundAtIndex:(NSInteger)index {
    return FlatSand;
}

-(NSString *)titleForBarAtIndex:(NSInteger)index {

    return @"lol";
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
