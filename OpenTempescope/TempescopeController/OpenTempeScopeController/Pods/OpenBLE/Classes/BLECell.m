//
//  BLECell.m
//  OpenBLE
//
//  Created by Jacob on 1/13/14.
//  Copyright (c) 2014 Apple Inc. All rights reserved.
//

#import "BLECell.h"

@implementation BLECell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
