//
//  ListImageCell.h
//  n-Discovery
//
//  Created by Chang on 8/5/15.
//  Copyright (c) 2015 Kent State University. All rights reserved.
//

#import <RETableViewManager/RETableViewManager.h>
#import "NDLearnAsUGoListImageItem.h"

@interface ListImageCell : RETableViewCell

@property (strong, readonly, nonatomic) UIImageView *pictureView;
@property (strong, readwrite, nonatomic) NDLearnAsUGoListImageItem *item;


@end
