//
//  FriendsViewController.h
//  Ribbit
//
//  Created by Matthias Kempe on 2014-04-09.
//  Copyright (c) 2014 Matthias Kempe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface FriendsViewController : UITableViewController

@property (nonatomic, strong) PFRelation *friendsRelation;
@property (nonatomic, strong) NSArray *friends;

@end
