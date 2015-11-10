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
{
    NSInteger _maxN;
    dispatch_queue_t _backgroundQueue;
}

@property (nonatomic, strong) NSMutableArray *tableData;
@property (nonatomic, strong) IGImageGenerator *simpleIdenticonsGenerator;

@end

@implementation IDTableViewController2

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"Max Integer: %ld", NSIntegerMax);
    
    _maxN = UINT16_MAX;
    
    _backgroundQueue = dispatch_queue_create("background queue", nil);
    
    self.simpleIdenticonsGenerator = [[IGImageGenerator alloc] initWithImageProducer:[IGSimpleIdenticon new] hashFunction:IGJenkinsHashFromData];
    
    [self loadData];
}


- (void)loadData
{
    _tableData = [NSMutableArray arrayWithArray:@[@(1),@(1)]];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _maxN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"IDCell" forIndexPath:indexPath];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger row = indexPath.row;
    cell.textLabel.text = [NSString stringWithFormat:@"%i", row+1];
    __block unsigned long long fibo;
    
    IGTableViewCell *igCell = (IGTableViewCell *)cell;
    igCell.currentRow = row;
    
    if ( row < [_tableData count] ) {
        fibo = [_tableData[row] integerValue];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%llu", fibo];
        __weak __typeof(igCell) weakCell = igCell;
        dispatch_async(_backgroundQueue, ^{
            UIImage *img = [self.simpleIdenticonsGenerator imageFromUInt32:(unsigned int)fibo size:CGSizeMake(44, 44)];
            if (weakCell.currentRow == row){
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakCell.imageView.image = img;
                });
            }
        });

    }
    else {
        __weak __typeof(igCell) weakCell = igCell;
        
        dispatch_async(_backgroundQueue, ^{
            fibo = [self fibo:row];
            if (weakCell.currentRow == row){
                dispatch_async(dispatch_get_main_queue(), ^{
                    weakCell.detailTextLabel.text = [NSString stringWithFormat:@"%llu", fibo];
                });
                UIImage *img = [self.simpleIdenticonsGenerator imageFromUInt32:(unsigned int)fibo size:CGSizeMake(44, 44)];
                if (weakCell.currentRow == row){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakCell.imageView.image = img;
                    });
                }
            }
        });
    }
}

- (unsigned long long)fibo:(NSUInteger)n {
    unsigned long long f;
    
    if ( n < [_tableData count] ) {
        f = [_tableData[n] unsignedLongLongValue];
    }
    else {
        f = [self fibo:(n-2)] + [self fibo:(n-1)];
        [_tableData addObject:@(f)];
    }
    
    return f;
}

@end