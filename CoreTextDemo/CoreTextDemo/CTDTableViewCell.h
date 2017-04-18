//
//  CTDTableViewCell.h
//  CoreTextDemo
//
//  Created by KiBen on 2017/4/18.
//  Copyright © 2017年 KiBen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CTDTableViewCell : UITableViewCell
@property (nonatomic, copy) NSDictionary *data;

- (void)draw;
- (void)clear;
- (void)releaseMemory;
@end
