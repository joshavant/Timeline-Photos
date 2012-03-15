/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 *  TPLoginView.m
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

#import "TPLoginView.h"
#import <QuartzCore/QuartzCore.h>

#define SIGN_IN_LABEL_TEXT @"Sign in with your Facebook account:"
#define SIGN_UP_LABEL_TEXT @"Sign up for a Facebook account"

// UI Configuration
// The view layout will dynamically adjust to these parameters
#define FORM_TOP_MARGIN           22
#define SIGN_IN_LABEL_TOP_MARGIN  12
#define LOGIN_FIELDS_TOP_MARGIN   16
#define PASSWORD_FIELD_TOP_MARGIN 10
#define SIGN_UP_ARROW_TOP_MARGIN  23
#define GITHUB_BADGE_TOP_MARGIN   197

// Custom UIView that redirects to Facebook for signup, when touched
@interface TPFacebookLinkView : UIView
@end

@implementation TPFacebookLinkView
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    NSURL *facebookURL = [[NSURL alloc] initWithString:@"http://m.facebook.com/r.php"];
    [[UIApplication sharedApplication] openURL:facebookURL];
}
@end

// ...and one for Github
@interface TPGithubLinkView : UIView
@end

@implementation TPGithubLinkView
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    NSURL *githubURL = [[NSURL alloc] initWithString:@"http://github.com/joshavant/Timeline-Photos"];
    [[UIApplication sharedApplication] openURL:githubURL];
}
@end


@implementation TPLoginView

