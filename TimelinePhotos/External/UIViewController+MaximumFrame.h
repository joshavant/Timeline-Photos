//
//  UIViewController+MaximumFrame.h
//
//  SOURCE: http://stackoverflow.com/questions/6914711/programmatically-determine-the-maximum-usable-frame-size-for-a-uiview
//

#import <UIKit/UIKit.h>

@interface UIViewController (MaximumFrame)

- (CGRect) maximumUsableFrame;

@end
