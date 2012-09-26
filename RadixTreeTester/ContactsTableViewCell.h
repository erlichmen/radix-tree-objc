//
//  ContactsTableViewCell.h
//  RadixTreeTester
//
//  Created by Shay Erlichmen on 26/09/12.
//  Copyright (c) 2012 erlichmen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ContactsTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) IBOutlet UILabel *phoneLabel;

@end
