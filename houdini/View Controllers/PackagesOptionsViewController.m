//
//  PackagesOptionsViewController.m
//  Houdini
//
//  Created by Abraham Masri on 11/22/17.
//  Copyright © 2017 cheesecakeufo. All rights reserved.
//

#include "task_ports.h"
#include "triple_fetch_remote_call.h"
#include "apps_control.h"
#include "utilities.h"

#include <sys/param.h>
#include <sys/mount.h>

#import <UIKit/UIKit.h>


@interface PackagesOptionsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *uninstallTweaksButton;
@property (weak, nonatomic) IBOutlet UIButton *removeThemeButton;
@property (weak, nonatomic) IBOutlet UIButton *installDeb;
@property (weak, nonatomic) IBOutlet UIButton *removeMyAnimmojiButton;
@property (weak, nonatomic) IBOutlet UIButton *removeHoudiniButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicatorView;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;

@end

@implementation PackagesOptionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)uninstallTweaksTapped:(id)sender {
    
    [self.statusLabel setText:@"uninstalling tweaks.."];
    [self.uninstallTweaksButton setHidden:YES];
    [self.installDeb setHidden:YES];
    [self.removeThemeButton setHidden:YES];
    [self.dismissButton setHidden:YES];
    [self.loadingIndicatorView setHidden:NO];
    [self.loadingIndicatorView startAnimating];
    
}


- (IBAction)removeThemeTapped:(id)sender {
    
    [self.statusLabel setText:@"removing theme.."];
    [self.installDeb setHidden:YES];
    [self.removeMyAnimmojiButton setHidden:YES];
    [self.removeThemeButton setHidden:YES];
    [self.removeHoudiniButton setHidden:YES];
    [self.dismissButton setHidden:YES];
    [self.loadingIndicatorView setHidden:NO];
    [self.loadingIndicatorView startAnimating];
    
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(startRemovingTheme:) userInfo:nil repeats:NO];
    
}
- (IBAction)installDebTapped:(id)sender {
    
    UIViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"InstallDebViewController"];
    viewController.providesPresentationContextTransitionStyle = YES;
    viewController.definesPresentationContext = YES;
    [viewController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [self presentViewController:viewController animated:YES completion:nil];
    
}

- (void) startRemovingTheme:(NSTimer*)t {

    
    extern NSMutableDictionary *all_apps;
    if(all_apps == NULL) {
        printf("[INFO]: refreshing apps list..\n");
        list_applications_installed();
    }
    
    
    // start reverting back to original
    for (NSString* uuid in all_apps) {
        NSMutableDictionary *app_dict = [all_apps objectForKey:uuid];
        
        if ([[app_dict objectForKey:@"valid"]  isEqual: @YES]) {
            
            if ([app_dict objectForKey:@"identifier"] == nil) {
                continue;
            }
            
            printf("[INFO]: reverting to original theme for %s\n", strdup([[app_dict objectForKey:@"raw_display_name"] UTF8String]));
            
            // revert to the original icons first
            revert_theme_to_original(strdup([[app_dict objectForKey:@"app_path"] UTF8String]), true);
            
            
            // invalidate cache
            invalidate_icon_cache(strdup([[app_dict objectForKey:@"identifier"] UTF8String]));
        }
    }
    
    [self.statusLabel setText:@"respringing.."];
    
    printf("[INFO]: finished removing theme. clearing UI cache and respringing..\n");
    uicache();

}

- (void) removeAnimoji {
    
    
    // remove the thumbnail first
    chosen_strategy.strategy_unlink("/System/Library/PrivateFrameworks/AvatarKit.framework/thumbnails/customanimoji.png");
    
    // iterate through the directory and remove its contents
    char *path = "/System/Library/PrivateFrameworks/AvatarKit.framework/puppets/customanimoji";
    
    DIR *target_dir;
    struct dirent *file;
    
    int fd = chosen_strategy.strategy_open(path, O_RDONLY, 0);
    
    if (fd >= 0) {
        
        target_dir = fdopendir(fd);
        while((file = readdir(target_dir)) != NULL) {
            
            NSString *file_name = [NSString stringWithFormat:@"%s", strdup(file->d_name)];
            
            NSString *full_path = [NSString stringWithFormat:@"%s/%@", path, file_name];
            printf("[INFO]: unlinking: %s\n", strdup([full_path UTF8String]));
            chosen_strategy.strategy_unlink(strdup([full_path UTF8String]));
            
        }
        
        closedir(target_dir);
        close(fd);
    }
    
    // finally, remove the directory itself
    chosen_strategy.strategy_unlink("/System/Library/PrivateFrameworks/AvatarKit.framework/puppets/customanimoji");
    
}

- (IBAction)removeAnimojiTapped:(id)sender {

    
    [self removeMyAnimmojiButton];
    
    show_alert(self, @"Done", @"My Animoji has been removed");
    
}
- (IBAction)didTapRemoveHoudini:(id)sender {

    // reset 'hosts'
    set_custom_hosts(false);
    
    // remove Animoji
    [self removeAnimoji];
    
    // rename icons back to original
    rename_all_icons("", "original");
    
    // remove widgets/wallpaper
    delete_cached_wallpaper();
    
    // remove webclips
    remove_all_webclips();
    
    // reset 3D Touch toggles
    rename_all_3d_touch_shortcuts("", "original");
    
    // reset CC toggles
    chosen_strategy.strategy_unlink("/private/var/mobile/Library/ControlCenter/ModuleConfiguration.plist");

    // reset System Updates
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"system_updates_disabled"];
    chosen_strategy.strategy_chown("/var/mobile/Media/Downloads", MOBILE_UID, MOBILE_GID);
    chosen_strategy.strategy_chmod("/var/mobile/Media/Downloads", 0755);
    
    // remove Houdini :(
    //clear_files_for_path(strdup([[[NSBundle mainBundle] bundlePath] UTF8String]));
    
    // remove theme
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(startRemovingTheme:) userInfo:nil repeats:NO];
    
}

- (IBAction)dismissTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
