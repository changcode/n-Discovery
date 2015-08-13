//
//  NDLearnAsUGoListImageItem.h
//  n-Discovery
//
//  Created by Chang on 8/5/15.
//  Copyright (c) 2015 Kent State University. All rights reserved.
//

#import <RETableViewManager/RETableViewManager.h>

@interface NDLearnAsUGoListImageItem : RETableViewItem

@property (copy, readwrite, nonatomic) NSString *imageName;

+ (NDLearnAsUGoListImageItem *)itemWithImageNamed:(NSString *)imageName;

@end
