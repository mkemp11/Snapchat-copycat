//
//  LoginViewController.m
//  Ribbit
//
//  Created by Matthias Kempe on 2014-04-03.
//  Copyright (c) 2014 Matthias Kempe. All rights reserved.
//

#import "LoginViewController.h"
#import <Parse/Parse.h>

@interface LoginViewController ()

@end

@implementation LoginViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    /*if ([UIScreen mainScreen].bounds.size.height == 568) { // Check if the screen is a 4 inch display. (screen size)
        self.backgroundImageView.image = [UIImage imageNamed:@"loginBackground-568h"]; //then chose the 568 sized image
    }*/
    
    /*self.usernameField.delegate = self; //creates delegates
    self.passwordField.delegate = self; */
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setHidden:YES]; //Hides the navigation bar
}

- (IBAction)login:(id)sender {
        NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if ([username length] == 0 || [password length] == 0)  {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Make sure you enter a username and password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            
        }
    
        else{
            [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
                if (error) {
                    UIAlertView *alertView =[[UIAlertView alloc] initWithTitle:@"Sorry" message:[error.userInfo objectForKey:@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alertView show];
                }
                else{
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    
                }
            }];
        }

}


#pragma mark - UITextField delegate methods

/*- (BOOL)textFieldShouldReturn:(UITextField *)textField { //called when return key is hit when keyboard is showing for textfield
    [textField resignFirstResponder]; //text field is first responder of touch events. This makes the textfield no longer the first responder and keyboard is no longer needed. 
    return YES;
} */


@end