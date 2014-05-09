//
//  ImageViewController.h
//  Ribbit
//
//  Created by Matthias Kempe on 2014-04-21.
//  Copyright (c) 2014 Matthias Kempe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface ImageViewController : UIViewController

@property (nonatomic, strong) PFObject *message;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
