//
//  HPSplashScrollViewController.m
//  TimelinePhotos
//
//  Created by J A on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HPSplashScrollViewController.h"

@interface HPSplashScrollViewController() <UIScrollViewDelegate>

@property (nonatomic, assign) BOOL shouldLoopCheck;

- (void)loopCheck;

@end


@implementation HPSplashScrollViewController

@synthesize scrollView;
@synthesize scrollViewController;
@synthesize shouldLoopCheck;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.scrollView = [[HPSplashScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 298)];
    self.scrollView.delegate = self;
    [self.scrollView setShowsHorizontalScrollIndicator:false];
    [self.scrollView setShowsVerticalScrollIndicator:false];
    
    self.scrollViewController = [[HPSplashScrollControl alloc] initWithFrame:CGRectMake(0, 276, 320, 12)];
    self.scrollViewController.numberOfPages = [self.scrollView.imageNames count];
    [self.scrollViewController setImageCurrent:[UIImage imageNamed:@"dot_on"]];
    [self.scrollViewController setImageNormal:[UIImage imageNamed:@"dot_off"]];
    [self.scrollViewController setOpaque:false];
    [self.scrollViewController setUserInteractionEnabled:false];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.scrollView wake];
	[self.scrollView startScrollLoop];
}

- (void)viewWillDisappear:(BOOL)animated
{
   	[self.scrollView killScrollLoop];
	[super viewWillDisappear:animated];
}

#pragma mark - UIScrollView Delegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	CGFloat width = self.scrollView.frame.size.width;
	int index = (int) floor((self.scrollView.contentOffset.x - width / 2) / width);
	[self.scrollViewController setCurrentPage:index%[self.scrollView.imageNames count]];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	[self.scrollView killScrollLoop];
    
	if (self.shouldLoopCheck)
	{
		[self loopCheck];
		self.shouldLoopCheck = NO;
	}
	self.shouldLoopCheck = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	self.shouldLoopCheck = NO;
	[self loopCheck];
}

- (void)loopCheck
{
	CGFloat width = self.scrollView.frame.size.width;
	int index = (int) floor((self.scrollView.contentOffset.x - width / 2) / width) + 1;
	if (index == [self.scrollView.imageNames count]+1)
		[self.scrollView setContentOffset:CGPointMake(width, 0)];
	else if (index == 0)
		[self.scrollView setContentOffset:CGPointMake(self.scrollView.contentSize.width-width*2, 0)];
}

@end
