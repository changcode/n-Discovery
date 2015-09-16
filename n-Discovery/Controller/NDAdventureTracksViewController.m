//
//  NDAdventureTracksViewController.m
//  n-Discovery
//
//  Created by Chang on 9/14/15.
//  Copyright (c) 2015 Kent State University. All rights reserved.
//

#import "NDAdventureTracksViewController.h"
#import "JBParallaxCell.h"
#import "SLParallaxController.h"

@interface NDAdventureTracksViewController ()<UIScrollViewDelegate>
@property (strong, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (nonatomic, strong) NSArray *tableItems;
@property (nonatomic, strong) NSArray *titleItems;
@property (nonatomic, strong) NSArray *subtitleItems;

@property (strong, nonatomic) NSArray *hardCode;
@end

@implementation NDAdventureTracksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_menuButton setAction:@selector(presentLeftMenuViewController:)];
    // Load the items in the table
    self.tableItems = @[[UIImage imageNamed:@"demo_1.jpg"],
                        [UIImage imageNamed:@"demo_2.jpg"],
                        [UIImage imageNamed:@"demo_3.jpg"],
                        [UIImage imageNamed:@"demo_4.png"],
                        [UIImage imageNamed:@"demo_1.jpg"],
                        [UIImage imageNamed:@"demo_2.jpg"],
                        [UIImage imageNamed:@"demo_3.jpg"],
                        [UIImage imageNamed:@"demo_4.png"],
                        [UIImage imageNamed:@"demo_3.jpg"],
                        [UIImage imageNamed:@"demo_2.jpg"],
                        [UIImage imageNamed:@"demo_1.jpg"],
                        [UIImage imageNamed:@"demo_4.png"]];
    self.hardCode = @[@"ledges_weathering_questions.json",@"discover_fallcolors.json",@"ledges_microhabitat.json"];
    
    self.titleItems = @[@"Ledges Weathering", @"Fall Color", @"Ledges Mircohabitat", @"Coming", @"Coming", @"Coming", @"Coming", @"Coming", @"Coming", @"Coming", @"Coming", @"Coming"];
    self.subtitleItems = @[@"Ledges Weathering", @"Fall Color", @"Ledges Mircohabitat", @"Coming", @"Coming", @"Coming", @"Coming", @"Coming", @"Coming", @"Coming", @"Coming", @"Coming" ];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self scrollViewDidScroll:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"parallaxCell";
    JBParallaxCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.titleLabel.text = [self.titleItems objectAtIndex:indexPath.row];
    cell.subtitleLabel.text = [self.subtitleItems objectAtIndex:indexPath.row];
    cell.parallaxImage.image = self.tableItems[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2) {
//        [self.navigationController pushViewController:[SLParallaxController new] animated:YES];
        self.hidesBottomBarWhenPushed = YES;
        [self performSegueWithIdentifier:@"test" sender:self.hardCode[indexPath.row]];
        self.hidesBottomBarWhenPushed = NO;
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"ForthComing!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK!", nil];
        [alert show];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"test"]) {
        SLParallaxController *vc = segue.destinationViewController;
        vc.jsonfile = (NSString *)sender;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    // Get visible cells on table view.
    NSArray *visibleCells = [self.tableView visibleCells];
    
    for (JBParallaxCell *cell in visibleCells) {
        [cell cellOnTableView:self.tableView didScrollOnView:self.view];
    }
}


@end
