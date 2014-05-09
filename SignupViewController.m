//
//  SignupViewController.m
//  Ribbit
//
//  Created by Matthias Kempe on 2014-04-03.
//  Copyright (c) 2014 Matthias Kempe. All rights reserved.
//

#import "SignupViewController.h"
#import <Parse/Parse.h>

@interface SignupViewController ()

@end

@implementation SignupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    /*if ([UIScreen mainScreen].bounds.size.height == 568) { // Check if the screen is a 4 inch display. (screen size)
        self.backgroundImageView.image = [UIImage imageNamed:@"loginBackground-568h"]; //then chose the 568 sized image
    }*/
    
   }


- (IBAction)signup:(id)sender {
    NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *email = [self.emailField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; // trims white edges around text field (space bar)
  if ([username length] == 0 || [password length] == 0 || [email length] == 0) {
      UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Make sure you enter a username, password and email address!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
      [alertView show];
      
  }
  else{
      PFUser *newUser = [PFUser user]; // method to create new PFuser object and put information in th object
          newUser.username = username;
          newUser.password = password;
          newUser.email = email;
      
      [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
          if (error) {
              UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:@"Sorry" message:[error.userInfo objectForKey:@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
              [alertView show];
          }
          else{
              [self.navigationController popToRootViewControllerAnimated: YES]; //Takes to inbox view contorller
          }
      }];
      
      // more sequencial code that runs right away!
      
  }
}

- (IBAction)dismiss:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}




@end

