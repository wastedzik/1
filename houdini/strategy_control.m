//
//  strategy_control.m
//  houdini
//
//  Created by Abraham Masri on 12/7/17.
//  Copyright © 2017 cheesecakeufo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#include "triple_fetch_strategy.h"
#include "async_wake_strategy.h"
//#include "upper_echelon_strategy.h"
#include "multi_path_strategy.h"
#include "strategy_control.h"

strategy chosen_strategy;

// purpose: returns the suitable strategy for the system version
kern_return_t set_exploit_strategy() {
    
    memset(&chosen_strategy, 0, sizeof(chosen_strategy));
    
    NSString *system_version = [[UIDevice currentDevice] systemVersion];
    
    
    NSArray *triple_fetch_versions = @[@"10.0", @"10.1", @"10.1.1", @"10.2", @"10.2.1", @"10.3.1"];
    
    //NSArray *upper_echelon_versions = [[NSArray alloc] initWithObjects:@"11.0", @"11.0.1", @"11.0.3", @"11.1", @"11.1.2", @"11.2", @"11.2.1", @"11.3", @"11.3.1", @"11.4", @"11.4.1", @"12.0", nil];
    
    NSArray *multi_path_versions = @[@"11.2", @"11.2.1", @"11.3", @"11.3.1"];
    
    if ([triple_fetch_versions containsObject:system_version]) {
    
        printf("[INFO]: chose triple_fetch_strategy!\n");
        chosen_strategy = triple_fetch_strategy();
        return KERN_SUCCESS;
        
    }
//    else if ([upper_echelon_versions containsObject:system_version]) {
//
//        printf("[INFO]: chose upper_echelon_strategy!\n");
//        chosen_strategy = upper_echelon_strategy();
//        return KERN_SUCCESS;
//
//    }
    else if ([multi_path_versions containsObject:system_version]) {

        printf("[INFO]: chose multi_path_strategy!\n");
        chosen_strategy = _multi_path_strategy();
        return KERN_SUCCESS;
    }

    printf("[ERROR]: no suitable strategy was chosen!\n");
    return KERN_FAILURE;
}
