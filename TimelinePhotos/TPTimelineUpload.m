//
//  TPTimelineUpload.m
//  TimelinePhotos
//
//  Created by Josh Avant on 1/3/12.
//  Copyright (c) 2012 Hipster, Inc. All rights reserved.
//

#import "TPTimelineUpload.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "ASINetworkQueue.h"

// NSNotificaion name/object NSStrings
NSString *const TPTimelineFacebookLoginDidSucceed = @"TPTimelineFacebookLoginDidSucceed";
NSString *const TPTimelineFacebookLoginDidFail = @"TPTimelineFacebookLoginDidFail";
NSString *const TPTimelineFacebookRequestDidFail = @"TPTimelineFacebookRequestDidFail";
NSString *const TPTimelineUploadDidSucceed = @"TPTimelineUploadDidSucceed";
NSString *const TPTimelineUploadDidFail = @"TPTimelineUploadDidFail";

// ASI/Facebook Properties
#define USER_AGENT      @"Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.8.1.3) Gecko/20070309 Firefox/2.0.0.3 HiMarkSignedJoshAvant/6222246"

#define FB_HOMEPAGE_URL @"http://www.facebook.com"
#define FB_LOGIN_URL    @"https://login.facebook.com/login.php?login_attempt=1"
#define FB_PROFILE_URL  @"https://www.facebook.com/%@"
#define FB_UPLOAD_URL   @"https://upload.facebook.com/photos_upload.php"

// RegExs
// note: the following regexs match value in matching group 1
#define FULL_NAME @"class=\"headerTinymanName\">([^<]*)</span>"
#define PROFILE_IMAGE @"src=\"([^\"]*)\"[^>]*alt=\"Profile Picture\""

// note: the following regexs match property name in matching group 1, and property value in matching group 2
#define FB_DTSG_REGEX @"name=\"(fb_dtsg)\" value=\"([^\"]*)"
#define XHPC_COMPOSERID_REGEX @"name=\"(xhpc_composerid)\" value=\"([^\"]*)"
#define AUDIENCE_VALUE_REGEX @"name=\"(audience\\[[0-9]+]\\[value])\">(?:.(?!</select>))+<option value=\"([^\"]+)\" selected=\"1\">"
#define AUDIENCE_WILDCARD_REGEX @"name=\"(audience\\[[0-9]*][^\"]*)\" value=\"([^\"]*)\""


@interface TPTimelineUpload() <ASIHTTPRequestDelegate>

@property (nonatomic, strong) NSMutableDictionary *uploadParameters;

- (void)prepareUserInfoDefaults;
- (void)verifyLoginAttemptFromResponseRequest:(ASIHTTPRequest *)request;
- (void)captureXhpcTargetIdFromCookieJar; // sets the Facebook userid value in params dict under 'xhpc_targetid' key
- (void)startAsyncFacebookProfilePageRequest;
- (void)didFailFacebookRequest;
- (void)captureProfileParamsFromProfilePageRequest:(ASIHTTPRequest *)request;
- (void)captureProfileImageWithRequest:(ASIHTTPRequest *)request;
- (void)didSucceedFacebookRequest;
- (void)timelineUploadDidSucceed;
- (void)timelineUploadDidFail;

@end


@implementation TPTimelineUpload

// public
@synthesize facebookUserIdString;
@synthesize fullName;
@synthesize profileImage;

// private
@synthesize uploadParameters;

#pragma mark - Customized Initializer
- (id)init
{
    if (self = [super init])
    {
        self.uploadParameters = [[NSMutableDictionary alloc] init];
        [self prepareUserInfoDefaults];
    }
    
    return self;
}

- (void)prepareUserInfoDefaults
{
    self.fullName = @"Facebook User";
    self.profileImage = [UIImage imageNamed:@"default_profile_image"];
}

#pragma mark - Net Request-related Methods
- (void)startAsyncFacebookLoginWithEmailAddressString:(NSString *)userEmailAddress
                                    andPasswordString:(NSString *)userPassword
{
    NSLog(@"TPTimelineUpload: Starting async Facebook login for user: email: %@, password: %@", userEmailAddress, userPassword);
    ASINetworkQueue *loginFlowRequestQueue = [[ASINetworkQueue alloc] init];
    [loginFlowRequestQueue setMaxConcurrentOperationCount:1];    
    
    [ASIHTTPRequest setDefaultUserAgentString:USER_AGENT];
    
    ASIHTTPRequest *facebookHomepageRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:FB_HOMEPAGE_URL]];
    [facebookHomepageRequest setDelegate:self];
    [facebookHomepageRequest setDidFailSelector:@selector(didFailFacebookRequest)];
    [loginFlowRequestQueue addOperation:facebookHomepageRequest];
    
    ASIFormDataRequest *facebookLoginRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:FB_LOGIN_URL]];
    [facebookLoginRequest setDelegate:self];
    [facebookLoginRequest setDidFailSelector:@selector(didFailFacebookRequest)];
    [facebookLoginRequest setDidFinishSelector:@selector(verifyLoginAttemptFromResponseRequest:)];
    [facebookLoginRequest addPostValue:userEmailAddress forKey:@"email"];
    [facebookLoginRequest addPostValue:userPassword forKey:@"pass"];
    [loginFlowRequestQueue addOperation:facebookLoginRequest];
    
    [loginFlowRequestQueue go];
}

