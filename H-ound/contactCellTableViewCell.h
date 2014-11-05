//
//  contactCellTableViewCell.h
//  H-ound
//
//  Created by Matteo Comisso on 10/07/14.
//  Copyright (c) 2014 Blue-Mate. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface contactCellTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *contactName;
@property (strong, nonatomic) IBOutlet UIImageView *contactImage;
@property (strong, nonatomic) IBOutlet UILabel *statusOfUser;

@end
