//
//  TrackQualityView.m
//  Spotifive
//
//  Created by Adam Salvitti-Gucwa on 9/26/14.
//  Copyright (c) 2014 Esgie. All rights reserved.
//

#import "TrackQualityView.h"
#import "UIView+MCSizes.h"

@interface TrackQualityView ()

@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, strong) UIView *tapView;
@property (nonatomic, strong) UIButton *qualityButton;
@property (nonatomic, strong) UIButton *closeButton;

@end


@implementation TrackQualityView

- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    blurEffectView.frame = self.bounds;
    [self addSubview:blurEffectView];
    
    self.qualityButton = [UIButton new];
    self.qualityButton.frame = CGRectMake(self.width/2 - 40, self.height/2 - 40, 80, 80);
    [self.qualityButton addTarget:self action:@selector(qualityButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.qualityButton.backgroundColor = [UIColor redColor];
    [self addSubview:self.qualityButton];
    
    self.closeButton = [UIButton new];
    self.closeButton.frame = CGRectMake(10 , 30, 40, 40);
    [self.closeButton addTarget:self action:@selector(dismissKeyboard) forControlEvents:UIControlEventTouchUpInside];
    self.closeButton.backgroundColor = [UIColor yellowColor];
    [self addSubview:self.closeButton];
  }
  return self;
}

-(void)dismissKeyboard
{
  [self.delegate dismissKeyboard];
}

-(IBAction)qualityButtonTapped:(id)sender
{
  [self.delegate toggleQuality];
}
@end