- (void)verifyLoginAttemptFromResponseRequest:(ASIHTTPRequest *)request
{
    if([[request responseString] rangeOfString:@"<title>Log In"].location == NSNotFound)
    {
        NSLog(@"TPTimelineUpload: Facebook authentication successful.");
        [self startAsyncFacebookProfilePageRequest];
    }
    else
    {
        NSLog(@"TPTimelineUpload: Facebook authentication failed!");
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:TPTimelineFacebookLoginDidFail 
                                                                                             object:TPTimelineFacebookLoginDidFail]];
    }
}

- (void)captureXhpcTargetIdFromCookieJar
{
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    
    for(NSHTTPCookie *cookie in cookies)
    {
        if([[cookie name] isEqualToString:@"c_user"])
        {
            [self.uploadParameters setObject:[cookie value] forKey:@"xhpc_targetid"];
            self.facebookUserIdString = [cookie value];
        }
    }
}

- (void)startAsyncFacebookProfilePageRequest
{
    [self captureXhpcTargetIdFromCookieJar]; // need to get the xhpc_targetid from cookie jar and set it in the params dict, first.
                                             // xhpc_targetid is equivalent to the user's Facebook userid.
    
    NSString *facebookProfilePageURL = [NSString stringWithFormat:FB_PROFILE_URL,
                                        [self.uploadParameters objectForKey:@"xhpc_targetid"]];
    
    NSLog(@"TPTimelineUpload: Requesting Facebook profile page at URL: %@", facebookProfilePageURL);
    
    ASIHTTPRequest *facebookProfilePageRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:facebookProfilePageURL]];
    [facebookProfilePageRequest setDelegate:self];
    [facebookProfilePageRequest setDidFailSelector:@selector(didFailFacebookRequest)];
    [facebookProfilePageRequest setDidFinishSelector:@selector(captureProfileParamsFromProfilePageRequest:)];
    
    [facebookProfilePageRequest startAsynchronous];
}

- (void)didFailFacebookRequest
{
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:TPTimelineFacebookRequestDidFail 
                                                                                         object:TPTimelineFacebookRequestDidFail]];
}

- (void)captureProfileParamsFromProfilePageRequest:(ASIHTTPRequest *)request
{    
    NSLog(@"TPTimelineUpload: Capturing profile params from Facebook profile page request response body.");
    NSString *responseBody = [request responseString];
    
    // Form Parameters
    for(NSString *regexPattern in [NSArray arrayWithObjects:FB_DTSG_REGEX,
                                                            XHPC_COMPOSERID_REGEX, 
                                                            AUDIENCE_VALUE_REGEX,
                                                            AUDIENCE_WILDCARD_REGEX, nil])
    {
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexPattern
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:nil];
        NSArray *regexMatches = [regex matchesInString:responseBody
                                               options:0
                                                 range:NSMakeRange(0, [responseBody length])];

        for (NSTextCheckingResult *regexMatch in regexMatches)
        {
            // see regex #define constants notes above
            NSString *propertyName = [responseBody substringWithRange:[regexMatch rangeAtIndex:1]];
            NSString *propertyValue = [responseBody substringWithRange:[regexMatch rangeAtIndex:2]];
            
            if([self.uploadParameters objectForKey:propertyName] == nil)
                [self.uploadParameters setObject:propertyValue forKey:propertyName];
            
        }
    }
    
    // Profile Information
    // Full Name
    NSRegularExpression *fullNameRegex = [NSRegularExpression regularExpressionWithPattern:FULL_NAME
                                                                                   options:NSRegularExpressionCaseInsensitive
                                                                                     error:nil];
    NSArray *fullNameRegexMatches = [fullNameRegex matchesInString:responseBody
                                                           options:0
                                                             range:NSMakeRange(0, [responseBody length])];
    
    
    if([fullNameRegexMatches count])
        self.fullName = [responseBody substringWithRange:[[fullNameRegexMatches objectAtIndex:0] rangeAtIndex:1]];    
    
    // Profile Image URL + Async Download
    NSRegularExpression *profileImageRegex = [NSRegularExpression regularExpressionWithPattern:PROFILE_IMAGE
                                                                                       options:NSRegularExpressionCaseInsensitive
                                                                                         error:nil];
    NSArray *profileImageRegexMatches = [profileImageRegex matchesInString:responseBody
                                                                   options:0
                                                                     range:NSMakeRange(0, [responseBody length])];
    
    if([profileImageRegexMatches count])
    {
        NSString *profileImageURL = [responseBody substringWithRange:[[profileImageRegexMatches objectAtIndex:0] rangeAtIndex:1]];
       
        NSLog(@"TPTimelineUpload: Requesting Facebook profile image at URL: %@", profileImageURL);
        
        ASIHTTPRequest *profileImageRequest = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:profileImageURL]];
        [profileImageRequest setDelegate:self];
        [profileImageRequest setDidFailSelector:@selector(didFailFacebookRequest)];
        [profileImageRequest setDidFinishSelector:@selector(captureProfileImageWithRequest:)];
        
        [profileImageRequest startAsynchronous];
        
    }
    else
        [self didSucceedFacebookRequest];
}

