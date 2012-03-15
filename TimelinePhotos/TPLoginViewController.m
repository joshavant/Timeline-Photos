/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 *  TPLoginViewController.m
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

#import "TPLoginViewController.h"
#import "TPLoginView.h"
#import "TPTimelineUpload.h"
#import "TPCustomActivityIndicator.h"
#import "TPAppDelegate.h"

@interface TPLoginViewController()

@property (nonatomic, strong) TPLoginView *loginView;
@property (nonatomic, strong) TPCustomActivityIndicator *customActivityIndicator;

- (void)facebookLoginDidSucceed;
- (void)facebookLoginDidFail;
- (void)facebookRequestDidFail;
- (void)subscribeToAllNotifications;
- (void)unsubscribeToAllNotifications;
- (BOOL)validateFormFieldsAndDisplayAlert;
- (void)dismissKeyboard;

@end


@implementation TPLoginViewController

// private
@synthesize loginView;
@synthesize customActivityIndicator;

#pragma mark - View lifecycle
- (void)loadView
{
    CGRect frame = [self maximumUsableFrame];
    self.loginView = [[TPLoginView alloc] initWithFrame:frame];

    // see TPCustomActivityIndicator for more information about frame implementation
    self.customActivityIndicator = [[TPCustomActivityIndicator alloc] initWithFrame:CGRectMake((frame.size.width - 60)/2,
                                                                                               (frame.size.height - 60)/2,
                                                                                               0,0)];
    [self.loginView addSubview:self.customActivityIndicator];
    
    self.view = self.loginView;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.loginView.emailTextField)
    {
        [self.loginView.passwordTextField becomeFirstResponder];
        return NO;
    }
    else if(textField == self.loginView.passwordTextField)
    {       
        if([self validateFormFieldsAndDisplayAlert])
        {
            [self dismissKeyboard];
            
            [self.customActivityIndicator startAnimating];
            
            [((TPAppDelegate *)[[UIApplication sharedApplication] delegate]).timelineUpload
             startAsyncFacebookLoginWithEmailAddressString:self.loginView.emailTextField.text
                                         andPasswordString:self.loginView.passwordTextField.text];
        }
    }
    
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.loginView.emailTextField.delegate = self;
    self.loginView.passwordTextField.delegate = self;
    
    UITapGestureRecognizer *keyboardDismissTapRecognizer = [[UITapGestureRecognizer alloc]
                                                            initWithTarget:self
                                                            action:@selector(dismissKeyboard)];
    keyboardDismissTapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:keyboardDismissTapRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self subscribeToAllNotifications];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self unsubscribeToAllNotifications];
}

#pragma mark - TPTimelineUpload Notification Callbacks
- (void)facebookLoginDidSucceed
{
    [self.customActivityIndicator stopAnimating];
    [((TPAppDelegate *)[[UIApplication sharedApplication] delegate]) switchToUserNavController];
}

- (void)facebookLoginDidFail
{
    [[[UIAlertView alloc] initWithTitle: @"Oops!"
                                message: @"That email and password combination was incorrect."
                               delegate: self
                      cancelButtonTitle: @"OK"
                      otherButtonTitles: nil] show];
    [self.customActivityIndicator stopAnimating];
}

- (void)facebookRequestDidFail
{
    [[[UIAlertView alloc] initWithTitle: @"Oops!"
                                message: @"There was a problem logging in. Make sure you're connected"
                                          "to the Internet and give it another go.\n\n"
                                          "(If this keeps happening, watch for an App Store update in a few days.)"
                               delegate: self
                      cancelButtonTitle: @"OK"
                      otherButtonTitles: nil] show];
    [self.customActivityIndicator stopAnimating];
}

#pragma mark - NSNotification Common Methods
- (void)subscribeToAllNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(facebookLoginDidSucceed)
                                                 name:TPTimelineFacebookLoginDidSucceed
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(facebookLoginDidFail)
                                                 name:TPTimelineFacebookLoginDidFail
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(facebookRequestDidFail)
                                                 name:TPTimelineFacebookRequestDidFail
                                               object:nil];
}

- (void)unsubscribeToAllNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TPTimelineFacebookLoginDidSucceed object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TPTimelineFacebookLoginDidFail object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TPTimelineFacebookRequestDidFail object:nil];
}

#pragma mark - Helper Methods
- (BOOL)validateFormFieldsAndDisplayAlert
{    
    if([self.loginView.emailTextField.text length] == 0)
    {
        [[[UIAlertView alloc] initWithTitle: @"Oops!"
                                    message: @"Looks like you forgot your email address."
                                   delegate: self
                          cancelButtonTitle: @"OK"
                          otherButtonTitles: nil] show];
        [self.loginView.emailTextField becomeFirstResponder];
        return NO;
    }
    else if([self.loginView.passwordTextField.text length] == 0)
    {
        [[[UIAlertView alloc] initWithTitle: @"Oops!"
                                    message: @"Looks like you forgot your password."
                                   delegate: self
                          cancelButtonTitle: @"OK"
                          otherButtonTitles: nil] show];
        [self.loginView.passwordTextField becomeFirstResponder];
        return NO;
    }
    
    return YES;
}

- (void)dismissKeyboard
{
    [self.loginView.emailTextField resignFirstResponder];
    [self.loginView.passwordTextField resignFirstResponder];
}

- (void)dealloc
{
    [self unsubscribeToAllNotifications];
}



@end
