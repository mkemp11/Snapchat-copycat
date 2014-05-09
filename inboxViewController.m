//
//  inboxViewController.m
//  Ribbit
//
//  Created by Matthias Kempe on 2014-04-03.
//  Copyright (c) 2014 Matthias Kempe. All rights reserved.
//

#import "inboxViewController.h"
#import "ImageViewController.h"
#import "MSCellAccessory.h"

@interface inboxViewController ()

@end

@implementation inboxViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    self.moviePlayer = [[MPMoviePlayerController alloc] init];
    
    PFUser *currentUser = [PFUser currentUser];
    
    /* NSString *title = currentUser.username;
    self.title = @"%d", title;*/
    
    if (currentUser){
        NSLog(@"Current User: %@", currentUser.username);
    }
    else{
        [self performSegueWithIdentifier:@"showLogin" sender:self];
    }
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    
    [self.refreshControl addTarget:self action:@selector(retrieveMessages) forControlEvents:UIControlEventValueChanged]; // this is important, it uses refresh control to call retrieve messages (gets new messages)
    
}



- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setHidden:NO];
    
    [self retrieveMessages];
    
      
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
    return [self.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    PFObject *message = [self.messages objectAtIndex:indexPath.row]; // get the message object that corresponds to this row at the indexpath
    cell.textLabel.text = [message objectForKey:@"senderName"];
    
    UIColor *disclosureColor = [UIColor colorWithRed:0.553 green:0.439 blue:0.718 alpha:1]; //sets desired color of accessory
    cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_DISCLOSURE_INDICATOR color:disclosureColor]; //give custom accessory
    
    NSString *fileType = [message objectForKey:@"fileType"]; // Get the file type
    if ([fileType isEqualToString:@"image"]) { // if file type is a picture
        cell.imageView.image = [UIImage imageNamed:@"icon_image"]; // put the image icon
    }
    else { // otherwise file is a video
        cell.imageView.image = [UIImage imageNamed:@"icon_video"]; // put the video icon
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedMessage = [self.messages objectAtIndex:indexPath.row]; // selects the tapped message and assigns it to selectedMessage
    NSString *fileType = [self.selectedMessage objectForKey:@"fileType"]; // Get the file type
    if ([fileType isEqualToString:@"image"]) { // if file type is a picture
        [self performSegueWithIdentifier:@"showImage" sender:self];
    }
    else { // otherwise file is a video
        PFFile *videoFile = [self.selectedMessage objectForKey:@"file"]; // Gets the file from the selected message
        NSURL *fileUrl = [NSURL URLWithString:videoFile.url]; // Get the url property (string)
        self.moviePlayer.contentURL = fileUrl; //set the url for the movie player
        [self.moviePlayer prepareToPlay]; // prepares the video for view
        [self.moviePlayer thumbnailImageAtTime:0 timeOption:MPMovieTimeOptionNearestKeyFrame];
        
        // Add it to the view controller so we can see it instead of creating a new view controller
        [self.view addSubview:self.moviePlayer.view];
        [self.moviePlayer setFullscreen:YES animated:YES]; // must be called after we add the view to our heriarchy. Otherwise wont work as exepcted
    }
    
    NSMutableArray *recipientIds = [NSMutableArray arrayWithArray:[self.selectedMessage objectForKey:@"recipientIds"]];//Now we want to delete the message
    NSLog(@"Recipients: %@", recipientIds); // log an array of all the recipients
    
    if ([recipientIds count] ==1) { // check how many recipients there are
        //Last recipient - delete
        [self.selectedMessage deleteInBackground];
    }
    else {
        //Remove the recipients and save it. We only want to remove the recipient, not the message, otherwise only one use will be able to look at it then message is deleted
        [recipientIds removeObject:[[PFUser currentUser] objectId]]; // removes current user from array
        [self.selectedMessage setObject:recipientIds forKey:@"recipientIds"];
        [self.selectedMessage saveInBackground];
    }
}

- (IBAction)logout:(id)sender {
    [PFUser logOut];
    [self performSegueWithIdentifier:@"showLogin" sender:self]; //when log out buttonis tapped, logs out user, then takes you to login page
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"showLogin"]){
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES]; //If you are in login screen, the bottom bar disappears
    }
    else if([segue.identifier isEqualToString:@"showImage"]) {               //If we are sequeing to the image view controller, then bottom bar disappears
        [segue.destinationViewController setHidesBottomBarWhenPushed:YES]; //If viewing image, the bottom bar dissappears
        ImageViewController *imageViewController =(ImageViewController *)segue.destinationViewController;
        imageViewController.message = self.selectedMessage;
        
    }
}

#pragma mark - Helper Methods

- (void)retrieveMessages {
    PFQuery *query = [PFQuery queryWithClassName:@"Messages"]; // this query (named query) is linked to class messages
    [query whereKey:@"recipientIds" equalTo:[[PFUser currentUser] objectId]]; // looks for equal objects in the recipients field and the current userID
    [query orderByDescending:@"createdAt"]; // in order of creation day. Query is now set, and now need to execute
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) { // puts matches in the "objects" array
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        else {
            //We Found messages
            self.messages = objects; //objects into messages arrary
            [self.tableView reloadData]; // reload tableview
            NSLog(@"Retrieved %d messages", [self.messages count]); // %d is for an integer. This counts number of messages there are for the currentuser
            
        }
        
        if ([self.refreshControl isRefreshing]) {  //sees if it is refreshing
            [self.refreshControl endRefreshing];   // if it is, then end refreshing. this goes after all the data was pulled form parse so you don't stop the refresh while data is being pulled
        }
    }];
}

@end
