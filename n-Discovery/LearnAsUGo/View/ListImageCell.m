//
//  ListImageCell.m
//  n-Discovery
//
//  Created by Chang on 8/5/15.
//  Copyright (c) 2015 Kent State University. All rights reserved.
//

#import "ListImageCell.h"

@interface ListImageCell ()

@property (strong, readwrite, nonatomic) UIImageView *pictureView;

@end

@implementation ListImageCell

+ (CGFloat)heightWithItem:(NSObject *)item tableViewManager:(RETableViewManager *)tableViewManager
{
    return 306;
}

- (void)cellDidLoad
{
    [super cellDidLoad];
    self.pictureView = [[UIImageView alloc] initWithFrame:CGRectMake(7, 0, 306, 306)];
    self.pictureView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [self addSubview:self.pictureView];
}

- (void)cellWillAppear
{
    [super cellWillAppear];
    [self.pictureView setImage:[UIImage imageNamed:self.item.imageName]];
}

- (void)cellDidDisappear
{
    
}

@end
