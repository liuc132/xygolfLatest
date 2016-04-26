//
//  CustomTableViewCell.h
//  xygolf
//
//  Created by LiuC on 16/4/26.
//  Copyright © 2016年 dreamer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomTableViewCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UILabel *holeName;
@property (weak, nonatomic) IBOutlet UILabel *holeState;
@property (weak, nonatomic) IBOutlet UILabel *holeCount;
@property (weak, nonatomic) IBOutlet UIButton *holeMoreInfoButton;




@end
