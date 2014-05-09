//
//  CameraViewController.m
//  Ribbit
//
//  Created by Matthias Kempe on 2014-04-11.
//  Copyright (c) 2014 Matthias Kempe. All rights reserved.
//

#import "CameraViewController.h"
#import <MobileCoreServices/UTCoreTypes.h> // media types are stored as constants in this library
#import "MSCellAccessory.h"

@interface CameraViewController ()

@end

@implementation CameraViewController

UIColor *disclosureColor;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.recipients = [[NSMutableArray alloc] init];
    
    disclosureColor = [UIColor colorWithRed:0.553 green:0.439 blue:0.718 alpha:1]; //sets desired color of accessory
}

- (void)viewWillAppear:(BOOL)animated // Is called when user goes back into the camera view controller. If tapped a second time, viewdidload will not run. this is why viewwillappear is run before viewdidappear (just copy pasted everything from viewdidload to run same things)
{
    [super viewWillAppear:animated];
    
    self.friendsRelation = [[PFUser currentUser] objectForKey:@"friendsRelation"]; // goes to the relation "friendsRelation" within the curren user.
    PFQuery *query = [self.friendsRelation query];
    [query orderByAscending:@"username"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error){
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }
        else {
            self.friends = objects; // sets array "friends" to the objects in the table view
            [self.tableView reloadData];
        }
    }];
    
    if (self.image == nil && [self.videoFilePath length] ==0) {
        self.imagePicker = [[UIImagePickerController alloc] init]; // allocate and initialise image picker controller
        self.imagePicker.delegate = self; // tell new image picker that camerviewcontroller is its delegate
        self.imagePicker.videoMaximumDuration = 10;


        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){ //Checks if camera is available on phone
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera; //if yes, go to camera
            self.imagePicker.allowsEditing = NO; // does not allow editing of picture or movie
        }
        else{
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; // otherwise they chose a photo from library
        }

        self.imagePicker.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:self.imagePicker.sourceType]; // set media types. This is a method from uipickercontroller

        [self presentViewController:self.imagePicker animated:NO completion:nil]; //this presents the view controller. don't want animated because then user will see viewcontroller in background, adn completion is for something to run when it's over.
    }
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
    return [self.friends count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath //is called to see what data is stored in cell
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    PFUser *user = [self.friends objectAtIndex:indexPath.row];
    cell.textLabel.text = user.username;
    
    if([self.recipients containsObject:user.objectId]) {  //returns true if the object passed in is somewhere in the array. otherwise returns false. We are checking ID's
        cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_CHECKMARK color:disclosureColor];
    }
    else {
        cell.accessoryView = nil;
    }
    
    return cell;
}


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath  //is called when a cell is tapped
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO]; //unhighlights cell after its tapped
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath]; // activates tapped cell so we can set the check mark
    PFUser *user = [self.friends objectAtIndex:indexPath.row];
    
    if (cell.accessoryView == nil) {
        cell.accessoryView = [MSCellAccessory accessoryWithType:FLAT_CHECKMARK color:disclosureColor]; // if has no check mark, put a check mark
        [self.recipients addObject:user.objectId]; //puts the user object into the recipeints array
    }
    else {
        cell.accessoryView = nil; // if has checkmark, change to no checkmark
        [self.recipients removeObject:user.objectId];
    }

}

#pragma mark - Image Picker Controller delegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker { // used to do something after a photo is selected or cancel
    [self dismissViewControllerAnimated:NO completion:nil]; // what happens when view controller is left
    
    [self.tabBarController setSelectedIndex:0]; // goes to inbox tab (first tab is 0)
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info  //Is called if user did in fact select a picture or movie
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType]; // Checks for the media type (photo or video)
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]){ // Means a PHOTO was taken or selected. Have to convert CoreType to NSString counterpart
        self.image = [info objectForKey:UIImagePickerControllerOriginalImage]; //gives the image (named image) the picture that was taken or selected
        if(self.imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) { //quick check to see if the camera was used becuase we don't want to re-save pictures taken from album
            UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil); // save to photo library
        }
        
        
    }
    else { //Else, means a video was taken or chosen
        self.videoFilePath = (__bridge NSString *)([[info objectForKey:UIImagePickerControllerMediaURL] path]);
        if(self.imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) { //quick check to see if the camera was used becuase we don't want to re-save videos taken from album
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(self.videoFilePath)){ // recommended check to see if video is saveable to library (Apple recommended)
                UISaveVideoAtPathToSavedPhotosAlbum(self.videoFilePath, nil, nil, nil); //save to video library
            }
        
        }
        
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark IBActions


