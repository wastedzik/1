//
//  display.m
//  houdini
//
//  Created by Abraham Masri on 11/23/17.
//  Copyright © 2017 cheesecakeufo. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "utilities.h"
#include "display.h"


/*
    Purpose: changes the resolution of the display
*/
void change_resolution (int width, int height) {
    
    printf("[INFO]: changing resolution to (w: %d, h: %d)\n", width, height);
    
    NSMutableDictionary *iomobile_graphics_family_dict = [[NSMutableDictionary alloc] init];
    
    [iomobile_graphics_family_dict setObject:[NSNumber numberWithInteger:height] forKey:@"canvas_height"];
    [iomobile_graphics_family_dict setObject:[NSNumber numberWithInteger:width] forKey:@"canvas_width"];
    
    // output path
    NSString *output_path = [NSString stringWithFormat:@"%@/com.apple.iokit.IOMobileGraphicsFamily.plist", get_houdini_dir_for_path(@"display")];
    
    [iomobile_graphics_family_dict writeToFile:output_path atomically:YES];
    
    copy_file(strdup([output_path UTF8String]), "/var/mobile/Library/Preferences/com.apple.iokit.IOMobileGraphicsFamily.plist", ROOT_UID, ROOT_UID, 01444);

}
