//
//  WidgetsViewController.m
//  Houdini
//
//  Created by Abraham Masri on 12/02/18.
//  Copyright © 2018 cheesecakeufo. All rights reserved.
//

#include "utilities.h"
#include "package.h"
#include "apps_control.h"
#include "WidgetObject.h"
#include "PreviewWidgetViewController.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "UIImage+Private.h"


@interface WidgetsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UITableView *widgetsTableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UISwitch *widgetsEnabledSwitch;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;

@property NSMutableArray *widgets_list;
@property WidgetObject *selectedWidget;
@property int label_location;
@end


@interface WidgetCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@end

@implementation WidgetCell
@end


@implementation WidgetsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.widgets_list = [[NSMutableArray alloc] init];
    
    WidgetObject *the_time_is = [[WidgetObject alloc] init];
    the_time_is.beforeTime = @"the time is ";
    the_time_is.afterTime = @"";
    the_time_is.hourSize = 60;
    the_time_is.hourBold = YES;
    the_time_is.textSize = 30;
    the_time_is.textBold = NO;

    WidgetObject *just_time = [[WidgetObject alloc] init];
    just_time.beforeTime = @"";
    just_time.afterTime = @"";
    just_time.hourSize = 160;
    just_time.hourBold = NO;
    just_time.textSize = 0;
    
    // add to list
    [self.widgets_list addObject:the_time_is];
    [self.widgets_list addObject:just_time];

    [self didToggleEnable:self.widgetsEnabledSwitch];
    
    // refresh the table view
    [self.widgetsTableView reloadData];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.widgets_list count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    WidgetCell *cell = (WidgetCell *)[tableView dequeueReusableCellWithIdentifier:@"WidgetCell"];
    
    WidgetObject *widget = (WidgetObject *)[self.widgets_list objectAtIndex:indexPath.row];
    
    cell.timeLabel.text = [widget.beforeTime stringByAppendingString:[NSString stringWithFormat:@"12:04am %@", widget.afterTime]];
    
    return cell;
}


- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    
    WidgetObject *widget = (WidgetObject *)[self.widgets_list objectAtIndex:indexPath.row];
    
    
    PreviewWidgetViewController *previewWidgetViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PreviewWidgetViewController"];
    
    previewWidgetViewController.widget_object = widget;
    previewWidgetViewController.providesPresentationContextTransitionStyle = YES;
    previewWidgetViewController.definesPresentationContext = YES;
    [previewWidgetViewController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [self presentViewController:previewWidgetViewController animated:YES completion:nil];
    
    
    
}

- (IBAction)didToggleEnable:(id)sender {
    
    NSLog(@"%d", self.widgetsEnabledSwitch.on);
    if (self.widgetsEnabledSwitch.on) {
        self.widgetsTableView.alpha = 1;
        self.widgetsTableView.userInteractionEnabled = YES;
    } else {
        self.widgetsTableView.alpha = 0.4;
        self.widgetsTableView.userInteractionEnabled = NO;
    }
}

- (IBAction)applyTapped:(id)sender {
    

    
    // add the time on top of the image_view
    //UIFont * custom_font = [UIFont fontWithName:@"Helvetica Neue" size:12];


    return;
    

}


- (IBAction)dismissTapped:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end

