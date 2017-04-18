//
//  CTDTableViewCell.m
//  CoreTextDemo
//
//  Created by KiBen on 2017/4/18.
//  Copyright © 2017年 KiBen. All rights reserved.
//

#import "CTDTableViewCell.h"

@interface CTDTableViewCell ()
@property (nonatomic, weak) UIView *bottomLine;
@end
@implementation CTDTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.textLabel.text = @"这只是测试数据";
        
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - 0.5, [UIScreen screenWidth], 0.5)];
        bottomLine.backgroundColor = [UIColor blackColor];
        [self addSubview:bottomLine];
        self.bottomLine = bottomLine;
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self.contentView bringSubviewToFront:self.bottomLine];
    self.bottomLine.y = self.height - 0.5;
}

- (void)setData:(NSDictionary *)data {
    
}
@end
