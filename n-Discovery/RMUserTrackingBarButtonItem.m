//
//  RMUserTrackingBarButtonItem.m
//  MapView
//
// Copyright (c) 2008-2013, Route-Me Contributors
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

#import "RMUserTrackingBarButtonItem.h"

#import "MGLMapView.h"
#import "MGLUserLocation.h"

#define RMPostVersion7 (floor(NSFoundationVersionNumber) >  NSFoundationVersionNumber_iOS_6_1)
#define RMPreVersion7  (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)

typedef enum : NSUInteger {
    RMUserTrackingButtonStateNone     = 0,
    RMUserTrackingButtonStateActivity = 1,
    RMUserTrackingButtonStateLocation = 2,
    RMUserTrackingButtonStateHeading  = 3
} RMUserTrackingButtonState;

@interface MGLMapView (PrivateMethods)

@property (nonatomic, weak) RMUserTrackingBarButtonItem *userTrackingBarButtonItem;

@end

#pragma mark -

@interface RMUserTrackingBarButtonItem ()

@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UIImageView *buttonImageView;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, assign) RMUserTrackingButtonState state;
@property (nonatomic, assign) UIViewTintAdjustmentMode tintAdjustmentMode;

- (void)createBarButtonItem;
- (void)updateState;
- (void)changeMode:(id)sender;

@end

#pragma mark -

@implementation RMUserTrackingBarButtonItem

@synthesize mapView = _mapView;
@synthesize segmentedControl = _segmentedControl;
@synthesize buttonImageView = _buttonImageView;
@synthesize activityView = _activityView;
@synthesize state = _state;

- (id)initWithMapView:(MGLMapView *)mapView
{
    if ( ! (self = [super initWithCustomView:[[UIControl alloc] initWithFrame:CGRectMake(0, 0, 32, 32)]]))
        return nil;

    [self createBarButtonItem];
    [self setMapView:mapView];

    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ( ! (self = [super initWithCoder:aDecoder]))
        return nil;

    [self setCustomView:[[UIControl alloc] initWithFrame:CGRectMake(0, 0, 32, 32)]];

    [self createBarButtonItem];

    return self;
}

- (void)createBarButtonItem
{
    if (RMPreVersion7)
    {
        _segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@""]];
        _segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
        [_segmentedControl setWidth:32.0 forSegmentAtIndex:0];
        _segmentedControl.userInteractionEnabled = NO;
        _segmentedControl.tintColor = self.tintColor;
        _segmentedControl.center = self.customView.center;

        [self.customView addSubview:_segmentedControl];
    }

    _buttonImageView = [[UIImageView alloc] initWithImage:nil];
    _buttonImageView.contentMode = UIViewContentModeCenter;
    _buttonImageView.frame = CGRectMake(0, 0, 32, 32);
    _buttonImageView.center = self.customView.center;
    _buttonImageView.userInteractionEnabled = NO;

    [self updateImage];

    [self.customView addSubview:_buttonImageView];

    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(RMPreVersion7 ? UIActivityIndicatorViewStyleWhite : UIActivityIndicatorViewStyleGray)];
    _activityView.hidesWhenStopped = YES;
    _activityView.center = self.customView.center;
    _activityView.userInteractionEnabled = NO;

    [self.customView addSubview:_activityView];

    [((UIControl *)self.customView) addTarget:self action:@selector(changeMode:) forControlEvents:UIControlEventTouchUpInside];

    _state = RMUserTrackingButtonStateNone;

    [self updateSize:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSize:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
}

- (void)dealloc
{
    [_mapView removeObserver:self forKeyPath:@"userTrackingMode"];
    [_mapView removeObserver:self forKeyPath:@"userLocation.location"];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
}

#pragma mark -

- (void)setMapView:(MGLMapView *)newMapView
{
    if ( ! [newMapView isEqual:_mapView])
    {
        [_mapView removeObserver:self forKeyPath:@"userTrackingMode"];
        [_mapView removeObserver:self forKeyPath:@"userLocation.location"];

        _mapView = newMapView;
        [_mapView addObserver:self forKeyPath:@"userTrackingMode"      options:NSKeyValueObservingOptionNew context:nil];
        [_mapView addObserver:self forKeyPath:@"userLocation.location" options:NSKeyValueObservingOptionNew context:nil];

//        _mapView.userTrackingBarButtonItem = self;

        [self updateState];
    }
}

- (void)setTintColor:(UIColor *)newTintColor
{
    [super setTintColor:newTintColor];

    if (RMPreVersion7)
        _segmentedControl.tintColor = newTintColor;
    else
        [self updateImage];
}

#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self updateState];
}

#pragma mark -

