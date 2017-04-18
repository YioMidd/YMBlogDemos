//
//  CTDTableViewCell.m
//  CoreTextDemo
//
//  Created by KiBen on 2017/4/18.
//  Copyright © 2017年 KiBen. All rights reserved.
//

#import "CTDTableViewCell.h"
#import "UIButton+WebCache.h"

@interface CTDTableViewCell ()
@property (nonatomic, weak) UIView *bottomLine;
@property (nonatomic, weak) UIImageView *postBGView;
@property (nonatomic, weak) UIButton *avatarView;
@property (nonatomic, weak) UIImageView *connerImageV;
@property (nonatomic, weak) UIScrollView *multiPhotoScrollV;
@property (nonatomic, assign, getter=isDrawed) BOOL drawed;
@end

@implementation CTDTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        
        UIImageView *postBgView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:postBgView];
        self.postBGView = postBgView;
        
        UIButton *avatarView = [[UIButton alloc] initWithFrame:CGRectMake(SIZE_GAP_LEFT, SIZE_GAP_TOP, SIZE_AVATAR, SIZE_AVATAR)];
        [self.contentView addSubview:avatarView];
        self.avatarView = avatarView;
        
        UIView *bottomLine = [[UIView alloc] initWithFrame:CGRectMake(0, self.height - 0.5, [UIScreen screenWidth], 0.5)];
        bottomLine.backgroundColor = [UIColor blackColor];
        [self addSubview:bottomLine];
        self.bottomLine = bottomLine;
        
        UIScrollView *photoView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        photoView.showsVerticalScrollIndicator = NO;
        photoView.showsHorizontalScrollIndicator = NO;
        [self.contentView addSubview:photoView];
        self.multiPhotoScrollV = photoView;
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self.contentView bringSubviewToFront:self.bottomLine];
    self.bottomLine.y = self.height - 0.5;
}

- (void)setData:(NSDictionary *)data {
    _data = data;
    
    [self.avatarView setBackgroundImage:nil forState:UIControlStateNormal];
    NSString *avatarString = [data valueForKey:@"avatarUrl"];
    if (avatarString) {
        [self.avatarView sd_setBackgroundImageWithURL:[NSURL URLWithString:avatarString] forState:UIControlStateNormal placeholderImage:nil options:SDWebImageLowPriority];
    }
}

- (void)draw {
    if (self.isDrawed) {
        return;
    }
    self.drawed = YES;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGRect rect = [[self.data valueForKey:@"frame"] CGRectValue];
        UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
    });
}

- (void)clear {
    
}

- (void)releaseMemory {
    
}
@end
