//
//  UIView(MCSizes)
//
//  Created by Karol Kozub on 15.10.2012.
//  Copyright (c) 2012 Macoscope. All rights reserved.
//

#import "UIView+MCSizes.h"

@implementation UIView (MCSizes)
- (CGSize)size
{
    return self.frame.size;
}

- (void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGPoint)origin
{
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGFloat)top
{
    return self.origin.y;
}

- (void)setTop:(CGFloat)top
{
    CGPoint origin = self.origin;
    origin.y = top;
    self.origin = origin;
}

- (CGFloat)left
{
    return self.origin.x;
}

- (void)setLeft:(CGFloat)left
{
    CGPoint origin = self.origin;
    origin.x = left;
    self.origin = origin;
}

- (CGFloat)width
{
    return self.size.width;
}

- (void)setWidth:(CGFloat)width
{
    CGSize size = self.size;
    size.width = width;
    self.size = size;
}

- (CGFloat)height
{
    return self.size.height;
}

- (void)setHeight:(CGFloat)height
{
    CGSize size = self.size;
    size.height = height;
    self.size = size;
}

- (CGFloat)bottom
{
    return self.top + self.height;
}

- (void)setBottom:(CGFloat)bottom
{
    self.top = bottom - self.height;
}

- (CGFloat)right
{
    return self.left + self.width;
}

- (void)setRight:(CGFloat)right
{
    self.left = right - self.width;
}

- (void)resizeToView:(UIView *)view
{
    self.frame = CGRectMake(0, 0, view.width, view.height);
}

- (void)setWidth:(CGFloat)width alignment:(MCViewAlignment)alignment
{
    if (alignment & MCViewAlignmentRight) {
        CGFloat right = self.right;
        self.width = width;
        self.right = right;
    } else {
        self.width = width;
    }
}

- (void)setHeight:(CGFloat)height alignment:(MCViewAlignment)alignment
{
    if (alignment & MCViewAlignmentBottom) {
        CGFloat bottom = self.bottom;
        self.height = height;
        self.bottom = bottom;
    } else {
        self.height = height;
    }
}

- (void)setSize:(CGSize)size alignment:(MCViewAlignment)alignment
{
    [self setWidth:size.width alignment:alignment];
    [self setHeight:size.height alignment:alignment];
}
@end