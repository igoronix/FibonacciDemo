//
//  IDTableViewController.m
//  IDFibonacciDemo
//
//  Created by Igor Dorofix on 10.11.15.
//  Copyright © 2015 Igor Dorofix. All rights reserved.
//

#import "IDTableViewController.h"

#import "IGIdenticon.h"

@interface IDTableViewController ()

@property (nonatomic, strong) NSMutableArray *numbers;
@property (nonatomic, strong) IGImageGenerator *simpleIdenticonsGenerator;

@property (nonatomic, strong) NSMutableArray *icons;

@end

@implementation IDTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.numbers = [NSMutableArray arrayWithCapacity:UINT16_MAX];
//    self.icons = [NSMutableArray arrayWithCapacity:UINT16_MAX];
    
    self.simpleIdenticonsGenerator = [[IGImageGenerator alloc] initWithImageProducer:[IGSimpleIdenticon new] hashFunction:IGJenkinsHashFromData];
    
    dispatch_async(dispatch_queue_create("Fibonacci queue", 0), ^{
        NSUInteger f1 = 1; // seed value 1
        NSUInteger f2 = 0; // seed value 2
        NSUInteger fn; // used as a holder for each new value in the loop
        
        for (NSUInteger i = 0; i < UINT16_MAX; i++){
            fn = f1 + f2;
            f1 = f2;
            f2 = fn;
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.numbers addObject:@(fn)];
                
                NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
                NSArray *visibleRows = [visiblePaths valueForKey:@"row"];
                if ([visibleRows containsObject:@(i)]){
                    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
                }
            });
        }
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    NSLog(@"IDTableViewController didReceiveMemoryWarning");
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return UINT16_MAX;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IDCell" forIndexPath:indexPath];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    cell.textLabel.text = [NSString stringWithFormat:@"%i", indexPath.row];
    if ([self.numbers count] > indexPath.row){
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", self.numbers[indexPath.row]];
        NSUInteger number = [self.numbers[indexPath.row] integerValue];
        cell.imageView.image = [self.simpleIdenticonsGenerator imageFromUInt32:number size:CGSizeMake(44, 44)];
    }
    else{
        cell.detailTextLabel.text = @"Processing";
    }
}

@end
