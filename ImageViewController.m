//
//  ImageViewController.m
//  Ribbit
//
//  Created by Matthias Kempe on 2014-04-21.
//  Copyright (c) 2014 Matthias Kempe. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()

@end

@implementation ImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad]; // load image view property with the image
    PFFile *imageFile = [self.message objectForKey:@"file"]; //
    NSURL *imageFileUrl = [[NSURL alloc] initWithString:imageFile.url];
    NSData *imageData = [NSData dataWithContentsOfURL:imageFileUrl];
    self.imageView.image = [UIImage imageWithData:imageData];
    
    NSString *senderName = [self.message objectForKey:@"senderName"]; // Gets the name of the sender
    NSString *title = [NSString stringWithFormat:@"Sent from %@", senderName]; // creates the title "sent from (sender name)"
    self.navigationItem.title = title; // sets that title as the title of the navigation bar
}

- (void)viewDidAppear:(BOOL)animated {  // View did appear begins as soon as the view is actually first displayed to the user
    [super viewDidAppear:animated];
    
    if ([self respondsToSelector:@selector(timeout)]) {
    [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(timeout) userInfo:nil repeats:NO]; // This is the timer
    }
    else {
        NSLog(@"Error: Selector Missing");
    }
}

#pragma mark - Helper Methods

- (void)timeout {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
