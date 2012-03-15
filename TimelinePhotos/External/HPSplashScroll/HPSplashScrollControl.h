//
//  Created by carlrice on 8/9/11.
//

@interface HPSplashScrollControl : UIPageControl 
{
	UIImage* _imageNormal;
	UIImage* _imageCurrent;
}

@property (nonatomic, readwrite, strong) UIImage* imageNormal;
@property (nonatomic, readwrite, strong) UIImage* imageCurrent;

@end