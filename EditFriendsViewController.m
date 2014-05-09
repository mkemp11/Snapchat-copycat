//
//  EditFriendsViewController.m
//  Ribbit
//
//  Created by Matthias Kempe on 2014-04-07.
//  Copyright (c) 2014 Matthias Kempe. All rights reserved.
//

#import "EditFriendsViewController.h"
#import "MSCellAccessory.h"

@interface EditFriendsViewController ()

@end

@implementation EditFriendsViewController

UIColor *disclosureColor; //define the variable everywhere. global variable

- (void)viewDidLoad
{
    [super viewDidLoad];
    PFQuery *query = [PFUser query];
    [query orderByAscending:@"username"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
        else {
            self.allUsers = objects;
            [self.tableView reloadData];
        }
    }];
    
    self.currentUser = [PFUser currentUser];
    
    disclosureColor = [UIColor colorWithRed:0.553 green:0.439 blue:0.718 alpha:1]; //sets desired color of accessor
    
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
    return [self.allUsers count]; //Number of rows is number of users using Count method
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    PFUser *user = [self.allUsers objectAtIndex:indexPath.row];
    cell.textLabel.text = user.username;
    
    if ([self isFriend:user]){ //if user is a friend (custom method "isFriend")
        cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_CHECKMARK color:disclosureColor];
    }
    else{
        cell.accessoryView = nil;
    }
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableViewCell *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath // is called when a row in a table is tapped
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath: indexPath]; // reference to current tableview cell
    
    PFUser *user = [self.allUsers objectAtIndex:indexPath.row]; // get current user that corresponds to the current indexpath.row
    
    PFRelation *friendsRelation = [self.currentUser relationForKey:@"friendsRelation"]; //gets the relation for current user
    if([self isFriend:user]) {
        cell.accessoryView = nil;  // 1.remove the checkmark
       
        for (PFUser *friend in self.friends){ // this for loop runs through all objects in the friends array
                if([friend.objectId isEqualToString:user.objectId]){ //compares the passed in array with the array currently in edit friends
                    [self.friends removeObject:friend]; // deletes off friends list
                    break;
                }
        }
        
        [friendsRelation removeObject:user]; // removes object (user) (remove from relation)
    }
    
    else {
        cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_CHECKMARK color:disclosureColor];
        [self.friends addObject:user];
        [friendsRelation addObject:user];
    }
    [self.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) { //saves
        if (error) {
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }
        
    }];
}

#pragma mark - Helper methods
//pragma marks are specialised comments used for organization

-(BOOL)isFriend:(PFUser *)user{ //BOOL returns true or false
    for (PFUser *friend in self.friends){ // this for loop runs through all objects in the friends array
        if([friend.objectId isEqualToString:user.objectId]){ //compares the passed in array with the array currently in edit friends

            return YES;
        }
        
    }
    return NO;
}
@end
