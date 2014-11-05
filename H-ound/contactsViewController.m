//
//  contactsViewController.m
//  H-ound
//
//  Created by Matteo Comisso on 10/07/14.
//  Copyright (c) 2014 Blue-Mate. All rights reserved.
//

#import "contactsViewController.h"
#import "contactCellTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>


@interface contactsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *contacts;

@end

@implementation contactsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationController.navigationBarHidden = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.backgroundColor = [UIColor flatOrangeColor];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self fetchUsers];
}
- (IBAction)refreshTableButton:(id)sender {
    [self fetchUsers];
}

-(void)fetchUsers
{
    PFQuery *searchAllContactsOfHfarm = [PFUser query];
    searchAllContactsOfHfarm.cachePolicy = kPFCachePolicyNetworkElseCache;
    //    [searchAllContactsOfHfarm whereKey:@"objectId" notEqualTo:[PFUser currentUser].objectId];
    [searchAllContactsOfHfarm findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            //NSLog(@"%@", [objects[0] description]);
            _contacts = [NSMutableArray arrayWithArray:objects];
            [self.tableView reloadData];
        }
        else
        {
            NSLog(@"Description: %@, Failure: %@", [error localizedDescription], [error localizedFailureReason]);
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
    return [_contacts count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    
    contactCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    //Setup cell elemnents
    cell.statusOfUser.layer.cornerRadius = 5.f;
    
    if (cell == nil) {
        cell = [[contactCellTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:cellIdentifier];
    }
    
    //Set the content of every cell
    cell.backgroundColor = [UIColor flatPomegranateColor];
    cell.contactName.text = [[_contacts objectAtIndex:indexPath.row] objectForKey:@"name"];
    cell.contactImage.layer.cornerRadius = 10.f;
    cell.contactImage.layer.masksToBounds = YES;
    //    NSLog(@"%@", [[[_contacts objectAtIndex:indexPath.row] objectForKey:@"inside"] description]);
    if ([[_contacts objectAtIndex:indexPath.row] objectForKey:@"inside"]) {
        cell.statusOfUser.backgroundColor = [UIColor flatMidnightBlueColor];
        cell.statusOfUser.text = @"OUT";
    }
    else
    {
        cell.statusOfUser.backgroundColor = [UIColor flatEmeraldColor];
        cell.statusOfUser.text = @"IN";
    }
    
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

    PFUser *touchedUser = [_contacts objectAtIndex:indexPath.row];
    //Ha toccato una row @indexpath
    //Send notification to parse servers
    NSString *nameOfTouchedUser = [touchedUser objectForKey:@"name"];
    //NSString *usernameOfTouchedUser = [[_contacts objectAtIndex:indexPath.row]objectForKey:@"username"];
    
    NSString *userChannel = [@"ch" stringByAppendingString:[touchedUser objectForKey:@"username"]];
    NSLog(@"%@", userChannel);
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"user" equalTo:[touchedUser objectForKey:@"username"]];
    
    PFPush *sendPush = [[PFPush alloc]init];
    //    [sendPush setQuery:pushQuery];
    [sendPush setData:@{@"title": [[PFUser currentUser]objectForKey:@"name"],
                        @"alert":@"💨",
                        @"sound":@"fart.caf",
                        @"category":@"actionable",
                        @"senderId":[[NSString stringWithFormat:@"ch"]stringByAppendingString:[[PFUser currentUser] objectForKey:@"username"]],
                        @"t":@"m"}];
    //    [sendPush setMessage:[[PFUser currentUser]objectForKey:@"name"]];
    [sendPush setChannel:userChannel];
    
    //NSLog(@"Username: %@", usernameOfTouchedUser);
    [sendPush sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            NSLog(@"Push notification sent to: %@, %@", nameOfTouchedUser, userChannel);
        }
        else
        {
            NSLog(@"Errors while sending push: %@, %@", [error localizedDescription], [error localizedFailureReason]);
        }
    }];
    //Ogni user è un canale differente di push notification
    //Iscrivo gli utenti l'un l'altro
    
    /*
     PFQuery *pushQuery = [PFInstallation query];
     [pushQuery whereKey:@"injuryReports" equalTo:YES];
     
     // Send push notification to query
     PFPush *push = [[PFPush alloc] init];
     [push setQuery:pushQuery]; // Set our Installation query
     [push setMessage:@"Willie Hayes injured by own pop fly."];
     [push sendPushInBackground];
     */
    
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    CATransform3D rotation;
    rotation = CATransform3DMakeRotation((90.0*M_PI)/180, 0.0, 0.7, 0.4);
    rotation.m34 = 1.0/ -600;
    
    //Defining Initial state
    cell.layer.shadowColor = [[UIColor blackColor]CGColor];
    cell.layer.shadowOffset = CGSizeMake(10, 10);
    cell.alpha = 0;
    cell.layer.transform = rotation;
    cell.layer.anchorPoint = CGPointMake(0, 0.5);
    
    //Defining Final state
    [UIView beginAnimations:@"rotation" context:NULL];
    [UIView setAnimationDuration:0.8];
    cell.layer.transform = CATransform3DIdentity;
    cell.alpha = 1;
    cell.layer.shadowOffset = CGSizeMake(0, 0);
    
    [UIView commitAnimations];
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
