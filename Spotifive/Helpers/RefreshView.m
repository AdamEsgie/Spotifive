//
//  RefreshView.m
//  yn
//
//  Created by Adam Salvitti-Gucwa on 9/11/14.
//  Copyright (c) 2014 DEDE. All rights reserved.
//

#import "RefreshView.h"
#import <QuartzCore/QuartzCore.h>

@implementation RefreshView

- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectInset(self.bounds, 10, 10)];
    view.clipsToBounds = YES;
    view.layer.cornerRadius = view.frame.size.width/2;
    [self addSubview:view];
    
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    blurEffectView.frame = view.bounds;
    [view addSubview:blurEffectView];
  }
  return self;
}

@end
