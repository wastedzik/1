//
//  BlankIconsViewController.m
//  Houdini
//
//  Created by Abraham Masri on 05/05/18.
//  Copyright © 2018 cheesecakeufo. All rights reserved.
//

#include "utilities.h"
#include "apps_control.h"

#import <UIKit/UIKit.h>


@interface BlankIconsViewController : UIViewController  <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UISegmentedControl *styleTypeSegment;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *hexInput;
@property (weak, nonatomic) IBOutlet UILabel *hexWarningLabel;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;

@property (nonatomic) UIImagePickerController *imagePickerController;

@property (assign) BOOL shouldRespring;
@property NSMutableArray *control_center_modules_list;
@property NSString *output_path;
@end

@implementation BlankIconsViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imagePickerController = [[UIImagePickerController alloc] init];
    self.imagePickerController.delegate = self;
    self.imagePickerController.allowsEditing = YES;
    self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    
    [self.hexInput addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}


-(void)textFieldDidChange :(UITextField *) textField{
    if(self.hexInput.text.length != 7 || ![self.hexInput.text containsString:@"#"]) {
        [self.addButton setEnabled:NO];
        [self.addButton setAlpha:0.3];
        return;
    }
    
    unsigned int rgb = 0;
    [[NSScanner scannerWithString:
      [[self.hexInput.text uppercaseString] stringByTrimmingCharactersInSet:
       [[NSCharacterSet characterSetWithCharactersInString:@"0123456789ABCDEF"] invertedSet]]]
     scanHexInt:&rgb];
    
    
    UIColor *color = [UIColor colorWithRed:((CGFloat)((rgb & 0xFF0000) >> 16)) / 255.0
                                     green:((CGFloat)((rgb & 0xFF00) >> 8)) / 255.0
                                      blue:((CGFloat)(rgb & 0xFF)) / 255.0
                                     alpha:1.0];
    
    self.imageView.image = nil;
    [self.imageView setBackgroundColor:color];
    
    [self.addButton setEnabled:YES];
    [self.addButton setAlpha:1.0];
    
    UIGraphicsBeginImageContext(self.imageView.bounds.size);
    [self.imageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *converted_image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    NSData *image_data = UIImagePNGRepresentation(converted_image);
    
    // save the image in our path then copy it
    self.output_path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:@"/icon.png"];
    [image_data writeToFile:self.output_path atomically:YES];
    
    
}


- (IBAction)styleTypeChanged:(id)sender {
    
    if (self.styleTypeSegment.selectedSegmentIndex == 0) { // color
        
        // show the hex entry
        self.hexInput.hidden = false;
        self.hexWarningLabel.hidden = false;
        
        
    } else { // image
        
        // hide the hex entry
        self.hexInput.hidden = true;
        self.hexWarningLabel.hidden = true;
        
        // show the image picker
        [self presentViewController:self.imagePickerController animated:YES completion:NULL];
    }
}

- (UIImage*)scaleImageToIcon: (UIImage*) sourceImage
{
    
    UIGraphicsBeginImageContext(CGSizeMake(162, 162));
    [sourceImage drawInRect:CGRectMake(0, 0, 162, 162)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    UIImage *image = chosenImage;
    
    // resize the image
    UIImage *new_image = [self scaleImageToIcon:image];
    
    // save the image
    self.output_path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:@"/icon.png"];
    
    NSData *imageData = UIImagePNGRepresentation(new_image);
    [imageData writeToFile:self.output_path atomically:YES];
    
    self.imageView.image = new_image;
    self.shouldRespring = true;
}

- (IBAction)addTapped:(id)sender {
    
    if(self.output_path.length <= 0) {
        show_alert(self, @"Oops", @"Please enter a color or an image first");
        return;
    }
    
    create_webclip(strdup([self.output_path UTF8String]), "", "");
}


- (IBAction)dismissTapped:(id)sender {

    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch * touch = [touches anyObject];
    if(touch.phase == UITouchPhaseBegan) {
        [self.hexInput resignFirstResponder];
    }
}

@end
