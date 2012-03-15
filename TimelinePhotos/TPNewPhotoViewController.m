/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 *  TPNewPhotoViewController.m
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

#import "TPNewPhotoViewController.h"
#import "TPMetadataViewController.h"
#import "TPBarButton.h"
#import "TPLogoutViewController.h"
#import "TPAppDelegate.h"
#import <CoreLocation/CLLocationManager.h>
#import <CoreLocation/CLLocationManagerDelegate.h>
#import <AssetsLibrary/AssetsLibrary.h>

// simple object container for Photo-related objects
@interface TPPhotoData : NSObject
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSTimeZone *timeZone;
- (void)removeContents;
@end

@implementation TPPhotoData
@synthesize image;
@synthesize date;
@synthesize timeZone;
- (void)removeContents
{
    self.image = nil;
    self.date = nil;
    self.timeZone = nil;
}
@end


@interface TPNewPhotoViewController() <UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) TPMetadataViewController *metadataViewController;
@property (nonatomic, strong) TPPhotoData *photo;
@property (nonatomic, strong) IBOutlet UIView *educationSlideView;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL locationManagerHasInit;

- (void)configureNavigationBarButtons;
- (void)presentLibraryPickerModal;
- (void)pushMetadataViewController;
- (void)didPressSettingsBarButton;
- (IBAction)scanButtonPressed;
- (IBAction)choosePhotoButtonPressed;

@end


@implementation TPNewPhotoViewController

// private
@synthesize metadataViewController;
@synthesize photo;
@synthesize educationSlideView;
@synthesize locationManager;
@synthesize locationManagerHasInit;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.locationManagerHasInit = NO;
        self.navigationItem.title = @"Timeline Photos";
        [self configureNavigationBarButtons];
        
        self.photo = [[TPPhotoData alloc] init];
        
        // get current location user permissions
        // these permissions are needed before accessing photo library metadata
        // it's a nicer experience getting this now, compared to the default timing
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        self.locationManager.purpose = @"We need this permission to access the date that photos in your library were created.";
    }
    return self;
}

- (void)configureNavigationBarButtons
{
    TPBarButton *gearButton = [[TPBarButton alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 35.0f, 30.0f)];

    UIImageView *gearImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gear"]];
    gearImageView.center = gearButton.center;
    [gearButton addSubview:gearImageView];
    
    [gearButton addTarget:self
                   action:@selector(didPressSettingsBarButton)
         forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:gearButton];    
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // required for HPSplashScroll - see HPSplashScrollViewController.h for more info
    [self.educationSlideView addSubview:self.scrollView];
    [self.educationSlideView addSubview:self.scrollViewController];
}

- (void)viewDidUnload
{
    [self setEducationSlideView:nil];
    [super viewDidUnload];
}

#pragma mark - Custom VC Displaying Methods
- (void)presentLibraryPickerModal
{
    UIImagePickerController *libraryPickerController = [[UIImagePickerController alloc] init];
    libraryPickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    libraryPickerController.delegate = self;
    libraryPickerController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentModalViewController:libraryPickerController animated:YES];
}

- (void)pushMetadataViewController
{
    if(!self.metadataViewController)
    {
        self.metadataViewController = [[TPMetadataViewController alloc] initWithNibName:@"TPMetadataViewController"
                                                                      andRawUploadImage:self.photo.image
                                                                          andUploadDate:self.photo.date
                                                                      andUploadTimeZone:self.photo.timeZone];
    }
    else
    {
        self.metadataViewController.timelineUploadRawImage = self.photo.image;
        self.metadataViewController.timelineUploadDate = self.photo.date;
        self.metadataViewController.timelineUploadTimeZone = self.photo.timeZone;
    }
    
    [self.navigationController pushViewController:self.metadataViewController animated:YES];
    [self.photo removeContents];
}

#pragma mark - Button Action Callbacks
- (void)didPressSettingsBarButton
{    
    TPLogoutViewController *logoutViewController = [[TPLogoutViewController alloc] initWithNibName:@"TPLogoutViewController"
                                                                                            bundle:nil];
    logoutViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;

    UINavigationController *modalNavigationController = [[UINavigationController alloc]
                                                         initWithRootViewController:logoutViewController];

    [(TPAppDelegate *)[[UIApplication sharedApplication] delegate]
     customizeNavBarBackgroundForNavController:modalNavigationController];
    
    [self presentModalViewController:modalNavigationController animated:YES];
}

- (IBAction)scanButtonPressed
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == NO)
        return;
    
    UIImagePickerController *cameraPickerController = [[UIImagePickerController alloc] init];
    cameraPickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    cameraPickerController.delegate = self;
    cameraPickerController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentModalViewController:cameraPickerController animated:YES];
}

- (IBAction)choosePhotoButtonPressed
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] == NO)
        return;
    
    if (([CLLocationManager locationServicesEnabled])
        && ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined))
    {
        // permission has not been decided yet, ask for permission before presenting camera roll
        [locationManager startUpdatingLocation];
        [locationManager stopUpdatingLocation];
    }else{
        // permission has been decided already, continue to the camera roll
        [self presentLibraryPickerModal];
    }
}

#pragma mark - CLLocationManagerDelegate Methods
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    // the BOOL ivar is a workaround for this method firing upon init of CLLocationManager instance
    if(self.locationManagerHasInit)
        [self presentLibraryPickerModal];
    
    self.locationManagerHasInit = YES;
}

#pragma mark - UIImagePickerControllerDelegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissModalViewControllerAnimated:NO];
    
    self.photo.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.photo.timeZone = [NSTimeZone localTimeZone];
    
    if(picker.sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        // camera
        self.photo.date = [NSDate date];
        [self pushMetadataViewController];
    }
    else
    {
        // camera roll
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
        [assetsLibrary assetForURL:[info objectForKey:UIImagePickerControllerReferenceURL]
                       resultBlock:^(ALAsset *asset) {
                           NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                           dateFormatter.dateFormat = @"y:MM:dd HH:mm:SS";

                           NSDate *photoDate = [dateFormatter dateFromString:[[[[asset defaultRepresentation] metadata]
                                                                               objectForKey:@"{Exif}"] objectForKey:@"DateTimeOriginal"]];
                           
                           // all iOS 4.x versions don't reliably save `DateTimeOriginal` key in EXIF data
                           if(photoDate)
                               self.photo.date = photoDate;
                           else
                               self.photo.date = [NSDate date];
                           
                           [self pushMetadataViewController];
                       }
                      failureBlock:^(NSError *error) {
                          [[[UIAlertView alloc] initWithTitle: @"Oops!"
                                                      message: @"There was a problem with that image. Please try that again."
                                                     delegate: self
                                            cancelButtonTitle: @"OK"
                                            otherButtonTitles: nil] show];
                      }];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:NO];
}

@end