- (void)captureProfileImageWithRequest:(ASIHTTPRequest *)request
{
    self.profileImage = [UIImage imageWithData:[request responseData]];
    [self didSucceedFacebookRequest];
}

- (void)didSucceedFacebookRequest
{
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:TPTimelineFacebookLoginDidSucceed 
                                                                                         object:TPTimelineFacebookLoginDidSucceed]];
}

- (void)startAsyncTimelineUploadWithUIImage:(UIImage *)uploadImage
                          withCaptionString:(NSString *)uploadCaption
                                    forDate:(NSDate *)uploadDate
                                 inTimeZone:(NSTimeZone *)uploadTimeZone
{  
    
    // request configuration
    ASIFormDataRequest *facebookTimelineUploadRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:FB_UPLOAD_URL]];
    [facebookTimelineUploadRequest setDelegate:self];
    [facebookTimelineUploadRequest setDidFailSelector:@selector(timelineUploadDidFail)];
    [facebookTimelineUploadRequest setDidFinishSelector:@selector(timelineUploadDidSucceed)];
    
    // argument variable-based upload parameters
    [facebookTimelineUploadRequest addData:UIImagePNGRepresentation(uploadImage)
                              withFileName:@"helloFromJoshAvant.png"
                            andContentType:@"image/png"
                                    forKey:@"file1"];
    
    // the caption string must be set the same on two parameters. weird. weird, but true.
    [facebookTimelineUploadRequest addPostValue:uploadCaption forKey:@"xhpc_message_text"];
    [facebookTimelineUploadRequest addPostValue:uploadCaption forKey:@"xhpc_message"];
    
    
    // date formatting
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeZone = uploadTimeZone;

    [dateFormatter setDateFormat:@"yyyy"];
    NSString *yearString = [dateFormatter stringFromDate:uploadDate];
    
    [dateFormatter setDateFormat:@"MM"];
    NSString *monthString = [dateFormatter stringFromDate:uploadDate];
    
    [dateFormatter setDateFormat:@"dd"];
    NSString *dayString = [dateFormatter stringFromDate:uploadDate];
    
    [facebookTimelineUploadRequest addPostValue:yearString forKey:@"backdated_date[year]"];
    [facebookTimelineUploadRequest addPostValue:monthString forKey:@"backdated_date[month]"];
    [facebookTimelineUploadRequest addPostValue:dayString forKey:@"backdated_date[day]"];
    
    // params dict-based upload parameters
    for (NSString *parameterName in self.uploadParameters)
    {
        [facebookTimelineUploadRequest addPostValue:[self.uploadParameters objectForKey:parameterName] forKey:parameterName];
    }
    
    // upload parameters constants
    [facebookTimelineUploadRequest addPostValue:@"profile" forKey:@"xhpc_content"];
    [facebookTimelineUploadRequest addPostValue:@"1" forKey:@"xhpc_timeline"];
    [facebookTimelineUploadRequest addPostValue:@"1" forKey:@"xhpc_ismeta"];
    [facebookTimelineUploadRequest addPostValue:@"false" forKey:@"disable_location_sharing"];
    
    [facebookTimelineUploadRequest startAsynchronous];
}

- (void)timelineUploadDidSucceed
{
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:TPTimelineUploadDidSucceed 
                                                                                         object:TPTimelineUploadDidSucceed]];
}

- (void)timelineUploadDidFail
{
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:TPTimelineUploadDidFail 
                                                                                         object:TPTimelineUploadDidFail]];
}

- (void)logout
{
    [ASIHTTPRequest clearSession];
    [self.uploadParameters removeAllObjects];
    [self prepareUserInfoDefaults];
}
@end