- (IBAction)cancel:(id)sender { // was a "Bar Button Item"
    [self reset]; // removes checks from all recipients
    
    [self.tabBarController setSelectedIndex:0]; // take back to inbox tab
    
}

- (IBAction)send:(id)sender {
    if (self.image == nil && [self.videoFilePath length] == 0) { // checks if a video or picture was actucally picked or captured
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Try Again!" message:@"Please Capture or select a photo or video to share!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil]; //error message if not
        [alertView show];
        [self presentViewController:self.imagePicker animated:NO completion:nil]; // takes you back to the imagePicker view controller
    }
    else { // means we can send it
        [self uploadMessage];
        
        [self.tabBarController setSelectedIndex:0];
    }
}

#pragma mark - Helper methods

- (void)uploadMessage {
    NSData *fileData;   // from parse. shows how to send data to backend
    NSString *fileName;
    NSString *fileType;
    
    if (self.image !=nil) { //Check if image
        UIImage *newImage = [self resizeImage:self.image toWidth:321.0f andHeight:480.0f]; // these are the dimensions of the old iphone (.0f for float) (shrink the image)
        fileData = UIImagePNGRepresentation(newImage); // Data is of PNG type. PNG can hold jpg type, but not vise versa
        fileName = @"image.png"; // Name of file must have extension
        fileType = @"image"; //type is image
    }
    else {
        fileData = [NSData dataWithContentsOfFile:self.videoFilePath]; // data of video type
        fileName = @"video.mov";
        fileType = @"video";
    }
    
    PFFile *file = [PFFile fileWithName:fileName data:fileData]; // creates the PFFile
    [file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) { // File is uploaded, and when it succeeds or fails, block is called
        
        if (error) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An Error Occured" message:@"Please try sending your message again!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil]; //error message if not
            [alertView show];
        }
        else {
            PFObject *message = [PFObject objectWithClassName:@"Messages"]; //Class name is name we will use to refer to these types of objects (Table name). Creates the message
            [message setObject:file forKey:@"file"];
            [message setObject:fileType forKey:@"fileType"];
            [message setObject:self.recipients forKey:@"recipientIds"];
            [message setObject:[[PFUser currentUser]  objectId] forKey:@"senderId"];
            [message setObject:[[PFUser currentUser] username] forKey:@"senderName"];
            [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"An Error Occured" message:@"Please try sending your message again!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil]; //error message if not
                    [alertView show];
                }
                else {
                    [self reset]; // everything was successful and resets the contacts viewcontroller to no checkmarks. GOod becuase if it fails, then the image and contacts aren't reset and you can send again without having to re-select recipients
                }
            }];
            
        }
    }];
 
}

- (void)reset {
    self.image = nil; // resets the image to have non selected
    self.videoFilePath = nil; // resets the video to have non selected
    [self.recipients removeAllObjects];
}

- (UIImage *)resizeImage:(UIImage *)image toWidth:(float)width andHeight:(float)height{ // resize the image
    CGSize newSize = CGSizeMake(width, height); // defines rectangle used as the size of new image (CG = Core Graphics)
    CGRect newRectangle = CGRectMake(0, 0, width, height); // creates a rectangle with those dimensions
    UIGraphicsBeginImageContext(newSize); //
    [self.image drawInRect:newRectangle]; // send message to image property
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext(); //capture it and store it in a new separate UIImage variable
    UIGraphicsEndImageContext(); //Always have to end when you begin (line 196)
    
    return resizedImage;
}

@end
