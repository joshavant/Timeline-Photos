/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 *  TPLogoutViewController.m
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

#import "TPLogoutViewController.h"
#import "TPBarButton.h"
#import "TPAppDelegate.h"
#import "UIImage+Prep.h"

#define DESCRIPTION_TEXT @"You are logged in as\n%@"

@interface TPLogoutViewController()

// must be explicitly vertically centered, after any time text is modified
@property (nonatomic, strong) IBOutlet UITextView *descriptionTextView;
@property (nonatomic, strong) IBOutlet UIImageView *thumbnailImageView;
@property (nonatomic, strong) IBOutlet UIButton *logoutButton;

- (void)configureNavigationBarButtons;
- (void)didPressDismiss;
- (void)didPressLogout;

@end


@implementation TPLogoutViewController

// private
@synthesize descriptionTextView;
@synthesize thumbnailImageView;
@synthesize logoutButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationItem.title = @"Settings";
        [self configureNavigationBarButtons];
    }
    return self;
}

- (void)configureNavigationBarButtons
{
    TPBarButton *dismissButton = [[TPBarButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 60.0f, 30.0f)];
    [dismissButton setTitle:@"Dismiss" forState:UIControlStateNormal];
    [dismissButton addTarget:self
                      action:@selector(didPressDismiss)
            forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:dismissButton];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Welcome to the 'IB Kept Crashing, So I Hardcoded It' section
    [self.logoutButton addTarget:self
                          action:@selector(didPressLogout)
                forControlEvents:UIControlEventTouchUpInside];    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.descriptionTextView.text = [NSString stringWithFormat:DESCRIPTION_TEXT,
                                     ((TPAppDelegate *)[[UIApplication sharedApplication] delegate]).timelineUpload.fullName];
    
    // textview vertical alignment
    CGFloat topMargin = ([self.descriptionTextView bounds].size.height - [self.descriptionTextView contentSize].height *
                         [self.descriptionTextView zoomScale])/2.0;
    topMargin = ( topMargin < 0.0 ? 0.0 : topMargin );
    self.descriptionTextView.contentOffset = (CGPoint){.x = 0, .y = -topMargin};

    UIImage *profileImage = ((TPAppDelegate *)[[UIApplication sharedApplication] delegate]).timelineUpload.profileImage;
    self.thumbnailImageView.image = [profileImage imageForThumbnailWithLargestSide:130.0f];

}

- (void)viewDidUnload
{
    [self setDescriptionTextView:nil];
    [self setThumbnailImageView:nil];    
    [self setLogoutButton:nil];
    [super viewDidUnload];
}

- (void)didPressDismiss
{
    [self dismissModalViewControllerAnimated:NO];
}

- (void)didPressLogout
{
    [((TPAppDelegate *)[[UIApplication sharedApplication] delegate]).timelineUpload logout];
    [((TPAppDelegate *)[[UIApplication sharedApplication] delegate]) switchToLoginNavController];
}

@end
