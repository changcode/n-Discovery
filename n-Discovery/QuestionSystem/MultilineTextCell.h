//
//  MultilineTextCell.h
//  n-Discovery
//
//  Created by Chang on 9/15/15.
//  Copyright (c) 2015 Kent State University. All rights reserved.
//

#import <RETableViewManager/RETableViewManager.h>
#import "MultilineTextItem.h"

@interface MultilineTextCell : RETableViewCell

@property (strong, readwrite, nonatomic) MultilineTextItem *item;
@property (strong, readonly, nonatomic) UILabel *multilineLabel;

@end
