//
//  SignupViewController.h
//  Ribbit
//
//  Created by Matthias Kempe on 2014-04-03.
//  Copyright (c) 2014 Matthias Kempe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignupViewController : UIViewController 

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;

- (IBAction)signup:(id)sender;
- (IBAction)dismiss:(id)sender;


@end
