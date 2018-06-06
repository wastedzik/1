//
//  ControlCenterViewController.m
//  Houdini
//
//  Created by Abraham Masri on 05/05/18.
//  Copyright © 2018 cheesecakeufo. All rights reserved.
//

#include "utilities.h"

#import <UIKit/UIKit.h>


@interface ControlCenterViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *applyButton;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;

@property (assign) BOOL shouldRespring;
@property NSMutableArray *control_center_modules_list;

@end

@implementation ControlCenterViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.control_center_modules_list = [[NSMutableArray alloc] init];
    
    
    // read the plist file --
    FILE *info_file;
    long plist_size;
    char *plist_contents;
    
    char *info_path = "/private/var/mobile/Library/ControlCenter/ModuleConfiguration.plist";
    int fd = chosen_strategy.strategy_open(info_path, O_RDONLY, 0);

    if (fd < 0)
        return;

    info_file = fdopen(fd, "r");

    fseek(info_file, 0, SEEK_END);
    plist_size = ftell(info_file);
    rewind(info_file);
    plist_contents = malloc(plist_size * (sizeof(char)));
    fread(plist_contents, sizeof(char), plist_size, info_file);

    close(fd);
    fclose(info_file);

    NSString *plist_string = [NSString stringWithFormat:@"%s", plist_contents];
    NSData *data = [plist_string dataUsingEncoding:NSUTF8StringEncoding];

    NSError *error;
    NSPropertyListFormat format;
    NSDictionary *dict = [NSPropertyListSerialization propertyListWithData:data options:kNilOptions format:&format error:&error];

    // get list of module identifiers
    if([dict objectForKey:@"module-identifiers"] != nil) {

        for(NSString *identifier in [dict valueForKeyPath:@"module-identifiers"]) {

            NSLog(@"module: %@", identifier);
            [self.control_center_modules_list addObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:identifier, @"identifier", identifier, @"value", nil]];
        }

    }
    
    [self.tableView setEditing:YES];
    [self.tableView reloadData];
    
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.control_center_modules_list count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"ControlCenterCell"];

    NSString *module_identifier = [(NSMutableDictionary *)[self.control_center_modules_list objectAtIndex:indexPath.row] objectForKey:@"value"];

    [cell.textLabel setText:module_identifier];

    return cell;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {

    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self.control_center_modules_list removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
        
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {

    NSString *module_identifier = self.control_center_modules_list[fromIndexPath.row];
    [self.control_center_modules_list removeObjectAtIndex:fromIndexPath.row];
    [self.control_center_modules_list insertObject:module_identifier atIndex:toIndexPath.row];

}

- (IBAction)addTapped:(id)sender {
    
    // add a fake blank row using the Camera module
    [self.control_center_modules_list addObject:[[NSMutableDictionary alloc] initWithObjectsAndKeys:@"com.apple.control-center.CameraModule", @"identifier", @"Blank Toggle", @"value", nil]];
    [self.tableView reloadData];

}


- (IBAction)applyTapped:(id)sender {

    if (!self.shouldRespring) {
    
        self.shouldRespring = YES;

        // save changes
        NSMutableDictionary *module_configuration_dict = [[NSMutableDictionary alloc] init];

        // convert the control_center_modules_list to a 'save-able' list
        NSMutableArray *saveable_list = [[NSMutableArray alloc] init];

        for(NSMutableDictionary *dict in self.control_center_modules_list)
            [saveable_list addObject:[dict objectForKey:@"identifier"]];

        [module_configuration_dict setObject:saveable_list forKey:@"module-identifiers"];

        // add version
        [module_configuration_dict setObject:@(1) forKey:@"version"];

        NSLog(@"%@", module_configuration_dict);

        // output path
        NSString *output_path = [NSString stringWithFormat:@"%@/ModuleConfiguration.plist", get_houdini_dir_for_path(@"ControlCenter")];

        [module_configuration_dict writeToFile:output_path atomically:YES];

        [self.applyButton setTitle:@"respring" forState:UIControlStateNormal];

        
        // a workaround to write the file before iOS overwrites it
        kill_springboard(SIGSTOP);

        copy_file(strdup([output_path UTF8String]), "/private/var/mobile/Library/ControlCenter/ModuleConfiguration.plist", MOBILE_UID, MOBILE_GID, 0644);

        copy_file("/private/var/mobile/Library/ControlCenter/_ModuleConfiguration.plist", "/private/var/mobile/Library/ControlCenter/ModuleConfiguration.plist", MOBILE_UID, MOBILE_GID, 0644);
        
        sleep(1);
        kill_springboard(SIGCONT);
        
        return;
    }
    
    kill_springboard(SIGKILL);
}


- (IBAction)dismissTapped:(id)sender {

    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
