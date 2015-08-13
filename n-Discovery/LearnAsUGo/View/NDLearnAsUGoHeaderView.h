//
//  NDLearnAsUGoHeaderView.h
//  n-Discovery
//
//  Created by Chang on 8/5/15.
//  Copyright (c) 2015 Kent State University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NDLearnAsUGoHeaderView : UIView

@property (strong, readonly, nonatomic) UIImageView *userpicImageView;
@property (strong, readonly, nonatomic) UILabel *usernameLabel;

+ (NDLearnAsUGoHeaderView *)headerViewWithImageNamed:(NSString *)imageName username:(NSString *)username;

@end
