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
    
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor whiteColor];
    self.layer.cornerRadius = self.frame.size.width/2;
  }
  return self;
}

@end
