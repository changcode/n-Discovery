//
//  NDQuestionSingleTableViewController.h
//  n-Discovery
//
//  Created by Chang on 9/15/15.
//  Copyright (c) 2015 Kent State University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RETableViewManager.h"

@interface NDQuestionTableViewController : UITableViewController <RETableViewManagerDelegate>

@property (strong, readonly, nonatomic) RETableViewManager *manager;

@property (strong, readonly, nonatomic) RETableViewSection *quesitonSection;
@property (strong, readonly, nonatomic) RETableViewSection *answerSection;

@property (strong, readwrite, nonatomic) NSArray *QuestionData;
@property (strong, readwrite, nonatomic) NSDictionary *UserData;

@end
