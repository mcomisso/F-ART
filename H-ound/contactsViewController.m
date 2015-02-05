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


@interface contactsViewController () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *contacts;
@property (nonatomic, strong) NSMutableArray *contactsImages;

@property (nonatomic, strong) NSArray *availableColours;

@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end

@implementation contactsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // TODO: Replace this test id with your personal ad unit id
    MPAdView* adView = [[MPAdView alloc] initWithAdUnitId:@"0fd404de447942edb7610228cb412614"
                                                     size:MOPUB_BANNER_SIZE];
    self.adView = adView;
    self.adView.delegate = self;
    self.adView.frame = CGRectMake(0, self.view.frame.size.height - MOPUB_BANNER_SIZE.height,
                                   MOPUB_BANNER_SIZE.width, MOPUB_BANNER_SIZE.height);
    [self.view addSubview:self.adView];
    [self.adView loadAd];

    self.navigationController.navigationBar.barTintColor = FlatSkyBlueDark;
    self.navigationController.navigationBar.tintColor = FlatWhite;
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:FlatWhite}];

    [[UIApplication sharedApplication]setStatusBarStyle:StatusBarContrastColorOf(FlatSkyBlueDark) animated:YES];
    
    _availableColours = ColorScheme(ColorSchemeComplementary, FlatSkyBlueDark, YES);

    self.navigationController.navigationBarHidden = NO;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    self.tableView.backgroundColor = FlatSkyBlue;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // Attach long press gesture recogniz
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 1.5;
    lpgr.delegate = self;
    [self.tableView addGestureRecognizer:lpgr];
    
    _refreshControl = [[UIRefreshControl alloc]init];
    _refreshControl.tintColor = FlatWhite;
    [self.tableView addSubview:_refreshControl];
    [_refreshControl addTarget:self action:@selector(refreshTableButton:) forControlEvents:UIControlEventValueChanged];
    
    //Request facebook friends
    [self requestMyFacebookFriends];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([PFUser currentUser] == nil) {
        [self performSegueWithIdentifier:@"registerSegue" sender:self];
    }
}

#pragma mark - <MPAdViewDelegate>
- (UIViewController *)viewControllerForPresentingModalView {
    return self;
}

#pragma mark - Images
-(void)loadImagesOfContacts
{
    //TODO: cache images of contacts ¿@{ID:photoid}?
}

- (void)refreshTableButton:(id)sender {
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
                [[PFUser currentUser]addUniqueObject:[friendObject objectForKey:@"id"] forKey:@"facebookFriends"];
            }
            
            [[PFUser currentUser]saveEventually];
            
            PFQuery *searchAllContacts = [PFUser query];
            searchAllContacts.cachePolicy = kPFCachePolicyNetworkElseCache;
            [searchAllContacts whereKey:@"facebookId" containedIn:friendsIds];
            
            [searchAllContacts findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error) {
                    //NSLog(@"%@", [objects[0] description]);
                    _contacts = [NSMutableArray arrayWithArray:objects];
                    [self loadImagesOfContacts];
                    
                    [self.refreshControl endRefreshing];
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

-(void)picturesDownloader
{
    
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
    return _contacts.count + 1;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[contactCellTableViewCell class]]) {
        
        int selector = arc4random() % [_availableColours count];
        
        contactCellTableViewCell *contactCell = (contactCellTableViewCell *) cell;
        contactCell.contentView.backgroundColor = _availableColours[selector];
        
        contactCell.contactName.textColor = ContrastColorOf(contactCell.contentView.backgroundColor, YES);
        contactCell.contactLastName.textColor = ContrastColorOf(contactCell.contentView.backgroundColor, YES);
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _contacts.count) {
        static NSString *shareCellIdentifier = @"shareCellIdenfifier";
        shareTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:shareCellIdentifier];
        
        cell.contentView.backgroundColor = ClearColor;
        cell.backgroundColor = ClearColor;
        
        if (cell == nil) {
            cell = [[shareTableViewCell alloc]initWithFrame:CGRectZero];
        }
        if (_contacts.count == 0) {
            cell.labelText.text = @"You have no friends here. Tap to share and fart'em all!";
        }
        else
        {
            cell.labelText.text = @"Tap to share!";
        }

        
        return cell;
    }
    else
    {
        static NSString *cellIdentifier = @"cellIdentifier";
        contactCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        
        if (cell == nil) {
            cell = [[contactCellTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
                                                  reuseIdentifier:cellIdentifier];
        }
        
        //Set the content of every cell
    
        cell.contactName.text = [[[_contacts objectAtIndex:indexPath.row] objectForKey:@"name"] uppercaseString];
        cell.contactLastName.text = [[_contacts objectAtIndex:indexPath.row] objectForKey:@"surname"];

        cell.contactImage.layer.cornerRadius = 10.f;
        cell.contactImage.layer.masksToBounds = YES;
        
        [FBRequestConnection
         startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
             if (!error) {
                 NSString *facebookId = [[_contacts objectAtIndex:indexPath.row]objectForKey:@"facebookId"];
                 
                 NSURL *profilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", facebookId]];
                 
                 cell.contactImage.contentMode = UIViewContentModeScaleAspectFill;
                 cell.contactImage.clipsToBounds = YES;
                 
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
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == _contacts.count) {
        NSLog(@"Share visual");
        NSString *shareString = [NSString stringWithFormat:@"Let's fart together!"];
        NSArray *shareContent = @[shareString];
        
        NSArray *excludedActivities = @[UIActivityTypeAddToReadingList,
                                        UIActivityTypeAirDrop,
                                        UIActivityTypeAssignToContact,
                                        UIActivityTypeCopyToPasteboard,
                                        UIActivityTypeMail,
                                        UIActivityTypePostToFlickr,
                                        UIActivityTypePostToVimeo,
                                        UIActivityTypePrint,
                                        UIActivityTypeSaveToCameraRoll];
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc]initWithActivityItems:shareContent applicationActivities:nil];
        
        activityViewController.excludedActivityTypes = excludedActivities;
        
        [self presentViewController:activityViewController animated:YES completion:nil];
        
    }
    else
    {
        PushNotificationMaster *pushMaster = [PushNotificationMaster new];
        
        PFUser *touchedUser = [_contacts objectAtIndex:indexPath.row];
        //Send notification to parse servers
        
        //Userchannel = "ch" + username
        NSString *userChannel = [@"ch" stringByAppendingString:[touchedUser objectForKey:@"username"]];
        
        [pushMaster sendPushNotificationToUserChannel:userChannel];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _contacts.count)
    {
        NSLog(@"Can't do anything here");
    } else {
        
    }
}

/**
 Long press
 */
-(void)handleLongPress:(UILongPressGestureRecognizer *)longPressGesture
{
    CGPoint p = [longPressGesture locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:p];
    
    if (indexPath == nil) {
        NSLog(@"Pressed outside the rows");
    } else if(longPressGesture.state == UIGestureRecognizerStateBegan) {
        NSLog(@"Indexpath pressed = %@", [indexPath description]);
    } else {
        NSLog(@"Gesture recognizer state: %ld", longPressGesture.state);
    }
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