- (void)updateSize:(NSNotification *)notification
{
    NSInteger orientation = (notification ? [[notification.userInfo objectForKey:UIApplicationStatusBarOrientationUserInfoKey] integerValue] : [[UIApplication sharedApplication] statusBarOrientation]);

    CGFloat dimension = (UIInterfaceOrientationIsPortrait(orientation) ? (RMPostVersion7 ? 36 : 32) : 24);

    self.customView.bounds = _buttonImageView.bounds = _segmentedControl.bounds = CGRectMake(0, 0, dimension, dimension);
    [_segmentedControl setWidth:dimension forSegmentAtIndex:0];
    self.width = dimension;

    _segmentedControl.center = _buttonImageView.center = _activityView.center = CGPointMake(dimension / 2, dimension / 2 - (RMPostVersion7 ? 1 : 0));

    [self updateImage];
}

+ (UIImage *)resourceImageNamed:(NSString *)imageName
{
    if ( ! [[imageName pathExtension] length])
        imageName = [imageName stringByAppendingString:@".png"];
    return [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageName ofType:@"png"]];
//    return [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] bundlePath] pathForBundleResourceNamed:imageName ofType:nil]];
}

- (void)updateImage
{
    if (RMPreVersion7)
    {
        if (_mapView.userTrackingMode == MGLUserTrackingModeFollowWithHeading)
            _buttonImageView.image = [RMUserTrackingBarButtonItem resourceImageNamed:@"TrackingHeading.png"];
        else
            _buttonImageView.image = [RMUserTrackingBarButtonItem resourceImageNamed:@"TrackingLocation.png"];
    }
    else
    {
        CGRect rect = CGRectMake(0, 0, self.customView.bounds.size.width, self.customView.bounds.size.height);

        UIGraphicsBeginImageContextWithOptions(rect.size, NO, [[UIScreen mainScreen] scale]);

        CGContextRef context = UIGraphicsGetCurrentContext();

        UIImage *image;

        if (_mapView.userTrackingMode == MGLUserTrackingModeNone || ! _mapView)
            image = 
            image = [RMUserTrackingBarButtonItem resourceImageNamed:@"TrackingLocationOffMask.png"];
        else if (_mapView.userTrackingMode == MGLUserTrackingModeFollow)
            image = [RMUserTrackingBarButtonItem resourceImageNamed:@"TrackingLocationMask.png"];
        else if (_mapView.userTrackingMode == MGLUserTrackingModeFollowWithHeading)
            image = [RMUserTrackingBarButtonItem resourceImageNamed:@"TrackingHeadingMask.png"];

        UIGraphicsPushContext(context);
        [image drawAtPoint:CGPointMake((rect.size.width  - image.size.width) / 2, ((rect.size.height - image.size.height) / 2) + 2)];
        UIGraphicsPopContext();

        CGContextSetBlendMode(context, kCGBlendModeSourceIn);
        CGContextSetFillColorWithColor(context, self.tintColor.CGColor);
        CGContextFillRect(context, rect);

        _buttonImageView.image = UIGraphicsGetImageFromCurrentImageContext();

        UIGraphicsEndImageContext();

        CABasicAnimation *backgroundColorAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
        CABasicAnimation *cornerRadiusAnimation    = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];

        backgroundColorAnimation.duration = cornerRadiusAnimation.duration = 0.25;

        CGColorRef filledColor = [[self.tintColor colorWithAlphaComponent:0.1] CGColor];
        CGColorRef clearColor  = [[UIColor clearColor] CGColor];

        CGFloat onRadius  = 4.0;
        CGFloat offRadius = 0;

        if (_mapView.userTrackingMode != MGLUserTrackingModeNone && self.customView.layer.cornerRadius != onRadius)
        {
            backgroundColorAnimation.fromValue = (__bridge id)clearColor;
            backgroundColorAnimation.toValue   = (__bridge id)filledColor;

            cornerRadiusAnimation.fromValue = @(offRadius);
            cornerRadiusAnimation.toValue   = @(onRadius);

            self.customView.layer.backgroundColor = filledColor;
            self.customView.layer.cornerRadius    = onRadius;
        }
        else if (_mapView.userTrackingMode == MGLUserTrackingModeNone && self.customView.layer.cornerRadius != offRadius)
        {
            backgroundColorAnimation.fromValue = (__bridge id)filledColor;
            backgroundColorAnimation.toValue   = (__bridge id)clearColor;

            cornerRadiusAnimation.fromValue = @(onRadius);
            cornerRadiusAnimation.toValue   = @(offRadius);

            self.customView.layer.backgroundColor = clearColor;
            self.customView.layer.cornerRadius    = offRadius;
        }

        [self.customView.layer addAnimation:backgroundColorAnimation forKey:@"animateBackgroundColor"];
        [self.customView.layer addAnimation:cornerRadiusAnimation    forKey:@"animateCornerRadius"];
    }
}

