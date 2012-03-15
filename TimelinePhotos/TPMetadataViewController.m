/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 *  TPMetadataViewController.m
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

#import "TPMetadataViewController.h"
#import "SSTextView.h"
#import "UIImage+Prep.h"
#import "TPCustomActivityIndicator.h"
#import "TPBarButton.h"
#import "TPAppDelegate.h"
#import "TPConfirmationViewController.h"
#import "TPTimelineUpload.h"

#define THUMBNAIL_MAX_DIMENSION_LARGEST 135

@interface TPMetadataViewController () <UITextViewDelegate>

@property (nonatomic, strong) TPCustomActivityIndicator *customActivityIndicator;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) IBOutlet UILabel *dateLabel;
@property (nonatomic, strong) IBOutlet SSTextView *descriptionTextView;
@property (nonatomic, strong) IBOutlet UIToolbar *keyboardToolbar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *keyboardDoneButton;
@property (nonatomic, strong) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, strong) IBOutlet UIImageView *thumbnailImageView;
@property (nonatomic, strong) UIImage *facebookUploadImage;

- (void)configureNavigationBarButtons;
- (void)didPressBackButton;
- (void)didPressAddToTimelineButton;
- (void)timelineUploadDidSucceed;
- (void)timelineUploadDidFail;
- (void)datePickerDidDateChange;
- (void)dismissKeyboard;
- (void)subscribeToAllNotifications;
- (void)unsubscribeToAllNotifications;

@end


@implementation TPMetadataViewController

// public
@synthesize timelineUploadRawImage;
@synthesize timelineUploadDate;
@synthesize timelineUploadTimeZone;

// private
@synthesize customActivityIndicator;
@synthesize dateFormatter;
@synthesize dateLabel;
@synthesize descriptionTextView;
@synthesize keyboardToolbar;
@synthesize keyboardDoneButton;
@synthesize datePicker;
@synthesize thumbnailImageView;
@synthesize facebookUploadImage;

- (id)initWithNibName:(NSString *)nibNameOrNil
    andRawUploadImage:(UIImage *)rawUploadImage
        andUploadDate:(NSDate *)uploadDate
    andUploadTimeZone:(NSTimeZone *)uploadTimeZone;
{
    self = [super initWithNibName:nibNameOrNil bundle:nil];
    if (self)
    {
        self.navigationItem.title = @"Details";
        [self configureNavigationBarButtons];

        self.dateFormatter = [[NSDateFormatter alloc] init];
        self.dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        
        self.timelineUploadRawImage = rawUploadImage;
        self.timelineUploadDate = uploadDate;
        self.timelineUploadTimeZone = uploadTimeZone;
    }
    return self;
}

- (void)configureNavigationBarButtons
{
    TPBarButton *backButton = [[TPBarButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 50.0f, 30.0f)];
    [backButton setTitle:@"Back" forState:UIControlStateNormal];
    [backButton addTarget:self
                   action:@selector(didPressBackButton)
         forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];    
    
    
    TPBarButton *addToTimelineButton = [[TPBarButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 108.0f, 30.0f)];
    [addToTimelineButton setTitle:@"Add to Timeline" forState:UIControlStateNormal]; 
    [addToTimelineButton addTarget:self
                            action:@selector(didPressAddToTimelineButton)
                  forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addToTimelineButton];    
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.descriptionTextView.placeholder = @"Write something about this photo...";
    self.descriptionTextView.placeholderColor = [UIColor colorWithWhite:0.600 alpha:1.000];
    
    self.descriptionTextView.inputAccessoryView = self.keyboardToolbar;
    
    // Welcome to the 'IB Kept Crashing, So I Hardcoded It' section
    self.keyboardDoneButton.target = self;
    self.keyboardDoneButton.action = @selector(dismissKeyboard);
    
    self.datePicker.maximumDate = [NSDate date];
    [self.datePicker addTarget:self
                        action:@selector(datePickerDidDateChange)
              forControlEvents:UIControlEventValueChanged];
    
    // see TPCustomActivityIndicator.m for more information about frame width/height values
    CGRect frame = [self maximumUsableFrame];
    self.customActivityIndicator = [[TPCustomActivityIndicator alloc] initWithFrame:CGRectMake((frame.size.width - 60)/2,
                                                                                               (frame.size.height - 60)/2,
                                                                                               0,0)];
    
    [self.view addSubview:self.customActivityIndicator];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.dateFormatter.timeZone = self.timelineUploadTimeZone;
    self.datePicker.timeZone = self.timelineUploadTimeZone;
    
    self.datePicker.date = self.timelineUploadDate;
    self.timelineUploadDate = self.timelineUploadDate; // triggers custom setter
    
    self.thumbnailImageView.image = [self.timelineUploadRawImage imageForThumbnailWithLargestSide:THUMBNAIL_MAX_DIMENSION_LARGEST];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self unsubscribeToAllNotifications];
    self.facebookUploadImage = nil;
    self.descriptionTextView.text = @"";
    [super viewDidDisappear:animated];
}

