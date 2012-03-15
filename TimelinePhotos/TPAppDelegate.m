/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 *  TPAppDelegate.m
 *
 *  Created by Josh Avant
 *  Copyright (c) 2012 Hipster, Inc.
 *  All rights reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions
 *  are met:
 *
 *  Redistributions of source code must retain the above copyright notice,
 *  this list of conditions and the following disclaimer.
 *
 *  Redistributions in binary form must reproduce the above copyright notice,
 *  this list of conditions and the following disclaimer in the documentation
 *  and/or other materials provided with the distribution.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 *  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 *  TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 *  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR
 *  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 *  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 *  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#import "TPAppDelegate.h"
#import "TPNavigationBar.h"
#import "TPLoginViewController.h"
#import "TPNewPhotoViewController.h"
#import "TPMetadataViewController.h"
#import <objc/runtime.h>

@implementation TPAppDelegate

// public
@synthesize window;
@synthesize timelineUpload;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.timelineUpload = [[TPTimelineUpload alloc] init];
    [self switchToLoginNavController];
    // [self switchToUserNavController]; // uncomment for DEBUG MODE (no login)
    [self.window makeKeyAndVisible];    
    return YES;
}

- (void)switchToLoginNavController
{
    TPLoginViewController *loginViewController = [[TPLoginViewController alloc] init];
    
    UINavigationController *loginNavController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    loginNavController.navigationBarHidden = YES;
    
    [UIView transitionWithView:self.window
                      duration:0.75
                       options:UIViewAnimationOptionTransitionFlipFromLeft
                    animations:^{self.window.rootViewController = loginNavController;}
                    completion:nil];
}

- (void)switchToUserNavController
{
    TPNewPhotoViewController *newPhotoViewController = [[TPNewPhotoViewController alloc] initWithNibName:@"TPNewPhotoViewController"
                                                                                                  bundle:nil];
    
    UINavigationController *userNavController = [[UINavigationController alloc] initWithRootViewController:newPhotoViewController];

    [self customizeNavBarBackgroundForNavController:userNavController];
    
    [UIView transitionWithView:self.window
                      duration:0.75
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:^{self.window.rootViewController = userNavController;}
                    completion:nil];
}

- (void)customizeNavBarBackgroundForNavController:(UINavigationController *)navController
{
    // Navigation Bar Custom Background
    if([[UINavigationBar class] respondsToSelector:@selector(appearance)])
    {
        // iOS 5+
        UIImage *navigationBarBackground = [[UIImage imageNamed:NAVBAR_IMAGENAMED_PATH] 
                                            resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        
        [[UINavigationBar appearance] setBackgroundImage:navigationBarBackground 
                                           forBarMetrics:UIBarMetricsDefault];
    }
    else
    {
        // iOS < 5
        // Workaround that effects app-wide custom background view
        object_setClass(navController.navigationBar, [TPNavigationBar class]);
    }
}

@end