- (void)updateState
{
    // "selection" state
    //
    if (RMPreVersion7)
        _segmentedControl.selectedSegmentIndex = (_mapView.userTrackingMode == MGLUserTrackingModeNone ? UISegmentedControlNoSegment : 0);

    // activity/image state
    //
    if (_mapView.userTrackingMode != MGLUserTrackingModeNone && ( ! _mapView.userLocation || ! _mapView.userLocation.location || (_mapView.userLocation.location.coordinate.latitude == 0 && _mapView.userLocation.location.coordinate.longitude == 0)))
    {
        // if we should be tracking but don't yet have a location, show activity
        //
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^(void)
                         {
                             _buttonImageView.transform = CGAffineTransformMakeScale(0.01, 0.01);
                             _activityView.transform    = CGAffineTransformMakeScale(0.01, 0.01);
                         }
                         completion:^(BOOL finished)
                         {
                             _buttonImageView.hidden = YES;

                             [_activityView startAnimating];

                             [UIView animateWithDuration:0.25 animations:^(void)
                             {
                                 _buttonImageView.transform = CGAffineTransformIdentity;
                                 _activityView.transform    = CGAffineTransformIdentity;
                             }];
                         }];

        _state = RMUserTrackingButtonStateActivity;
    }
    else
    {
        if ((_mapView.userTrackingMode == MGLUserTrackingModeNone              && _state != RMUserTrackingButtonStateNone)     ||
            (_mapView.userTrackingMode == MGLUserTrackingModeFollow            && _state != RMUserTrackingButtonStateLocation) ||
            (_mapView.userTrackingMode == MGLUserTrackingModeFollowWithHeading && _state != RMUserTrackingButtonStateHeading))
        {
            // we'll always animate if leaving activity state
            //
            __block BOOL animate = (_state == RMUserTrackingButtonStateActivity);

            [UIView animateWithDuration:0.25
                                  delay:0.0
                                options:UIViewAnimationOptionBeginFromCurrentState
                             animations:^(void)
                             {
                                 if (_state == RMUserTrackingButtonStateHeading &&
                                     _mapView.userTrackingMode != MGLUserTrackingModeFollowWithHeading)
                                 {
                                     // coming out of heading mode
                                     //
                                     animate = YES;
                                 }
                                 else if ((_state != RMUserTrackingButtonStateHeading) &&
                                          _mapView.userTrackingMode == MGLUserTrackingModeFollowWithHeading)
                                 {
                                     // going into heading mode
                                     //
                                     animate = YES;
                                 }

                                 if (animate)
                                     _buttonImageView.transform = CGAffineTransformMakeScale(0.01, 0.01);

                                 if (_state == RMUserTrackingButtonStateActivity)
                                     _activityView.transform = CGAffineTransformMakeScale(0.01, 0.01);
                             }
                             completion:^(BOOL finished)
                             {
                                 [self updateImage];

                                 _buttonImageView.hidden = NO;

                                 if (_state == RMUserTrackingButtonStateActivity)
                                     [_activityView stopAnimating];

                                 [UIView animateWithDuration:0.25 animations:^(void)
                                 {
                                     if (animate)
                                         _buttonImageView.transform = CGAffineTransformIdentity;

                                     if (_state == RMUserTrackingButtonStateActivity)
                                         _activityView.transform = CGAffineTransformIdentity;
                                 }];
                             }];

            if (_mapView.userTrackingMode == MGLUserTrackingModeNone)
                _state = RMUserTrackingButtonStateNone;
            else if (_mapView.userTrackingMode == MGLUserTrackingModeFollow)
                _state = RMUserTrackingButtonStateLocation;
            else if (_mapView.userTrackingMode == MGLUserTrackingModeFollowWithHeading)
                _state = RMUserTrackingButtonStateHeading;
        }
    }
}

- (void)changeMode:(id)sender
{
    if (_mapView)
    {
        switch (_mapView.userTrackingMode)
        {
            case MGLUserTrackingModeNone:
            default:
            {
                _mapView.userTrackingMode = MGLUserTrackingModeFollow;
                
                break;
            }
            case MGLUserTrackingModeFollow:
            {
                if ([CLLocationManager headingAvailable])
                    _mapView.userTrackingMode = MGLUserTrackingModeFollowWithHeading;
                else
                    _mapView.userTrackingMode = MGLUserTrackingModeNone;

                break;
            }
            case MGLUserTrackingModeFollowWithHeading:
            {
                _mapView.userTrackingMode = MGLUserTrackingModeNone;

                break;
            }
        }
    }

    [self updateState];
}

@end