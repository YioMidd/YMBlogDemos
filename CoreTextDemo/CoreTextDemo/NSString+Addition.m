//
//  NSString+Addition.m
//  CoreTextDemo
//
//  Created by KiBen on 2017/4/18.
//  Copyright © 2017年 KiBen. All rights reserved.
//

#import "NSString+Addition.h"
#import <CoreText/CoreText.h>

@implementation NSString (Addition)
- (NSUInteger) compareTo: (NSString*) comp {
    NSComparisonResult result = [self compare:comp];
    if (result == NSOrderedSame) {
        return 0;
    }
    return result == NSOrderedAscending ? -1 : 1;
}

- (NSUInteger) compareToIgnoreCase: (NSString*) comp {
    return [[self lowercaseString] compareTo:[comp lowercaseString]];
}

- (bool) contains: (NSString*) substring {
    NSRange range = [self rangeOfString:substring];
    return range.location != NSNotFound;
}

- (bool) endsWith: (NSString*) substring {
    NSRange range = [self rangeOfString:substring];
    return range.location == [self length] - [substring length];
}

- (bool) startsWith: (NSString*) substring {
    NSRange range = [self rangeOfString:substring];
    return range.location == 0;
}

- (NSUInteger) indexOf: (NSString*) substring {
    NSRange range = [self rangeOfString:substring options:NSCaseInsensitiveSearch];
    return range.location == NSNotFound ? -1 : range.location;
}

- (NSUInteger) indexOf:(NSString *)substring startingFrom: (NSUInteger) index {
    NSString* test = [self substringFromIndex:index];
    return index+[test indexOf:substring];
}

- (NSUInteger) lastIndexOf: (NSString*) substring {
    NSRange range = [self rangeOfString:substring options:NSBackwardsSearch];
    return range.location == NSNotFound ? -1 : range.location;
}

- (NSUInteger) lastIndexOf:(NSString *)substring startingFrom: (NSUInteger) index {
    NSString* test = [self substringFromIndex:index];
    return [test lastIndexOf:substring];
}

- (NSString*) substringFromIndex:(NSUInteger)from toIndex: (NSUInteger) to {
    NSRange range;
    range.location = from;
    range.length = to - from;
    return [self substringWithRange: range];
}

- (NSString*) trim {
    
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSArray*) split: (NSString*) token {
    return [self split:token limit:0];
}

- (NSArray*) split: (NSString*) token limit: (NSUInteger) maxResults {
    NSMutableArray* result = [NSMutableArray arrayWithCapacity: 8];
    NSString* buffer = self;
    while ([buffer contains:token]) {
        if (maxResults > 0 && [result count] == maxResults - 1) {
            break;
        }
        NSUInteger matchIndex = [buffer indexOf:token];
        NSString* nextPart = [buffer substringFromIndex:0 toIndex:matchIndex];
        buffer = [buffer substringFromIndex:matchIndex + [token length]];
        [result addObject:nextPart];
    }
    if ([buffer length] > 0) {
        [result addObject:buffer];
    }
    
    return result;
}

- (NSString*) replace: (NSString*) target withString: (NSString*) replacement {
    return [self stringByReplacingOccurrencesOfString:target withString:replacement];
}

- (CGSize)sizeWithConstrainedToWidth:(float)width fromFont:(UIFont *)font1 lineSpace:(float)lineSpace{
    return [self sizeWithConstrainedToSize:CGSizeMake(width, CGFLOAT_MAX) fromFont:font1 lineSpace:lineSpace];
}

