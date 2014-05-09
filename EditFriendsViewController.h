//
//  EditFriendsViewController.h
//  Ribbit
//
//  Created by Matthias Kempe on 2014-04-07.
//  Copyright (c) 2014 Matthias Kempe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface EditFriendsViewController : UITableViewController

@property (nonatomic, strong) NSArray *allUsers;
@property (nonatomic, strong) PFUser *currentUser;
@property (nonatomic, strong) NSMutableArray *friends; // is used to set the data (friends list)

-(BOOL)isFriend:(PFUser *)user;

@end
