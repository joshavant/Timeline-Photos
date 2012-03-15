/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 *  TPConfirmationViewController.m
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

#import "TPConfirmationViewController.h"
#import "UIImage+Prep.h"
#import "TPBarButton.h"
#import "TPAppDelegate.h"

#define THUMBNAIL_MAX_DIMENSION_LARGEST 250

@interface TPConfirmationViewController ()

@property (strong, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (nonatomic, strong) UIImageView *confirmBadgeImageView;

- (void)configureNavigationBarButtons;
- (IBAction)didPressAddAnotherPostcard;
- (IBAction)didPressViewOnFacebook;

@end


@implementation TPConfirmationViewController

// public
@synthesize timelineUploadRawImage;

// private
@synthesize thumbnailImageView;
@synthesize confirmBadgeImageView;

- (id)initWithNibName:(NSString *)nibNameOrNil
    andRawUploadImage:(UIImage *)rawUploadImage;
{
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    if (self)
    {
        self.navigationItem.title = @"Success!";
        [self configureNavigationBarButtons];
        
        self.timelineUploadRawImage = rawUploadImage;
    }
    return self;
}

- (void)configureNavigationBarButtons
{
    TPBarButton *addAnotherButton = [[TPBarButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 92.0f, 30.0f)];
    [addAnotherButton setTitle:@"Add Another" forState:UIControlStateNormal];
    [addAnotherButton addTarget:self
                         action:@selector(didPressAddAnotherPostcard)
               forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addAnotherButton];
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    self.confirmBadgeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Icon_confirm"]];
    self.confirmBadgeImageView.center = CGPointMake(self.thumbnailImageView.bounds.size.width/2,
                                                    self.thumbnailImageView.bounds.size.height/2);
    [self.thumbnailImageView addSubview:self.confirmBadgeImageView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.thumbnailImageView.image = [self.timelineUploadRawImage imageForThumbnailWithLargestSide:THUMBNAIL_MAX_DIMENSION_LARGEST];
    self.confirmBadgeImageView.alpha = 0.0f;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [UIView animateWithDuration:0.4 animations:^{self.confirmBadgeImageView.alpha = 1.0;}];
}

- (void)viewDidUnload
{
    [self setThumbnailImageView:nil];
    [super viewDidUnload];
}

#pragma mark - Button Action Callbacks
- (IBAction)didPressAddAnotherPostcard
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)didPressViewOnFacebook
{
    NSString *facebookUserId = ((TPAppDelegate *)[[UIApplication sharedApplication] delegate]).timelineUpload.facebookUserIdString;
    NSURL *facebookURL = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"http://m.facebook.com/profile.php?id=%@", facebookUserId]];
    [[UIApplication sharedApplication] openURL:facebookURL];    
}

@end
