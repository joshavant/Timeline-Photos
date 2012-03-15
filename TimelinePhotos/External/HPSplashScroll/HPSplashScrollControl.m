//
//  Created by carlrice on 8/9/11.
//


#import "HPSplashScrollControl.h"


@interface HPSplashScrollControl ()
- (void)updateDots;
@end

@implementation HPSplashScrollControl

@synthesize imageNormal = _imageNormal;
@synthesize imageCurrent = _imageCurrent;

- (void)setCurrentPage:(NSInteger)currentPage
{
	[super setCurrentPage:currentPage];
	[self updateDots];
}

- (void)updateCurrentPageDisplay
{
	[super updateCurrentPageDisplay];
	[self updateDots];
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	[super endTrackingWithTouch:touch withEvent:event];
	[self updateDots];
}

/**
* Set the default unselected image
*/
- (void)setImageNormal:(UIImage *)image
{
	_imageNormal = image;
	[self updateDots];
}

/**
* Set the currently active/selected image
*/
- (void)setImageCurrent:(UIImage *)image
{
	_imageCurrent = image;
	[self updateDots];
}

/**
* Update dot display overriding the defaults
*/
- (void)updateDots
{
	if (_imageCurrent || _imageNormal)
	{
		NSArray *dotViews = self.subviews;
		for (NSUInteger i = 0; i < dotViews.count; ++i)
		{
			UIImageView *dot = [dotViews objectAtIndex:i];
			dot.frame = CGRectMake(dot.frame.origin.x, dot.frame.origin.y, _imageNormal.size.width, _imageNormal.size.height);
			dot.image = (i == self.currentPage) ? _imageCurrent : _imageNormal;
		}
	}
}

- (void)dealloc
{
	_imageNormal = nil;
	_imageCurrent = nil;
}

@end