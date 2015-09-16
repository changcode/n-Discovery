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
@property (strong, readwrite, nonatomic) RETextItem *openAnswerOptions;

@property (assign, readwrite, nonatomic) NSUInteger *atIndexOfQuestion;

@end

@implementation NDQuestionTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [NSString stringWithFormat:@"Number: %d", [_QuestionData count]];
    _manager = [[RETableViewManager alloc] initWithTableView:self.tableView delegate:self];
    if ([_QuestionData count]) {
        _quesitonSection = [self addQuestionSection];
        _answerSection = [self addAnswerSection];
    }
}

- (RETableViewSection *)addQuestionSection {
    
    _manager[@"MultilineTextItem"] = @"MultilineTextCell";
    
    RETableViewSection *section = [RETableViewSection sectionWithHeaderTitle:@"Question"];
    
    [section addItem:[MultilineTextItem itemWithTitle: _QuestionData != nil ? _QuestionData[0][@"q_description"] : @"EMPTY" ]];
    
    [_manager addSection:section];
    return section;
}

- (RETableViewSection *)addAnswerSection {
    __typeof (&*self) __weak weakSelf = self;
    
    RETableViewSection *section = [RETableViewSection sectionWithHeaderTitle:@"Answer"];
    
    if ([_QuestionData[0][@"q_type"] isEqualToString:@"multi"]) {
        _multiAnswerOptions = [REMultipleChoiceItem itemWithTitle:@"Options" value:@[@"Option 2", @"Option 4"] selectionHandler:^(REMultipleChoiceItem *item) {
            [item deselectRowAnimated:YES];
            
            // Generate sample options
            //
            NSMutableArray *options = [NSMutableArray arrayWithArray:_QuestionData[0][@"q_options"]];
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
    }
    if ([_QuestionData[0][@"q_type"] isEqualToString:@"single"]) {
        _singleAnswerOptions = [RERadioItem itemWithTitle:@"Answer" value:nil
                                         selectionHandler:^(RERadioItem *item) {
                                             [item deselectRowAnimated:YES];
                                             // Generate sample options
                                             //
                                             NSMutableArray *options = [NSMutableArray arrayWithArray:_QuestionData[0][@"q_options"]];
                                             
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
    if ([_QuestionData[0][@"q_type"] isEqualToString:@"open"]) {
        
        _openAnswerOptions = [RETextItem itemWithTitle:nil value:nil placeholder:@"Enter your think here"];
        [section addItem:_openAnswerOptions];
    }
    
    RETableViewItem *buttonItem = [RETableViewItem itemWithTitle:@"Submit" accessoryType:UITableViewCellAccessoryNone selectionHandler:^(RETableViewItem *item) {
        item.title = @"OK!";
        [item reloadRowWithAnimation:UITableViewRowAnimationAutomatic];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    buttonItem.textAlignment = NSTextAlignmentCenter;
    [section addItem:buttonItem];
    
    [_manager addSection:section];
    return section;
}
@end
