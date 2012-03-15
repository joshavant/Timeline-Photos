/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 *  TPLoginTextField.m
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

#import "TPLoginTextField.h"
#import <QuartzCore/QuartzCore.h>

@interface TPLoginTextField()

// convenience method for getting CGRect of editing and text areas
- (CGRect)editingAndTextRectForBounds:(CGRect)bounds;

@end


@implementation TPLoginTextField

- (id)init
{
    self = [super init];
    if(self)
    {
        self.font = [UIFont fontWithName:@"Helvetica-Bold" size:18.0f];
        self.textColor = [UIColor whiteColor];
        
        self.adjustsFontSizeToFitWidth = YES;
        self.minimumFontSize = 16.0f;
        
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0.0f, 0.6f);
        self.layer.shadowOpacity = 0.5f;
        self.layer.shadowRadius = 0.35f;
        
        self.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.autocorrectionType = UITextAutocorrectionTypeNo;
        self.enablesReturnKeyAutomatically = YES;
    }    
    return self;
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    CGRect rect = [self editingAndTextRectForBounds:bounds];
    // workaround for cutting off descending characters only when in editing mode
    return CGRectMake(rect.origin.x,
                      rect.origin.y,
                      rect.size.width,
                      rect.size.height + 5);
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return [self editingAndTextRectForBounds:bounds];
}

- (CGRect)editingAndTextRectForBounds:(CGRect)bounds
{
    return CGRectMake(10,
                      10,
                      bounds.size.width  - 20,
                      bounds.size.height - 20);
}

- (void)drawPlaceholderInRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f);
    CGContextSetAlpha(context, 0.65f);
    
    [self.placeholder drawInRect:rect
                        withFont:self.font
                   lineBreakMode:UILineBreakModeTailTruncation
                       alignment:self.textAlignment];
    
    CGContextRestoreGState(context);
}

@end
