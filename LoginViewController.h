//
//  LoginViewController.h
//  Ribbit
//
//  Created by Matthias Kempe on 2014-04-03.
//  Copyright (c) 2014 Matthias Kempe. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoginViewController : UIViewController // <UITextFieldDelegate> // For making keyboard disappear

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

- (IBAction)login:(id)sender;


@end
