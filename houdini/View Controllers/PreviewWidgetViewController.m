//
//  PreviewWidgetViewController.m
//  houdini
//
//  Created by Abraham Masri on 11/13/17.
//  Copyright © 2017 Abraham Masri. All rights reserved.
//

#import "PreviewWidgetViewController.h"

#include "apps_control.h"
#include "utilities.h"
#include "UIImage+Private.h"

@interface PreviewWidgetViewController ()

@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;

@property UIView *widgetView;
@property CGPoint lastLocation;

@end

@implementation PreviewWidgetViewController

@synthesize widget_object = _widget_object;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // add the current wallpaper
    NSString *cpbitmap_path = [NSString stringWithFormat:@"%@/%@", [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject], @"LockBackground.cpbitmap"];
    
    // copy the cpbitmap to our directory then open it
    copy_file("/var/mobile/Library/SpringBoard/LockBackground.cpbitmap", strdup([cpbitmap_path UTF8String]), MOBILE_UID, MOBILE_GID, 0644);

    UIImage *current_wallpaper_image = [UIImage imageWithContentsOfCPBitmapFile:cpbitmap_path flags:0];
    //UIImage *current_wallpaper_image = [[UIImage alloc] initWithData:get_saved_wallpaper()];
    
    self.imageView.image = current_wallpaper_image;

    // add the time label ---
    UILabel *time_label = [[UILabel alloc] init];
    time_label.userInteractionEnabled = YES;
    time_label.textColor = [UIColor whiteColor];
    time_label.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    
    UIFont *before_text_font;
    UIFont *after_text_font;
    if (self.widget_object.textBold) {
        
        before_text_font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:self.widget_object.textSize];
        after_text_font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:self.widget_object.textSize];
    } else {
        
        before_text_font = [UIFont fontWithName:@"HelveticaNeue" size:self.widget_object.textSize];
        after_text_font = [UIFont fontWithName:@"HelveticaNeue" size:self.widget_object.textSize];
    }
    
    
    UIFont *time_font;
    if (self.widget_object.hourBold) {
        
        time_font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:self.widget_object.hourSize];
    } else {
        
        time_font = [UIFont fontWithName:@"HelveticaNeue" size:self.widget_object.hourSize];
    }
    
    NSMutableAttributedString *before_text_attributed = [[NSMutableAttributedString alloc] initWithString:self.widget_object.beforeTime attributes:@{NSFontAttributeName : before_text_font }];
    
    // get the current hour
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"HH";
    
    NSString *hour = [timeFormatter stringFromDate: [NSDate date]];
    
    
    NSMutableAttributedString *time_attributed = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", hour] attributes:@{NSFontAttributeName : time_font }];
    
    NSMutableAttributedString *after_text_attributed = [[NSMutableAttributedString alloc] initWithString:self.widget_object.afterTime attributes:@{NSFontAttributeName : after_text_font }];
    
    
    [before_text_attributed appendAttributedString:time_attributed];
    [before_text_attributed appendAttributedString:after_text_attributed];
    
    time_label.attributedText = before_text_attributed;

    // center the label in the view
    time_label.center = self.view.center;
    
    // make the label draggable
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(detectPan:)];
    [time_label addGestureRecognizer:panRecognizer];
    
    self.widgetView = time_label;
    [self.previewView addSubview:time_label];
    
}
- (void) detectPan:(UIPanGestureRecognizer *) uiPanGestureRecognizer {
    CGPoint translation = [uiPanGestureRecognizer translationInView:self.previewView];
    self.widgetView.center = CGPointMake(self.widgetView.center.x + translation.x, self.widgetView.center.y + translation.y);
    
    [uiPanGestureRecognizer setTranslation:CGPointZero inView:self.previewView];
}

- (IBAction)actionButtonTapped:(id)sender {
    
    // removed temporarily
    
}

- (IBAction)dismissTapped:(id)sender {

    [self dismissViewControllerAnimated:YES completion:nil];

}

@end
