//
//  FriendsViewController.m
//  Ribbit
//
//  Created by Matthias Kempe on 2014-04-09.
//  Copyright (c) 2014 Matthias Kempe. All rights reserved.
//

#import "FriendsViewController.h"
#import "EditFriendsViewController.h"
#import "GravatarUrlBuilder.h"


@interface FriendsViewController ()

@end

@implementation FriendsViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.friendsRelation = [[PFUser currentUser] objectForKey:@"friendsRelation"]; // goes to the relation "friendsRelation" within the curren user.
    
    PFQuery *query = [self.friendsRelation query];
    [query orderByAscending:@"username"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }
        else {
            self.friends = objects; // sets array "friends" to the objects in the table view
            [self.tableView reloadData];
        }
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{ // used to share data between view controllers (sends friends list to "edit friends". Prepares data for transition to next view controller
    if([segue.identifier isEqualToString:@"showEditFriends"]){ // this is in case there are different segues to this view controller. Makes sure that it is going through showEditFriends segue
        
        EditFriendsViewController *viewController = (EditFriendsViewController *)segue.destinationViewController; // if the segue is correct, then segue into editFriendsViewcontroller
        viewController.friends = [NSMutableArray arrayWithArray:self.friends]; // make a mutable array out of NSArray "friends"
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.friends count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell"; // do this manually!!
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    PFUser *user = [self.friends objectAtIndex:indexPath.row];
    cell.textLabel.text = user.username;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0); // this allows asynchrounous running in the Grand Central Dispatch (GCD)> this sets the priority (default)
    
    dispatch_async(queue, ^{
        
        NSString *email = [user objectForKey:@"email"];   // 1. get the email adress
        
        NSURL *gravatarUrl = [GravatarUrlBuilder getGravatarUrl:email];  // 2. create the md5 hash (use a value known as a public key to encrypt the email adress in a special format known as hash value.
        
        NSData *imageData = [NSData dataWithContentsOfURL:gravatarUrl]; // 3.request image from gravatar
        
        if (imageData != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            cell.imageView.image = [UIImage imageWithData:imageData]; // 4. set image in cell
            [cell setNeedsLayout];
        });
        }
        
    });
    
    cell.imageView.image = [UIImage imageNamed:@"icon_person"]; // make the icon the default image if no data is found from gravatar
    
    return cell;
}


@end
