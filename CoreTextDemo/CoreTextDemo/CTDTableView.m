//
//  CTDTableView.m
//  CoreTextDemo
//
//  Created by KiBen on 2017/4/18.
//  Copyright © 2017年 KiBen. All rights reserved.
//

#import "CTDTableView.h"
#import "CTDTableViewCell.h"

@interface CTDTableView () <UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *datas;
    NSMutableArray *needLoadArr;
}
@end

@implementation CTDTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    if (self = [super initWithFrame:frame style:style]) {
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.dataSource = self;
        self.delegate = self;
        
        datas = [NSMutableArray array];
        needLoadArr = [NSMutableArray array];
        [self loadData];
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"%s",__func__);
    CTDTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CTDTableViewCell class])];
    if (!cell) {
        cell = [[CTDTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([CTDTableViewCell class])];
    }
//    cell.textLabel.text = [NSString stringWithFormat:@"indexPath row ---- %ld", indexPath.row];
    [self drawCell:cell forIndexPath:indexPath];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *data = [datas objectAtIndex:indexPath.row];
    CGRect frame = [data[@"frame"] CGRectValue];
    return frame.size.height;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [needLoadArr removeAllObjects];
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    return YES;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
//    [self loadContent];
    NSLog(@"%s", __func__);
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    NSLog(@"%s", __func__);
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    
    NSIndexPath *targetIndexPath = [self indexPathForRowAtPoint:*targetContentOffset];
    NSArray *indexPaths = [self indexPathsForVisibleRows];
    NSIndexPath *firstIndexPath = [indexPaths firstObject];
    NSInteger skipCount = 8;
    NSLog(@"velocity: %@  targetContentOffset:%@ targetIndexPath:%@ visibleFirstIndex:%@", NSStringFromCGPoint(velocity), NSStringFromCGPoint(*targetContentOffset), targetIndexPath, firstIndexPath);
    if (labs(targetIndexPath.row - firstIndexPath.row) > skipCount) {
        NSArray *temp = [self indexPathsForRowsInRect:CGRectMake(0, targetContentOffset->y, self.width, self.height)];
        NSMutableArray *visiIndexPaths = [NSMutableArray arrayWithArray:temp];
        if (velocity.y < 0) { // 向上滚动
            NSIndexPath *indexPath = [temp lastObject];
            if (indexPath.row + 3 < datas.count) {
                [visiIndexPaths addObject:[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0]];
                [visiIndexPaths addObject:[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0]];
                [visiIndexPaths addObject:[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0]];
            }
        }else {  // 向下滚动
            NSIndexPath *indexPath = [temp firstObject];
            if (indexPath.row > 3) {
                [visiIndexPaths addObject:[NSIndexPath indexPathForRow:indexPath.row-3 inSection:0]];
                [visiIndexPaths addObject:[NSIndexPath indexPathForRow:indexPath.row-2 inSection:0]];
                [visiIndexPaths addObject:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:0]];
            }
        }
        [needLoadArr addObjectsFromArray:visiIndexPaths];
    }
}

- (void)drawCell:(CTDTableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *data = [datas objectAtIndex:indexPath.row];
    [cell clear];
    cell.data = data;
    if (needLoadArr.count > 0 && [needLoadArr indexOfObject:indexPath] == NSNotFound) {
        [cell clear];
        return;
    }
    [cell draw];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    [needLoadArr removeAllObjects];
    [self loadContent];
    return [super hitTest:point withEvent:event];
}

- (void)loadContent {
    if (self.indexPathsForVisibleRows.count <= 0) {
        return;
    }
    if (self.visibleCells && self.visibleCells.count > 0) {
        for (CTDTableViewCell *cell in self.visibleCells) {
            [cell draw];
        }
    }
}

