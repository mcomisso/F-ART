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
#import <GKLineGraph.h>
@interface userSettingsViewController () <GKLineGraphDataSource>

@property (strong, nonatomic) IBOutlet UIImageView *profilePicture;
@property (strong, nonatomic) IBOutlet UILabel *profileName;
@property (strong, nonatomic) IBOutlet UILabel *profileSurname;
@property (weak, nonatomic) IBOutlet GKLineGraph *barGraph;

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
             DLog(@"userSettings: %@, %@", [error localizedDescription], [error localizedFailureReason]);
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
    
    DLog(@"Description %@", [cal description] );
    
    
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

-(NSInteger)numberOfLines
{
    return 2;
}

-(UIColor *)colorForLineAtIndex:(NSInteger)index
{
    if ((index % 2) == 0) {
        return FlatWatermelonDark;
    }
    else {
        return FlatYellowDark;
    }
}

-(NSArray *)valuesForLineAtIndex:(NSInteger)index
{
    
    NSArray *data = @[
  @[@20, @40, @20, @60, @40, @140, @80],
  @[@40, @20, @60, @100, @60, @20, @60],
  @[@80, @60, @40, @160, @100, @40, @110],
  @[@120, @150, @80, @120, @140, @100, @0],
  ];
    NSArray *labels = @[@"2001", @"2002", @"2003", @"2004", @"2005", @"2006", @"2007"];

    return data;
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
