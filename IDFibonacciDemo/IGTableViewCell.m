//
//  IGTableViewCell.m
//  IDFibonacciDemo
//
//  Created by Igor Dorofix on 10.11.15.
//  Copyright © 2015 Igor Dorofix. All rights reserved.
//

#import "IGTableViewCell.h"

@implementation IGTableViewCell

- (void)prepareForReuse{
    self.imageView.image = nil;
}

@end
