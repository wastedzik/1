//
//  upper_echelon_strategy.m
//  houdini
//
//  Created by Abraham Masri on 05/04/2018.
//  Copyright © 2018 cheesecakeufo. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "utilities.h"
#include "strategy_control.h"
//#include "upper_echelon.h"


// kickstarts the exploit
kern_return_t upper_echelon_strategy_start () {
    
    kern_return_t ret = KERN_SUCCESS;
    
    //extern void upper_echelon_main(void);
    
    //upper_echelon_main();

    
    
    return ret;
}

// called after strategy_start
kern_return_t upper_echelon_strategy_post_exploit () {
    
    kern_return_t ret = KERN_SUCCESS;
    


    return ret;
}

void upper_echelon_strategy_mkdir (char *path) {
    
    

}


void upper_echelon_strategy_rename (const char *old, const char *new) {

}


void upper_echelon_strategy_unlink (char *path) {


}

int upper_echelon_strategy_chown (const char *path, uid_t owner, gid_t group) {
    
    
    return 0;
}


int upper_echelon_strategy_chmod (const char *path, mode_t mode) {

    return 0;
}


int upper_echelon_strategy_open (const char *path, int oflag, mode_t mode) {
    
    int fd = -1;
//    bool ok = upper_echelon_open(path, oflag, mode, NULL, &fd);
//    if (!ok || fd < 0) {
//
//        printf("[ERROR]: Could not open: %s\n", path);
//        return -1;
//    }

    return fd;
    
}

void upper_echelon_strategy_kill (pid_t pid, int sig) {
    

}


pid_t upper_echelon_strategy_pid_for_name(char *name) {
    
    pid_t springboard_pid = -1;

    return springboard_pid;
}

void upper_echelon_strategy_reboot () {
    

}

// returns the upper_echelon strategy with its functions
strategy upper_echelon_strategy() {
    
    strategy returned_strategy;
    
    memset(&returned_strategy, 0, sizeof(returned_strategy));
    
    returned_strategy.strategy_start = &upper_echelon_strategy_start;
    returned_strategy.strategy_post_exploit = &upper_echelon_strategy_post_exploit;
    
    returned_strategy.strategy_mkdir = &upper_echelon_strategy_mkdir;
    returned_strategy.strategy_rename = &upper_echelon_strategy_rename;
    returned_strategy.strategy_unlink = &upper_echelon_strategy_unlink;
    
    returned_strategy.strategy_chown = &upper_echelon_strategy_chown;
    returned_strategy.strategy_chmod = &upper_echelon_strategy_chmod;
    
    returned_strategy.strategy_open = &upper_echelon_strategy_open;
    
    returned_strategy.strategy_kill = &upper_echelon_strategy_kill;
    returned_strategy.strategy_reboot = &upper_echelon_strategy_reboot;
    
    returned_strategy.strategy_pid_for_name = &upper_echelon_strategy_pid_for_name;
    
    return returned_strategy;
}
