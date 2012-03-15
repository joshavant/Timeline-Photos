/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 *  UIImage+Prep.m
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

#import "UIImage+Prep.h"
#import "UIImage+Resize.h"
#import <QuartzCore/QuartzCore.h>

#define FACEBOOK_MAX_DIMENSION_LARGEST  960
#define FACEBOOK_MAX_DIMENSION_SMALLEST 717

@implementation UIImage (Prep)

- (UIImage *)imageForLargestFacebookImageSizeFromRawImage
{
    if(self.size.width > self.size.height)
    {
        return [self resizedImageWithContentMode:UIViewContentModeScaleAspectFit
                                           bounds:CGSizeMake(FACEBOOK_MAX_DIMENSION_LARGEST, FACEBOOK_MAX_DIMENSION_SMALLEST)
                             interpolationQuality:kCGInterpolationHigh];
    }
    
    return [self resizedImageWithContentMode:UIViewContentModeScaleAspectFit
                                       bounds:CGSizeMake(FACEBOOK_MAX_DIMENSION_SMALLEST, FACEBOOK_MAX_DIMENSION_LARGEST)
                         interpolationQuality:kCGInterpolationHigh];
}

// TODO: This is a disgrace of a method. Needs to be fixed.
- (UIImage *)imageForThumbnailWithLargestSide:(CGFloat)side
{
    UIImage *thumbnailImage = [self resizedImageWithContentMode:UIViewContentModeScaleAspectFit
                                                         bounds:CGSizeMake(side, side)
                                           interpolationQuality:kCGInterpolationHigh];
    CGSize size = [thumbnailImage size];
    UIGraphicsBeginImageContext(size);
    CGRect rect = CGRectMake(0, 0, size.width, size.height);    
    [thumbnailImage drawInRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // outline
    CGContextSetRGBStrokeColor(context, 1.0, 1.0, 1.0, 1.0); 
    CGContextSetLineWidth(context, 3.0);
    CGContextStrokeRect(context, rect);
    
    UIImage *outputImage =  UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // shadow
    CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef shadowContext = CGBitmapContextCreate(NULL, outputImage.size.width + 4, outputImage.size.height + 3, CGImageGetBitsPerComponent(outputImage.CGImage), 0, colourSpace, kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colourSpace);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat components[4] = {0.0, 0.0, 0.0, 0.6};
    CGColorRef blackCGColor = CGColorCreate(rgbColorSpace, components); 
    
    CGContextSetShadowWithColor(shadowContext, CGSizeMake(0,-1), 2, blackCGColor);
    CGContextDrawImage(shadowContext, CGRectMake(3, 2, outputImage.size.width, outputImage.size.height), outputImage.CGImage);
    
    CGImageRef shadowedCGImage = CGBitmapContextCreateImage(shadowContext);
    CGColorSpaceRelease(rgbColorSpace);
    CGColorRelease(blackCGColor);
    CGContextRelease(shadowContext);
    
    UIImage * shadowedImage = [UIImage imageWithCGImage:shadowedCGImage];
    CGImageRelease(shadowedCGImage);
    
    return shadowedImage;
}

@end
