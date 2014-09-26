//
//  TrackQualityView.m
//  Spotifive
//
//  Created by Adam Salvitti-Gucwa on 9/26/14.
//  Copyright (c) 2014 Esgie. All rights reserved.
//

#import "TrackQualityView.h"

@interface TrackQualityView ()

@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, strong) UIView *tapView;

@end


@implementation TrackQualityView

- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    blurEffectView.frame = self.bounds;
    [self addSubview:blurEffectView];
    
  }
  return self;
}

-(void)addTapRecognizerToDismissKeyboard
{
  self.tapView = [[UIView alloc] init];
  self.tapView.frame = self.bounds;
  [self addSubview:self.tapView];
  
  UIGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
  [self.tapView setGestureRecognizers:[NSArray arrayWithObject:tap]];
  
}

-(void)dismissKeyboard
{
  [self.delegate dismissKeyboard];
}

@end
