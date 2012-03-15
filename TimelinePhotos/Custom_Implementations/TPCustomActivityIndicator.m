/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 *  TPCustomActivityIndicator.m
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

#import "TPCustomActivityIndicator.h"

@implementation TPCustomActivityIndicator

/**
 USAGE NOTE:
 HZActivityIndicator has a weird implementation. Init this only with a frame of: {60, 60, 0, 0}.
 
 Description:
 In the HZActivityIndicator library, the frame becomes set internally, once the `indicatorRadius` property is set externally
 (lines 176-177, HZActivityIndicator.m).
 
 The internal formula for calculating the height and width of the generated view's frame is: `_indicatorRadius*2 + _finSize.height*2`
 (lines 179-180, HZActivityIndicatorView.m).
 
 According to the current implementation below, this activity indicator subclass, therefore, will generate a square, 60 point view.
 
 Additionally, since the frame is set internally, for this subclass's `initWithFrame` method, the frame's width and height
 properties can safely be set to 0.
 */

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = YES;
        self.hidden = YES;
        self.steps = 8;
        self.finSize = CGSizeMake(17, 10);
        self.indicatorRadius = 20;
        self.stepDuration = 0.150;
        self.color = [UIColor colorWithRed:85.0/255.0 green:0.0 blue:0.0 alpha:1.000];
        self.cornerRadii = CGSizeMake(0, 0);
        self.hidesWhenStopped = YES;
    }
    
    return self;
}

@end
