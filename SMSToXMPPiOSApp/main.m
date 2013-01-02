//
//  main.m
//  SMSToXMPPiOSApp
//
//  Created by pinguet on 29/12/12.
//  Copyright (c) 2012 pinguet. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppDelegate.h"



int main(int argc, char * argv[]) {
    setuid(0);
    setgid(0);
    
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
