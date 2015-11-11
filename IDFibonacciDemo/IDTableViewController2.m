//
//  IDTableViewController.m
//  IDFibonacciDemo
//
//  Created by Igor Dorofix on 10.11.15.
//  Copyright © 2015 Igor Dorofix. All rights reserved.
//

#import "IDTableViewController2.h"

#import "IGTableViewCell.h"
#import "IGIdenticon.h"

@interface IDTableViewController2 ()

@property (nonatomic, strong) NSMutableArray *numbers;
@property (nonatomic, strong) IGImageGenerator *simpleIdenticonsGenerator;
@property (nonatomic, strong) dispatch_queue_t backgroundQueue;

@end

@implementation IDTableViewController2

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.backgroundQueue = dispatch_queue_create("background_queue", nil);
    self.simpleIdenticonsGenerator = [[IGImageGenerator alloc] initWithImageProducer:[IGSimpleIdenticon new] hashFunction:IGJenkinsHashFromData];
    self.numbers = [NSMutableArray arrayWithArray:@[@(1),@(1)]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return UINT16_MAX;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IDCell" forIndexPath:indexPath];
    return cell;
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger row = indexPath.row;
    cell.textLabel.text = [NSString stringWithFormat:@"%i", row+1];
    __block unsigned long long fibo;
    
    IGTableViewCell *igCell = (IGTableViewCell *)cell;
    igCell.currentRow = row;
    __weak __typeof(igCell) weakCell = igCell;
    
    if (row < [self.numbers count]) {
        fibo = [self.numbers[row] unsignedLongLongValue];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%llu", fibo];
        dispatch_async(self.backgroundQueue, ^{
            [self updateCellImage:weakCell forRow:row withFibo:fibo];
        });
    }
    else {
        dispatch_async(self.backgroundQueue, ^{
            fibo = [self fibonacci:row];
            if (weakCell.currentRow == row){
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakCell.detailTextLabel.text = [NSString stringWithFormat:@"%llu", fibo];
                });
                [self updateCellImage:weakCell forRow:row withFibo:fibo];
            }
        });
    }
}

- (void)updateCellImage:(IGTableViewCell *)cell forRow:(NSUInteger)row withFibo:(unsigned long long)fibo{
    UIImage *img = [self.simpleIdenticonsGenerator imageFromUInt32:(unsigned int)fibo size:CGSizeMake(44, 44)];
    if (cell.currentRow == row){
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.imageView.image = img;
        });
    }
}

- (unsigned long long)fibonacci:(NSUInteger)n {
    unsigned long long f;
    
    if (n < [self.numbers count]) {
        f = [self.numbers[n] unsignedLongLongValue];
    }
    else {
        f = [self fibonacci:(n-2)] + [self fibonacci:(n-1)];
        [self.numbers addObject:@(f)];
    }
    
    return f;
}

@end