// public
@synthesize emailTextField;
@synthesize passwordTextField;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"bg_blue_gradient"]];    
        
        UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
        [self addSubview:logo];
        logo.frame = CGRectMake((self.frame.size.width - logo.image.size.width)/2,
                                FORM_TOP_MARGIN,
                                logo.image.size.width,
                                logo.image.size.height);
        
        UILabel *signInLabel = [[UILabel alloc] init];
        [self addSubview:signInLabel];
        signInLabel.text = SIGN_IN_LABEL_TEXT;
        signInLabel.textColor = [UIColor colorWithRed:0.769 green:0.800 blue:0.871 alpha:1.000];
        signInLabel.font = [UIFont fontWithName:@"Georgia-Italic" size:15.0f];
        signInLabel.layer.shadowColor = [UIColor colorWithRed:0.231 green:0.294 blue:0.431 alpha:1.000].CGColor;
        signInLabel.layer.shadowOffset = CGSizeMake(0.0f, 1.0f);
        signInLabel.layer.shadowOpacity = 1.0f;
        signInLabel.layer.shadowRadius = 0.35f;
        signInLabel.backgroundColor = [UIColor clearColor];
        signInLabel.frame = CGRectMake((self.frame.size.width -
                                        [signInLabel sizeThatFits:self.frame.size].width)/2,
                                       logo.frame.origin.y + logo.frame.size.height + SIGN_IN_LABEL_TOP_MARGIN,
                                       [signInLabel sizeThatFits:self.frame.size].width,
                                       [signInLabel sizeThatFits:self.frame.size].height);
        
        // email textfield configuration
        // background image
        UIImageView *emailTextFieldBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"textfield"]];
        [self addSubview:emailTextFieldBackground];
        emailTextFieldBackground.frame = CGRectMake((self.frame.size.width -
                                                     emailTextFieldBackground.image.size.width)/2,
                                                    signInLabel.frame.origin.y + signInLabel.frame.size.height + LOGIN_FIELDS_TOP_MARGIN,
                                                    emailTextFieldBackground.image.size.width,
                                                    emailTextFieldBackground.image.size.height);
        
        // TPLoginTextField
        self.emailTextField = [[TPLoginTextField alloc] init];
        [self addSubview:self.emailTextField];
        self.emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
        self.emailTextField.returnKeyType = UIReturnKeyNext;
        self.emailTextField.placeholder = @"Email";
        self.emailTextField.frame = emailTextFieldBackground.frame;
        
        // password textfield configuration
        // background image
        UIImageView *passwordTextFieldBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"textfield"]];
        [self addSubview:passwordTextFieldBackground];
        passwordTextFieldBackground.frame = CGRectMake((self.frame.size.width -
                                                        passwordTextFieldBackground.image.size.width)/2,
                                                       emailTextFieldBackground.frame.origin.y + emailTextFieldBackground.frame.size.height +
                                                       PASSWORD_FIELD_TOP_MARGIN,
                                                       passwordTextFieldBackground.image.size.width,
                                                       passwordTextFieldBackground.image.size.height);
        
        // TPLoginTextField
        self.passwordTextField = [[TPLoginTextField alloc] init];
        [self addSubview:self.passwordTextField];
        self.passwordTextField.secureTextEntry = YES;
        self.passwordTextField.returnKeyType = UIReturnKeyGo;
        self.passwordTextField.placeholder = @"Password";
        self.passwordTextField.frame = passwordTextFieldBackground.frame;
        
        // facebook signup label + arrow container view
        TPFacebookLinkView *signUpLabelAndArrowLinkView = [[TPFacebookLinkView alloc] init];
        [self addSubview:signUpLabelAndArrowLinkView];
        
        UILabel *signUpLabel = [[UILabel alloc] init];
        [signUpLabelAndArrowLinkView addSubview:signUpLabel];
        signUpLabel.text = SIGN_UP_LABEL_TEXT;
        signUpLabel.textColor = [UIColor colorWithRed:0.176 green:0.243 blue:0.392 alpha:1.000];
        signUpLabel.font = [UIFont fontWithName:@"Georgia-Italic" size:12.0f];
        signUpLabel.backgroundColor = [UIColor clearColor];
        signUpLabel.frame = CGRectMake(0,0,
                                       [signUpLabel sizeThatFits:self.frame.size].width,
                                       [signUpLabel sizeThatFits:self.frame.size].height);
        
        UIImageView *signUpRightArrow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow"]];
        [signUpLabelAndArrowLinkView addSubview:signUpRightArrow];
        signUpRightArrow.frame = CGRectMake(signUpLabel.bounds.origin.x + signUpLabel.bounds.size.width + 8,
                                            signUpLabel.bounds.origin.y + 2,
                                            [signUpRightArrow sizeThatFits:self.frame.size].width,
                                            [signUpRightArrow sizeThatFits:self.frame.size].height);        

        CGFloat signupTotalWidth = signUpRightArrow.frame.origin.x + signUpRightArrow.frame.size.width;
        CGFloat signupTotalHeight = signUpRightArrow.frame.origin.y + signUpRightArrow.frame.size.height;
        
        // to enlarge hit area: 8 is added to width and height / 4 is subtracted from x and y
        signUpLabelAndArrowLinkView.frame = CGRectMake((self.frame.size.width - signupTotalWidth)/2 - 4,
                                                       self.passwordTextField.frame.origin.y + self.passwordTextField.frame.size.height +
                                                       SIGN_UP_ARROW_TOP_MARGIN - 4,
                                                       signupTotalWidth + 8,
                                                       signupTotalHeight + 8);
        
        // github badge
        TPGithubLinkView *githubBadgeLinkView = [[TPGithubLinkView alloc] init];
        [self addSubview:githubBadgeLinkView];
        
        UIImageView *githubBadgeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btn_github_badge"]];
        [githubBadgeLinkView addSubview:githubBadgeView];
        githubBadgeView.alpha = 0.8f;
        githubBadgeLinkView.frame = CGRectMake(self.frame.size.width - githubBadgeView.frame.size.width - 8,
                                               signUpLabelAndArrowLinkView.frame.origin.y + signUpLabelAndArrowLinkView.frame.size.height +
                                               GITHUB_BADGE_TOP_MARGIN - 4,
                                               githubBadgeView.frame.size.width + 8,
                                               githubBadgeView.frame.size.height + 8);
    }
    return self;
}

@end
