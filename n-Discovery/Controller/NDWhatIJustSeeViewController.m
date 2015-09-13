//
//  NDWhatIJustSeeViewController.m
//  n-Discovery
//
//  Created by Chang on 9/13/15.
//  Copyright (c) 2015 Kent State University. All rights reserved.
//

#import "NDWhatIJustSeeViewController.h"
#import "FBShimmeringView.h"

@interface NDWhatIJustSeeViewController ()

@end

@implementation NDWhatIJustSeeViewController
{
    UIImageView *_wallpaperView;
    FBShimmeringView *_shimmeringView;
    UIView *_contentView;
    UILabel *_logoLabel;
    
    UILabel *_valueLabel;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    _wallpaperView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _wallpaperView.image = [UIImage imageNamed:@"forthcoming"];
    _wallpaperView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:_wallpaperView];
    
    CGRect valueFrame = self.view.bounds;
    valueFrame.size.height = valueFrame.size.height * 0.25;
    
    _valueLabel = [[UILabel alloc] initWithFrame:valueFrame];
    _valueLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:32.0];
    _valueLabel.textColor = [UIColor whiteColor];
    _valueLabel.textAlignment = NSTextAlignmentCenter;
    _valueLabel.numberOfLines = 0;
    _valueLabel.alpha = 0.0;
    _valueLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_valueLabel];
    
    _shimmeringView = [[FBShimmeringView alloc] init];
    _shimmeringView.shimmering = YES;
    _shimmeringView.shimmeringBeginFadeDuration = 0.3;
    _shimmeringView.shimmeringOpacity = 0.3;
    [self.view addSubview:_shimmeringView];
    
    _logoLabel = [[UILabel alloc] initWithFrame:_shimmeringView.bounds];
    _logoLabel.text = @"Forthcoming";
    
    _logoLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:45];
    _logoLabel.textColor = [UIColor whiteColor];
    _logoLabel.textAlignment = NSTextAlignmentCenter;
    _logoLabel.backgroundColor = [UIColor clearColor];
    _shimmeringView.contentView = _logoLabel;
    
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGRect shimmeringFrame = self.view.bounds;
    shimmeringFrame.origin.y = shimmeringFrame.size.height * 0.68;
    shimmeringFrame.size.height = shimmeringFrame.size.height * 0.32;
    _shimmeringView.frame = shimmeringFrame;
}

@end
