//
//  NDLearnAsUGoHeaderView.m
//  n-Discovery
//
//  Created by Chang on 8/5/15.
//  Copyright (c) 2015 Kent State University. All rights reserved.
//

#import "NDLearnAsUGoHeaderView.h"

@interface NDLearnAsUGoHeaderView()

@property (strong, readwrite, nonatomic) UIImageView *userpicImageView;
@property (strong, readwrite, nonatomic) UILabel *usernameLabel;


@end

@implementation NDLearnAsUGoHeaderView

+ (NDLearnAsUGoHeaderView *)headerViewWithImageNamed:(NSString *)imageNamed username:(NSString *)username
{
    NDLearnAsUGoHeaderView *view = [[NDLearnAsUGoHeaderView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    [view.userpicImageView setImage:[UIImage imageNamed:imageNamed]];
    [view.usernameLabel setText:username];
    return view;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        UIView *backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        backgroundView.backgroundColor = [UIColor whiteColor];
        backgroundView.alpha = 0.9;
        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:backgroundView];
        
        self.userpicImageView = [[UIImageView alloc] initWithFrame:CGRectMake(7, 7, 30, 30)];
        [self addSubview:self.userpicImageView];
        
        self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 3, 276, 35)];
        self.usernameLabel.font = [UIFont boldSystemFontOfSize:14];
        self.usernameLabel.textColor = [UIColor blackColor];
        self.usernameLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.usernameLabel];
    }
    return self;
}


@end
