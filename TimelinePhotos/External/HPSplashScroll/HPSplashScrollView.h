//
//  HPSplash.h
//  EduSplash
//
//  Created by Carl Rice on 8/9/11.
//  Copyright 2011 Hipster. All rights reserved.
//

@interface HPSplashScrollView : UIScrollView
{
	NSArray *_imageNames;
	CGPoint _startOffset;
	CGPoint _destinationOffset;
	NSDate * _startTime;
	NSTimer * _timer;
}
@property(nonatomic, strong) NSArray *imageNames;

@property(nonatomic, strong) NSDate *startTime;

- (void)startScrollLoop;
- (void)killScrollLoop;

- (void)sleep;

- (void)wake;


@end