- (CGSize)sizeWithConstrainedToSize:(CGSize)size fromFont:(UIFont *)font lineSpace:(float)lineSpace {
    
    CTFontRef textFont = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    CGFloat minLineHeight = font.pointSize, maxLineHeight = minLineHeight + 10;
    CTLineBreakMode lineBreakMode = kCTLineBreakByTruncatingTail;
    CTTextAlignment textAlignment = kCTLeftTextAlignment;
    
    CTParagraphStyleSetting settings[6] = {
        {kCTParagraphStyleSpecifierAlignment, sizeof(textAlignment), &textAlignment},
        {kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(minLineHeight), &minLineHeight},
        {kCTParagraphStyleSpecifierMaximumLineHeight, sizeof(maxLineHeight), &maxLineHeight},
        {kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(lineSpace), &lineSpace},
        {kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(lineSpace), &lineSpace},
        {kCTParagraphStyleSpecifierLineBreakMode, sizeof(CTLineBreakMode), &lineBreakMode},
    };
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, 6);
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    [attributes setValue:(__bridge id _Nullable)(textFont) forKey:(__bridge NSString *)kCTFontAttributeName];
    [attributes setValue:(__bridge id _Nullable)(paragraphStyle) forKey:(__bridge NSString *)kCTParagraphStyleAttributeName];
    
    NSAttributedString *attributeString = [[NSAttributedString alloc] initWithString:self attributes:attributes];
    CFAttributedStringRef attributeStringRef = (__bridge CFAttributedStringRef)attributeString;
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString(attributeStringRef);
    CGSize textSize = CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRangeMake(0, CFAttributedStringGetLength(attributeStringRef)), NULL, size, NULL);
    CFRelease(frameSetter);
    CFRelease(textFont);
    CFRelease(paragraphStyle);
    return textSize;
}

- (void)drawInContext:(CGContextRef)context withPosition:(CGPoint)p andFont:(UIFont *)font andTextColor:(UIColor *)color andHeight:(float)height andWidth:(float)width{
    CGSize size = CGSizeMake(width, font.pointSize + 10);
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CTFontRef textFont = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
    CGFloat minLineHeight = font.pointSize, maxLineHeight = minLineHeight + 10, lineSpace = 5;
    CTLineBreakMode lineBreakMode = kCTLineBreakByTruncatingTail;
    CTTextAlignment textAlignment = kCTLeftTextAlignment;
    
    CTParagraphStyleSetting settings[6] = {
        {kCTParagraphStyleSpecifierAlignment, sizeof(textAlignment), &textAlignment},
        {kCTParagraphStyleSpecifierMinimumLineHeight, sizeof(minLineHeight), &minLineHeight},
        {kCTParagraphStyleSpecifierMaximumLineHeight, sizeof(maxLineHeight), &maxLineHeight},
        {kCTParagraphStyleSpecifierMinimumLineSpacing, sizeof(lineSpace), &lineSpace},
        {kCTParagraphStyleSpecifierMaximumLineSpacing, sizeof(lineSpace), &lineSpace},
        {kCTParagraphStyleSpecifierLineBreakMode, sizeof(CTLineBreakMode), &lineBreakMode},
    };
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, 6);
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    [attributes setValue:(__bridge id _Nullable)(textFont) forKey:(__bridge NSString *)kCTFontAttributeName];
    [attributes setValue:color forKey:(__bridge NSString *)kCTForegroundColorAttributeName];
    [attributes setValue:(__bridge id _Nullable)(paragraphStyle) forKey:(__bridge NSString *)kCTParagraphStyleAttributeName];
    
    NSAttributedString *attributeString = [[NSAttributedString alloc] initWithString:self attributes:attributes];
    CFAttributedStringRef attributeStringRef = (__bridge CFAttributedStringRef)attributeString;
    
    CGRect rect = {{p.x, height - p.y - size.height}, size};
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, rect);
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString(attributeStringRef);
    CTFrameRef frameRef = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, CFAttributedStringGetLength(attributeStringRef)), path, NULL);
    CTFrameDraw(frameRef, context);
    CGPathRelease(path);
    CFRelease(frameSetter);
    CFRelease(frameRef);
    CFRelease(textFont);
    CFRelease(paragraphStyle);
    
    // 上下文翻转回去
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
}

- (void)drawInContext:(CGContextRef)context withPosition:(CGPoint)p andFont:(UIFont *)font andTextColor:(UIColor *)color andHeight:(float)height{
    [self drawInContext:context withPosition:p andFont:font andTextColor:color andHeight:height andWidth:[UIScreen screenWidth]];
}

@end
