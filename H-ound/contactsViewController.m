//
//  contactsViewController.m
//  H-ound
//
//  Created by Matteo Comisso on 10/07/14.
//  Copyright (c) 2014 Blue-Mate. All rights reserved.
//

#import "contactsViewController.h"
#import "contactCellTableViewCell.h"
#import "shareTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

#import <CWStatusBarNotification/CWStatusBarNotification.h>

#import "PushNotificationMaster.h"


@interface contactsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *contacts;

@end

@implementation contactsViewController

- (void)viewDidLoad
{
    
    // TODO: Replace this test id with your personal ad unit id
    MPAdView* adView = [[MPAdView alloc] initWithAdUnitId:@"0fd404de447942edb7610228cb412614"
                                                     size:MOPUB_BANNER_SIZE];
    self.adView = adView;
    self.adView.delegate = self;
    self.adView.frame = CGRectMake(0, self.view.bounds.size.height - MOPUB_BANNER_SIZE.height,
                                   MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height);
    [self.view addSubview:self.adView];
    [self.adView loadAd];
    
    [super viewDidLoad];

    self.navigationController.navigationBarHidden = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.backgroundColor = [UIColor flatOrangeColor];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self requestMyFacebookFriends];
}

#pragma mark - <MPAdViewDelegate>
- (UIViewController *)viewControllerForPresentingModalView {
    return self;
}

- (IBAction)refreshTableButton:(id)sender {
    [self requestMyFacebookFriends];
}

-(void)requestMyFacebookFriends
{
    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            NSArray *friendsObject = [result objectForKey:@"data"];
            NSMutableArray *friendsIds = [NSMutableArray arrayWithCapacity:friendsObject.count];
            for (NSDictionary *friendObject in friendsObject) {
                [friendsIds addObject:[friendObject objectForKey:@"id"]];
            }
            PFQuery *searchAllContacts = [PFUser query];
            searchAllContacts.cachePolicy = kPFCachePolicyNetworkElseCache;
            [searchAllContacts whereKey:@"facebookId" containedIn:friendsIds];
            
            [searchAllContacts findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    //NSLog(@"%@", [objects[0] description]);
                    _contacts = [NSMutableArray arrayWithArray:objects];
                    [self.tableView reloadData];
                }
                else
                {
                    NSLog(@"Error while querying the database for matching friends. Description: %@, Failure: %@", [error localizedDescription], [error localizedFailureReason]);
                }
            }];
        }
        else
        {
            NSLog(@"You have no friends. %@ %@", [error localizedDescription], [error localizedFailureReason]);
        }

    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegates methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    if ([_contacts count] == 0) {
        return 1;
    }
    return [_contacts count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int tester = (int)[_contacts count];
    
    if (tester == 0) {
        static NSString *shareCellIdentifier = @"shareCellIdentifier";
        shareTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:shareCellIdentifier];
        
        if (cell == nil) {
            cell = [[shareTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:shareCellIdentifier];
        }
        
        return cell;
    }
    static NSString *cellIdentifier = @"cellIdentifier";
    contactCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[contactCellTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:cellIdentifier];
    }
    
    //Set the content of every cell
    cell.backgroundColor = [UIColor flatPomegranateColor];
    cell.contactName.text = [[_contacts objectAtIndex:indexPath.row] objectForKey:@"name"];
    cell.contactImage.layer.cornerRadius = 10.f;
    cell.contactImage.layer.masksToBounds = YES;
    
    [FBRequestConnection
     startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
         if (!error) {
             NSString *facebookId = [[_contacts objectAtIndex:indexPath.row]objectForKey:@"facebookId"];
             
             NSURL *profilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", facebookId]];
             
             [cell.contactImage sd_setImageWithURL:profilePictureURL
                                  placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
             
         }
         else
         {
             NSLog(@"userSettings: %@, %@", [error localizedDescription], [error localizedFailureReason]);
         }
     }];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PushNotificationMaster *pushMaster = [PushNotificationMaster new];
    
    PFUser *touchedUser = [_contacts objectAtIndex:indexPath.row];
    //Send notification to parse servers

    //Userchannel = "ch" + username
    NSString *userChannel = [@"ch" stringByAppendingString:[touchedUser objectForKey:@"username"]];

    [pushMaster sendPushNotificationToUserChannel:userChannel];
}


- (IBAction)requestInfoForUser:(id)sender {
    
}


/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

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
