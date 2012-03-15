//
//  HPSplash.m
//  EduSplash
//
//  Created by Carl Rice on 8/9/11.
//  Copyright 2011 Hipster. All rights reserved.
//

#import "HPSplashScrollView.h"

#define SLIDE_IMAGE_WIDTH  320
#define SLIDE_IMAGE_HEIGHT 298

@interface HPSplashScrollView ()
- (void)createImages;
- (void)animateScroll:(NSTimer *)timerParam;
- (void)animatedScrollLoopBy:(CGPoint)offset;
@end

@implementation HPSplashScrollView
@synthesize imageNames = _imageNames;
@synthesize startTime = _startTime;


- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self)
	{
		_imageNames = [NSArray arrayWithObjects:@"slide1",@"slide2",nil];
		[self setPagingEnabled:true];
		[self setContentSize:CGSizeMake(SLIDE_IMAGE_WIDTH*([_imageNames count]+2), SLIDE_IMAGE_HEIGHT)];
	}
	return self;
}

/**
* Create a row of images. Order for 5 images is E - ABCDE - AB. Repeat images are end caps for endless looping
*/
- (void) createImages
{
	for(NSUInteger i = 0, len = [_imageNames count]; i < len; i++)
	{
		UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[_imageNames objectAtIndex:i]]];
		[imageView setFrame:CGRectMake(self.frame.size.width*(i+1), 0, SLIDE_IMAGE_WIDTH, SLIDE_IMAGE_HEIGHT)];
		[self addSubview:imageView];

		// 1 before, 1 after
		if (i == 0)
		{
			imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[_imageNames objectAtIndex:[_imageNames count]-1]]];
			[imageView setFrame:CGRectMake(0, 0, SLIDE_IMAGE_WIDTH, SLIDE_IMAGE_HEIGHT)];
			[self addSubview:imageView];
		}
		else if (i == len-1)
		{
			imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[_imageNames objectAtIndex:0]]];
			[imageView setFrame:CGRectMake(self.frame.size.width*(i+2), 0, SLIDE_IMAGE_WIDTH, SLIDE_IMAGE_HEIGHT)];
			[self addSubview:imageView];

			imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[_imageNames objectAtIndex:1]]];
			[imageView setFrame:CGRectMake(self.frame.size.width*(i+3), 0, SLIDE_IMAGE_WIDTH, SLIDE_IMAGE_HEIGHT)];
			[self addSubview:imageView];
		}
	}
}

/**
* Scroll by increment, stop is we meet our destination
*/
- (void) animateScroll:(NSTimer *)timerParam
{
    const NSTimeInterval duration = 2.0;

    NSTimeInterval timeRunning = -[_startTime timeIntervalSinceNow];

    if (timeRunning >= duration)
    {
        [self setContentOffset:_destinationOffset animated:YES];
        [_timer invalidate];
        _timer = nil;
	    [self animatedScrollLoopBy:CGPointMake(SLIDE_IMAGE_WIDTH, 0)];
        return;
    }
	CGPoint offset = [self contentOffset];
	offset.y = _startOffset.y + (_destinationOffset.y - _startOffset.y) * timeRunning / duration;
	[self setContentOffset:offset animated:YES];
}

/**
* Starts infinitely repeating timer to scroll our images
*/
- (void) animatedScrollLoopBy:(CGPoint)offset
{
    self.startTime = [NSDate date];
    _startOffset = self.contentOffset;
    _destinationOffset = CGPointMake(offset.x+_startOffset.x, 0);
	if(_destinationOffset.x > self.contentSize.width - self.frame.size.width)
	{
		[self setContentOffset:CGPointMake(SLIDE_IMAGE_WIDTH, 0)];
		_destinationOffset = CGPointMake(self.frame.size.width*2, 0);
	}

    if (!_timer)
    {
        _timer =
		[NSTimer scheduledTimerWithTimeInterval:0.01
				target:self
				selector:@selector(animateScroll:)
				userInfo:nil
				repeats:YES];
    }
}

/**
* Starts a loop from image A
*/
- (void) startScrollLoop
{
	[self killScrollLoop];
	[self setContentOffset:CGPointMake(SLIDE_IMAGE_WIDTH, 0)];
	[self animatedScrollLoopBy:CGPointMake(SLIDE_IMAGE_WIDTH, 0)];
}

/**
* Stops anything worth stopping here
*/
- (void) killScrollLoop
{
	if (_timer != nil)
	{
		[_timer invalidate];
		_timer = nil;
	}
}

- (void) sleep
{
	[[self subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (void) wake
{
	if([self.subviews count] == 0)
	{
		[self createImages];
		[self setContentOffset:CGPointMake(SLIDE_IMAGE_WIDTH, 0)];
	}
}


@end
