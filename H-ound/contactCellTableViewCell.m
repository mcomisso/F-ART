//
//  contactCellTableViewCell.m
//  H-ound
//
//  Created by Matteo Comisso on 10/07/14.
//  Copyright (c) 2014 Blue-Mate. All rights reserved.
//

#import "contactCellTableViewCell.h"
#import <POP/POP.h>

@implementation contactCellTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

-(void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    if (highlighted) {
        [super setHighlighted:highlighted animated:animated];
        
        POPSpringAnimation *springAnimation = [POPSpringAnimation animation];
        springAnimation.delegate = self;
        springAnimation.property = [POPAnimatableProperty propertyWithName:kPOPLayerScaleXY];
        springAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(0.9, 0.9)];
        springAnimation.name = @"tapAnimation";
        springAnimation.springSpeed = 1;
        springAnimation.springBounciness = 15;
        
        [self.layer pop_addAnimation:springAnimation forKey:@"tapDown"];
    }
    else
    {
        POPSpringAnimation *springAnimation = [POPSpringAnimation animation];
        springAnimation.delegate = self;
        springAnimation.property = [POPAnimatableProperty propertyWithName:kPOPLayerScaleXY];
        springAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1, 1)];
        springAnimation.name = @"selectedAnimation";
        springAnimation.springSpeed = 3;
        springAnimation.springBounciness = 10;
        
        [self.layer pop_addAnimation:springAnimation forKey:@"selected"];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state

    if (selected) {
        POPSpringAnimation *springAnimation = [POPSpringAnimation animation];
        springAnimation.delegate = self;
        springAnimation.property = [POPAnimatableProperty propertyWithName:kPOPLayerScaleXY];
        springAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1, 1)];
        springAnimation.name = @"selectedAnimation";
        springAnimation.springSpeed = 3;
        springAnimation.springBounciness = 10;
        
        [self.layer pop_addAnimation:springAnimation forKey:@"selected"];

    }
    else
    {
        POPSpringAnimation *springAnimation = [POPSpringAnimation animation];
        springAnimation.delegate = self;
        springAnimation.property = [POPAnimatableProperty propertyWithName:kPOPLayerScaleXY];
        springAnimation.toValue = [NSValue valueWithCGSize:CGSizeMake(1, 1)];
        springAnimation.name = @"unSelectedAnimation";
        springAnimation.springSpeed = 3;
        springAnimation.springBounciness = 10;
        
        [self.layer pop_addAnimation:springAnimation forKey:@"selected"];
    }
}

@end
