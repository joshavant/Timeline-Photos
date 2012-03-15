//
//  HPSplashScrollViewController.h
//  TimelinePhotos
//
//  Created by J A on 1/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HPSplashScrollView.h"
#import "HPSplashScrollControl.h"

// This is a quick-and-dirty abstraction layer for HPSplashScroll.
// Any view controllers that want use HPSplashScroll should subclass this.
//
// In viewDidLoad of subclasses, add these lines, in order:
//     [self.educationSlideView addSubview:self.scrollView];
//     [self.educationSlideView addSubview:self.scrollViewController];
//
// ...where `self.educationSlideView` is a UIView container for the HPSplashScroll views.

@interface HPSplashScrollViewController : UIViewController

@property (nonatomic, strong) HPSplashScrollView *scrollView;
@property (nonatomic, strong) HPSplashScrollControl *scrollViewController;

@end
