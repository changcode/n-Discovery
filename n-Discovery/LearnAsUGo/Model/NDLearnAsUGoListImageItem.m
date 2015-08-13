//
//  NDLearnAsUGoListImageItem.m
//  n-Discovery
//
//  Created by Chang on 8/5/15.
//  Copyright (c) 2015 Kent State University. All rights reserved.
//

#import "NDLearnAsUGoListImageItem.h"

@implementation NDLearnAsUGoListImageItem

+ (NDLearnAsUGoListImageItem *)itemWithImageNamed:(NSString *)imageName
{
    NDLearnAsUGoListImageItem *item = [[NDLearnAsUGoListImageItem alloc] init];
    item.imageName = imageName;
    return item;
}

@end