- (void)viewDidUnload
{    
    [self setDatePicker:nil];
    [self setDateLabel:nil];
    [self setDescriptionTextView:nil];
    [self setKeyboardToolbar:nil];
    [self setKeyboardDoneButton:nil];
    [self setThumbnailImageView:nil];
    [super viewDidUnload];
}

#pragma mark - Button Action Callbacks
- (void)didPressBackButton
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didPressAddToTimelineButton
{
    [self.customActivityIndicator startAnimating];
    
    if(!self.facebookUploadImage)
        self.facebookUploadImage = [self.timelineUploadRawImage imageForLargestFacebookImageSizeFromRawImage];

    [self subscribeToAllNotifications];
    
    // bombs away!
    [((TPAppDelegate *)[[UIApplication sharedApplication] delegate]).timelineUpload
     startAsyncTimelineUploadWithUIImage:self.facebookUploadImage
                       withCaptionString:self.descriptionTextView.text
                                 forDate:self.timelineUploadDate
                              inTimeZone:self.timelineUploadTimeZone];
}

#pragma mark - Timeline Upload Callbacks
- (void)timelineUploadDidSucceed
{
    TPConfirmationViewController *confirmationViewController = [[TPConfirmationViewController alloc]
                                                                initWithNibName:@"TPConfirmationViewController"
                                                                andRawUploadImage:self.timelineUploadRawImage];
    
    [self.navigationController pushViewController:confirmationViewController animated:YES];
    [self.customActivityIndicator stopAnimating];
}

- (void)timelineUploadDidFail
{
    [[[UIAlertView alloc] initWithTitle: @"Oops!"
                                message: @"Looks like there was a network problem. Try that one more time."
                               delegate: self
                      cancelButtonTitle: @"OK"
                      otherButtonTitles: nil] show];
}

#pragma mark - Helper Methods
- (void)setTimelineUploadDate:(NSDate *)aDate
{
    self.dateLabel.text = [NSString stringWithFormat:@"%@",
                           [self.dateFormatter stringFromDate:aDate]];

    timelineUploadDate = aDate;
}

- (void)datePickerDidDateChange
{
    self.timelineUploadDate = self.datePicker.date;
}

- (void)dismissKeyboard
{
    [self.descriptionTextView resignFirstResponder];
}

- (void)subscribeToAllNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(timelineUploadDidSucceed)
                                                 name:TPTimelineUploadDidSucceed
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(timelineUploadDidFail)
                                                 name:TPTimelineUploadDidFail
                                               object:nil];
}

- (void)unsubscribeToAllNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TPTimelineUploadDidSucceed object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TPTimelineUploadDidFail object:nil];
}

- (void)dealloc
{
    [self unsubscribeToAllNotifications];
}

@end
