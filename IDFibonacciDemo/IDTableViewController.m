//
//  IDTableViewController2.m
//  IDFibonacciDemo
//
//  Created by Igor Dorofix on 10.11.15.
//  Copyright © 2015 Igor Dorofix. All rights reserved.
//

#import "IDTableViewController.h"

#import "IGTableViewCell.h"
#import "IGIdenticon.h"

@interface IDTableViewController ()

@property (nonatomic, strong) NSMutableArray *numbers;
@property (nonatomic, strong) IGImageGenerator *simpleIdenticonsGenerator;

@end

@implementation IDTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.numbers = [NSMutableArray arrayWithCapacity:UINT16_MAX];
    self.simpleIdenticonsGenerator = [[IGImageGenerator alloc] initWithImageProducer:[IGSimpleIdenticon new] hashFunction:IGJenkinsHashFromData];
    
    dispatch_async(dispatch_queue_create("Fibonacci queue", 0), ^{
        unsigned long long f1 = 1; // seed value 1
        unsigned long long f2 = 0; // seed value 2
        unsigned long long fn; // used as a holder for each new value in the loop
        
        for (NSUInteger i = 0; i < UINT16_MAX; i++){
            fn = f1 + f2;
            f1 = f2;
            f2 = fn;
            
            [self.numbers addObject:@(fn)];
        }
        NSLog(@"=============DidFinish calculating = count=%lu", (unsigned long)[self.numbers count]);
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

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    NSUInteger row = indexPath.row;
    
    cell.textLabel.text = [NSString stringWithFormat:@"%i", row+1];
    if ([self.numbers count] > row){
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", self.numbers[row]];
        
        unsigned long long number = [self.numbers[row] unsignedLongLongValue];
        
        IGTableViewCell *igCell = (IGTableViewCell *)cell;
        igCell.currentRow = row;
        __weak __typeof(igCell) weakCell = igCell;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *img = [self.simpleIdenticonsGenerator imageFromUInt32:(unsigned int)number size:CGSizeMake(44, 44)];
            if (weakCell.currentRow == row){
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakCell.imageView.image = img;
                });
            }
        });
    }
    else{
        cell.detailTextLabel.text = @"Processing";
    }
}

@end
