//
//  NDQuestionSingleTableViewController.m
//  n-Discovery
//
//  Created by Chang on 9/15/15.
//  Copyright (c) 2015 Kent State University. All rights reserved.
//

#import "NDQuestionTableViewController.h"
#import "MultilineTextItem.h"
#import "RETableViewOptionsController.h"

@interface NDQuestionTableViewController ()

@property (strong, readwrite, nonatomic) RETableViewManager *manager;
@property (strong, readwrite, nonatomic) RETableViewSection *quesitonSection;
@property (strong, readwrite, nonatomic) RETableViewSection *answerSection;

@property (strong, readwrite, nonatomic) MultilineTextItem *questionItem;
@property (strong, readwrite, nonatomic) RERadioItem *singleAnswerOptions;
@property (strong, readwrite, nonatomic) REMultipleChoiceItem *multiAnswerOptions;


@end

@implementation NDQuestionTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Question for you";
    _manager = [[RETableViewManager alloc] initWithTableView:self.tableView delegate:self];
    _quesitonSection = [self addQuestionSection];
    _answerSection = [self addAnswerSection];
}

- (RETableViewSection *)addQuestionSection {
    
    _manager[@"MultilineTextItem"] = @"MultilineTextCell";
    
    RETableViewSection *section = [RETableViewSection sectionWithHeaderTitle:@"Question"];
    
    [section addItem:[MultilineTextItem itemWithTitle:@"Custom item / cell example. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam sem leo, malesuada tempor metus et, elementum pulvinar nibh.Custom item / cell example. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam sem leo, malesuada tempor metus et, elementum pulvinar nibh.Custom item / cell example. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam sem leo, malesuada tempor metus et, elementum pulvinar nibh.Custom item / cell example. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam sem leo, malesuada tempor metus et, elementum pulvinar nibh."]];
    
    [_manager addSection:section];
    return section;
}

- (RETableViewSection *)addAnswerSection {
    __typeof (&*self) __weak weakSelf = self;
    
    RETableViewSection *section = [RETableViewSection sectionWithHeaderTitle:@"Answer"];
    
    if (true) {
        _multiAnswerOptions = [REMultipleChoiceItem itemWithTitle:nil value:@[@"Option 2", @"Option 4"] selectionHandler:^(REMultipleChoiceItem *item) {
            [item deselectRowAnimated:YES];
            
            // Generate sample options
            //
            NSMutableArray *options = [[NSMutableArray alloc] init];
            for (NSInteger i = 1; i < 40; i++)
                [options addObject:[NSString stringWithFormat:@"Option %li", (long) i]];
            
            // Present options controller
            //
            RETableViewOptionsController *optionsController = [[RETableViewOptionsController alloc] initWithItem:item options:options multipleChoice:YES completionHandler:^(RETableViewItem *selectedItem){
                [item reloadRowWithAnimation:UITableViewRowAnimationNone];
                NSLog(@"parent: %@, child: %@", item.value, selectedItem.title);
            }];
            
            // Adjust styles
            //
            optionsController.delegate = weakSelf;
            optionsController.style = section.style;
            if (weakSelf.tableView.backgroundView == nil) {
                optionsController.tableView.backgroundColor = weakSelf.tableView.backgroundColor;
                optionsController.tableView.backgroundView = nil;
            }
            
            // Push the options controller
            //
            [weakSelf.navigationController pushViewController:optionsController animated:YES];
        }];
        [section addItem:_multiAnswerOptions];
    } else {
        _singleAnswerOptions = [RERadioItem itemWithTitle:@"Answer" value:nil
                                         selectionHandler:^(RERadioItem *item) {
                                             [item deselectRowAnimated:YES];
                                             // Generate sample options
                                             //
                                             NSMutableArray *options = [[NSMutableArray alloc] init];
                                             for (NSInteger i = 1; i < 40; i++)
                                                 [options addObject:[NSString stringWithFormat:@"Option %li", (long) i]];
                                             
                                             // Present options controller
                                             //
                                             RETableViewOptionsController *optionsController = [[RETableViewOptionsController alloc] initWithItem:item options:options multipleChoice:NO completionHandler:^(RETableViewItem *selectedItem){
                                                 [weakSelf.navigationController popViewControllerAnimated:YES];
                                                 
                                                 [item reloadRowWithAnimation:UITableViewRowAnimationNone]; // same as [weakSelf.tableView reloadRowsAtIndexPaths:@[item.indexPath] withRowAnimation:UITableViewRowAnimationNone];
                                             }];
                                             
                                             // Adjust styles
                                             //
                                             optionsController.delegate = weakSelf;
                                             optionsController.style = section.style;
                                             if (weakSelf.tableView.backgroundView == nil) {
                                                 optionsController.tableView.backgroundColor = weakSelf.tableView.backgroundColor;
                                                 optionsController.tableView.backgroundView = nil;
                                             }
                                             
                                             // Push the options controller
                                             //
                                             [weakSelf.navigationController pushViewController:optionsController animated:YES];
                                         }];
        [section addItem:_singleAnswerOptions];
    }
    [_manager addSection:section];
    return section;
}
@end