//读取信息
- (void)loadData{
    NSArray *temp = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"data" ofType:@"plist"]];
    for (NSDictionary *dict in temp) {
        NSDictionary *user = dict[@"user"];
        NSMutableDictionary *data = [NSMutableDictionary dictionary];
        data[@"avatarUrl"] = user[@"avatar_large"];
        data[@"name"] = user[@"screen_name"];
        NSString *from = [dict valueForKey:@"source"];
        if (from.length>6) {
            NSInteger start = [from indexOf:@"\">"]+2;
            NSInteger end = [from indexOf:@"</a>"];
            from = [from substringFromIndex:start toIndex:end];
        } else {
            from = @"未知";
        }
        data[@"time"] = @"2015-05-25";
        data[@"from"] = from;
        [self setCommentsFrom:dict toData:data];
        [self setRepostsFrom:dict toData:data];
        data[@"text"] = dict[@"text"];
        
        NSDictionary *retweet = [dict valueForKey:@"retweeted_status"];
        if (retweet) {
            NSMutableDictionary *subData = [NSMutableDictionary dictionary];
            NSDictionary *user = retweet[@"user"];
            subData[@"avatarUrl"] = user[@"avatar_large"];
            subData[@"name"] = user[@"screen_name"];
            subData[@"text"] = [NSString stringWithFormat:@"@%@: %@", subData[@"name"], retweet[@"text"]];
            [self setPicUrlsFrom:retweet toData:subData];
            
            {
                float width = [UIScreen screenWidth]-SIZE_GAP_LEFT*2;
                CGSize size = [subData[@"text"] sizeWithConstrainedToWidth:width fromFont:FontWithSize(SIZE_FONT_SUBCONTENT) lineSpace:5];
                NSInteger sizeHeight = (size.height+.5);
                subData[@"textRect"] = [NSValue valueWithCGRect:CGRectMake(SIZE_GAP_LEFT, SIZE_GAP_BIG, width, sizeHeight)];
                sizeHeight += SIZE_GAP_BIG;
                if (subData[@"pic_urls"] && [subData[@"pic_urls"] count]>0) {
                    sizeHeight += (SIZE_GAP_IMG+SIZE_IMAGE+SIZE_GAP_IMG);
                }
                sizeHeight += SIZE_GAP_BIG;
                subData[@"frame"] = [NSValue valueWithCGRect:CGRectMake(0, 0, [UIScreen screenWidth], sizeHeight)];
            }
            data[@"subData"] = subData;
        } else {
            [self setPicUrlsFrom:dict toData:data];
        }
        
        {
            float width = [UIScreen screenWidth]-SIZE_GAP_LEFT*2;
            CGSize size = [data[@"text"] sizeWithConstrainedToWidth:width fromFont:FontWithSize(SIZE_FONT_CONTENT) lineSpace:5];
            NSInteger sizeHeight = (size.height+.5);
            data[@"textRect"] = [NSValue valueWithCGRect:CGRectMake(SIZE_GAP_LEFT, SIZE_GAP_TOP+SIZE_AVATAR+SIZE_GAP_BIG, width, sizeHeight)];
            sizeHeight += SIZE_GAP_TOP+SIZE_AVATAR+SIZE_GAP_BIG;
            if (data[@"pic_urls"] && [data[@"pic_urls"] count]>0) {
                sizeHeight += (SIZE_GAP_IMG+SIZE_IMAGE+SIZE_GAP_IMG);
            }
            
            NSMutableDictionary *subData = [data valueForKey:@"subData"];
            if (subData) {
                sizeHeight += SIZE_GAP_BIG;
                CGRect frame = [subData[@"frame"] CGRectValue];
                CGRect textRect = [subData[@"textRect"] CGRectValue];
                frame.origin.y = sizeHeight;
                subData[@"frame"] = [NSValue valueWithCGRect:frame];
                textRect.origin.y = frame.origin.y+SIZE_GAP_BIG;
                subData[@"textRect"] = [NSValue valueWithCGRect:textRect];
                sizeHeight += frame.size.height;
                data[@"subData"] = subData;
            }
            
            sizeHeight += 30;
            data[@"frame"] = [NSValue valueWithCGRect:CGRectMake(0, 0, [UIScreen screenWidth], sizeHeight)];
        }
        
        [datas addObject:data];
    }
}

- (void)setCommentsFrom:(NSDictionary *)dict toData:(NSMutableDictionary *)data{
    NSInteger comments = [dict[@"reposts_count"] integerValue];
    if (comments>=10000) {
        data[@"reposts"] = [NSString stringWithFormat:@"  %.1fw", comments/10000.0];
    } else {
        if (comments>0) {
            data[@"reposts"] = [NSString stringWithFormat:@"  %ld", (long)comments];
        } else {
            data[@"reposts"] = @"";
        }
    }
}

- (void)setRepostsFrom:(NSDictionary *)dict toData:(NSMutableDictionary *)data{
    NSInteger comments = [dict[@"comments_count"] integerValue];
    if (comments>=10000) {
        data[@"comments"] = [NSString stringWithFormat:@"  %.1fw", comments/10000.0];
    } else {
        if (comments>0) {
            data[@"comments"] = [NSString stringWithFormat:@"  %ld", (long)comments];
        } else {
            data[@"comments"] = @"";
        }
    }
}

- (void)setPicUrlsFrom:(NSDictionary *)dict toData:(NSMutableDictionary *)data{
    NSArray *pic_urls = [dict valueForKey:@"pic_urls"];
    NSString *url = [dict valueForKey:@"thumbnail_pic"];
    NSArray *pic_ids = [dict valueForKey:@"pic_ids"];
    if (pic_ids && pic_ids.count>1) {
        NSString *typeStr = @"jpg";
        if (pic_ids.count>0||url.length>0) {
            typeStr = [url substringFromIndex:url.length-3];
        }
        NSMutableArray *temp = [NSMutableArray array];
        for (NSString *pic_url in pic_ids) {
            [temp addObject:@{@"thumbnail_pic": [NSString stringWithFormat:@"http://ww2.sinaimg.cn/thumbnail/%@.%@", pic_url, typeStr]}];
        }
        data[@"pic_urls"] = temp;
    } else {
        data[@"pic_urls"] = pic_urls;
    }
}

- (void)removeFromSuperview{
    for (UIView *temp in self.subviews) {
        for (CTDTableViewCell *cell in temp.subviews) {
            if ([cell isKindOfClass:[CTDTableViewCell class]]) {
                [cell releaseMemory];
            }
        }
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [datas removeAllObjects];
    datas = nil;
    [self reloadData];
    self.delegate = nil;
    [needLoadArr removeAllObjects];
    needLoadArr = nil;
    [super removeFromSuperview];
}
@end
