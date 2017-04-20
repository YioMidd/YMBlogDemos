//
//  CTDTableViewCell.m
//  CoreTextDemo
//
//  Created by KiBen on 2017/4/18.
//  Copyright © 2017年 KiBen. All rights reserved.
//

#import "CTDTableViewCell.h"
#import "UIButton+WebCache.h"
#import "NSString+Addition.h"
#import "CTDLabel.h"

@interface CTDTableViewCell ()
@property (nonatomic, weak) UIView *bottomLine;
@property (nonatomic, weak) UIImageView *postBGView;
@property (nonatomic, weak) UIButton *avatarView;
@property (nonatomic, weak) UIImageView *connerImageV;
@property (nonatomic, weak) UIScrollView *multiPhotoScrollV;
@property (nonatomic, assign, getter=isDrawed) BOOL drawed;
@property (nonatomic, assign) NSInteger drawColorFlag;

@property (nonatomic, weak) CTDLabel *dataLabel;
@property (nonatomic, weak) CTDLabel *subDataLabel;
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
        
        [self addLabel];
        
        UIImageView *connerImageV = [[UIImageView alloc] initWithFrame:avatarView.frame];
        connerImageV.image = [UIImage imageNamed:@"corner_circle@2x"];
        [self.contentView addSubview:connerImageV];
        
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

- (void)addLabel {
    if (self.dataLabel) {
        [self.dataLabel removeFromSuperview];
        self.dataLabel = nil;
    }
    
    CTDLabel *label = [[CTDLabel alloc] initWithFrame:[_data[@"textRect"] CGRectValue]];
//    label.textColor = [UIColor colorWithRed:50/255.0 green:50/255.0 blue:50/255.0 alpha:1];
    label.backgroundColor = self.backgroundColor;
    [self.contentView addSubview:label];
    self.dataLabel = label;
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
    NSInteger flag = self.drawColorFlag;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGRect rect = [[self.data valueForKey:@"frame"] CGRectValue];
        UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        [[UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1] set];
        CGContextFillRect(context, rect); // 画整个cell的背景
        
        if (_data[@"subData"]) {
            [[UIColor colorWithRed:243/255.0 green:243/255.0 blue:243/255.0 alpha:1] set];
            CGRect subDataRect = [_data[@"subData"][@"frame"] CGRectValue];
            CGContextFillRect(context, subDataRect); // 画原微博的背景
            [[UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1] set];
            CGContextFillRect(context, CGRectMake(0, subDataRect.origin.y, rect.size.width, 0.5)); // 画原微博顶部的分割线
        }
        
        // 画昵称跟来源
        {
            CGFloat nameX = SIZE_GAP_LEFT+SIZE_AVATAR+SIZE_GAP_BIG;
            CGFloat nameY = (SIZE_AVATAR-(SIZE_FONT_NAME+SIZE_FONT_SUBTITLE+6))/2-2+SIZE_GAP_TOP+SIZE_GAP_SMALL-5;
            [_data[@"name"] drawInContext:context withPosition:CGPointMake(nameX, nameY) andFont:FontWithSize(SIZE_FONT_NAME) andTextColor:[UIColor colorWithRed:106/255.0 green:140/255.0 blue:181/255.0 alpha:1] andHeight:rect.size.height];
            
            CGFloat fromX = nameX;
            CGFloat fromY = nameY + SIZE_FONT_NAME + 5;
            CGFloat fromWidth = [UIScreen screenWidth] - fromX;
            NSString *fromString = [NSString stringWithFormat:@"%@  %@",_data[@"time"], _data[@"from"]];
            [fromString drawInContext:context withPosition:CGPointMake(fromX, fromY) andFont:FontWithSize(SIZE_FONT_SUBTITLE) andTextColor:[UIColor colorWithRed:178/255.0 green:178/255.0 blue:178/255.0 alpha:1] andHeight:rect.size.height ];
        }
        
        // 画底部评论，转发
        {
            CGRect bottomRect = CGRectMake(0, rect.size.height - 30, [UIScreen screenWidth], 30);
            [[UIColor colorWithRed:250/255.0 green:250/255.0 blue:250/255.0 alpha:1] set];
            CGContextFillRect(context, bottomRect);
            
            CGFloat commentX = [UIScreen screenWidth] - SIZE_GAP_LEFT - 10;
            NSString *comment = _data[@"comments"];
            if (comment) {
                CGSize commentSize = [comment sizeWithConstrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) fromFont:FontWithSize(SIZE_FONT_SUBTITLE) lineSpace:5];
                commentX -= commentSize.width;
                [comment drawInContext:context withPosition:CGPointMake(commentX, bottomRect.origin.y + 8) andFont:FontWithSize(12) andTextColor:[UIColor colorWithRed:178/255.0 green:178/255.0 blue:178/255.0 alpha:1] andHeight:rect.size.height];
                
                [[UIImage imageNamed:@"t_comments.png"] drawInRect:CGRectMake(commentX - 5, bottomRect.origin.y + 10.5, 10, 9)];
            }
            
            CGFloat repostX = commentX - 20;
            NSString *repost = _data[@"reposts"];
            if (repost) {
                CGSize repostSize = [repost sizeWithConstrainedToSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) fromFont:FontWithSize(SIZE_FONT_SUBTITLE) lineSpace:5];
                repostX -= MAX(repostSize.width, 5) + SIZE_GAP_BIG;
                [repost drawInContext:context withPosition:CGPointMake(repostX, bottomRect.origin.y + 8) andFont:FontWithSize(12) andTextColor:[UIColor colorWithRed:178/255.0 green:178/255.0 blue:178/255.0 alpha:1] andHeight:rect.size.height];
                
                [[UIImage imageNamed:@"t_repost.png"] drawInRect:CGRectMake(repostX - 5, bottomRect.origin.y + 11, 10, 9)];
                
            }
            
            [@"•••" drawInContext:context withPosition:CGPointMake(SIZE_GAP_LEFT, bottomRect.origin.y + 8) andFont:FontWithSize(11) andTextColor:[UIColor colorWithRed:178/255.0 green:178/255.0 blue:178/255.0 alpha:0.5] andHeight:rect.size.height];
            
            if (_data[@"subData"]) {
                [[UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1] set];
                CGContextFillRect(context, CGRectMake(0, bottomRect.origin.y, bottomRect.size.width, 0.5));
            }
        }
        UIImage *bgImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_main_queue(), ^{
            if (flag == self.drawColorFlag) {
                self.postBGView.frame = rect;
                self.postBGView.image = nil;
                self.postBGView.image = bgImage;
            }
        });
    });
    [self drawText];
}

- (void)drawText {
    if (self.dataLabel == nil) {
        [self addLabel];
    }
    self.dataLabel.frame = [_data[@"textRect"] CGRectValue];
    [self.dataLabel setText:_data[@"text"]];
    
}

- (void)clear {
    if (!self.drawed) {
        NSLog(@"进来了");
        return;
    }
    self.postBGView.frame = CGRectZero;
    self.postBGView.image = nil;
    self.drawColorFlag = arc4random();
    self.drawed = NO;
}

- (void)releaseMemory {
    
}
@end
