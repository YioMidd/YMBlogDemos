//
//  CTDLabel.m
//  CoreTextDemo
//
//  Created by KiBen Hung on 2017/4/20.
//  Copyright © 2017年 KiBen. All rights reserved.
//

#import "CTDLabel.h"

#define kRegexHighlightViewTypeURL @"url"
#define kRegexHighlightViewTypeAccount @"account"
#define kRegexHighlightViewTypeTopic @"topic"
#define kRegexHighlightViewTypeEmoji @"emoji"


@interface CTDLabel ()
@property (nonatomic, assign) NSInteger drawFlag;
@property (nonatomic, strong) NSMutableDictionary *frameDict;
@property (nonatomic, strong) NSMutableDictionary *highlightColorsDict;

@property (nonatomic, weak) UIImageView *labelImageView;
@end

@implementation CTDLabel

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        self.drawFlag = arc4random();
        self.frameDict = [NSMutableDictionary dictionary];
        UIColor *highlightColor = [UIColor colorWithRed:106/255.0 green:140/255.0 blue:181/255.0 alpha:1];
        self.highlightColorsDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:highlightColor, kRegexHighlightViewTypeAccount, highlightColor, kRegexHighlightViewTypeURL, highlightColor, kRegexHighlightViewTypeEmoji, highlightColor, kRegexHighlightViewTypeTopic, nil];
        
        UIImageView *labelImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        labelImageView.image = [UIImage imageNamed:@"t_repost.png"];
        [self addSubview:labelImageView];
        self.labelImageView = labelImageView;
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    self.labelImageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

- (void)setText:(NSString *)text {
    _text = text;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIGraphicsBeginImageContextWithOptions(self.frame.size, ![self.backgroundColor isEqual:[UIColor clearColor]], 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        if (![self.backgroundColor isEqual:[UIColor clearColor]]) {
            [self.backgroundColor set];
            CGContextFillRect(context, CGRectMake(0, 0, self.width, self.height));
        }
        
//        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
//        CGContextTranslateCTM(context, 0, self.height);
//        CGContextScaleCTM(context, 1.0, -1.0);
        
        NSTextAlignment textAlignment = NSTextAlignmentLeft;
        UIColor *textColor = [UIColor blackColor];
        UIFont *textFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
        CGFloat lineSpace = 5;
        
        [self.text drawInContext:context withPosition:CGPointMake(SIZE_GAP_LEFT, SIZE_GAP_TOP) andFont:textFont andTextColor:textColor andHeight:self.height];
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        dispatch_async(dispatch_get_main_queue(), ^{
//            self.layer.contents = image;
//            self.labelImageView.image = image;
        });
    });
}
@end
