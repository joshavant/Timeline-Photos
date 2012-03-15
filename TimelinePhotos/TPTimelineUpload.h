/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 *  TPTimelineUpload.h
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

/////////////////////////////////////////
/**
 TPTimelineUpload relies on NSNotificationCenter to communicate the status of asynchronous processes to
 dependencies. This pattern shares the same responsibilities as the protocol/delegate pattern. The key
 difference is this pattern relies on NSNotifications rather than messages to a delegate object.
 
 Usage: Include this .h in any dependency and use the extern'd NSString constants for notification names and/or objects.
 */

// Facebook user authentication succeeds
extern NSString *const TPTimelineFacebookLoginDidSucceed;

// Facebook user authentication fails
extern NSString *const TPTimelineFacebookLoginDidFail;

// Generic network request failure during the sign in process
extern NSString *const TPTimelineFacebookRequestDidFail;

extern NSString *const TPTimelineUploadDidSucceed;
extern NSString *const TPTimelineUploadDidFail;
/////////////////////////////////////////



@interface TPTimelineUpload : NSObject

// public - these properties are available after TPTimelineFacebookLoginDidSucceed is sent
//          and should not be accessed after logging out
@property (nonatomic, retain) NSString *facebookUserIdString;
@property (nonatomic, retain) NSString *fullName;
@property (nonatomic, retain) UIImage  *profileImage;

- (void)startAsyncFacebookLoginWithEmailAddressString:(NSString *)userEmailAddress
                                    andPasswordString:(NSString *)userPassword;

// this method should *only* be called, after TPTimelineFacebookLoginDidSucceed is sent (successful login)
// and not before another successful login, after logging out
- (void)startAsyncTimelineUploadWithUIImage:(UIImage *)uploadImage
                          withCaptionString:(NSString *)uploadCaption
                                    forDate:(NSDate *)uploadDate
                                 inTimeZone:(NSTimeZone *)uploadTimeZone;

// clears all session-based data. after execution, the current logged in session is invalidated.
- (void)logout;

@end