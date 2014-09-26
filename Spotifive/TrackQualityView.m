//
//  TrackQualityView.m
//  Spotifive
//
//  Created by Adam Salvitti-Gucwa on 9/26/14.
//  Copyright (c) 2014 Esgie. All rights reserved.
//

#import "TrackQualityView.h"
#import "UIView+MCSizes.h"
#import "AnimationHelper.h"

@interface TrackQualityView ()

@property (nonatomic, strong) UITapGestureRecognizer *tapRecognizer;
@property (nonatomic, strong) UIView *tapView;
@property (nonatomic, strong) UIButton *qualityButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UILabel *infoLabel;

@end


@implementation TrackQualityView

- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = self.bounds;
    [self addSubview:blurEffectView];
    
    UIVibrancyEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
    UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
    [vibrancyEffectView setFrame:self.bounds];
    
    self.qualityButton = [UIButton new];
    self.qualityButton.frame = CGRectMake(self.width/2 - 80, self.height/2 - 80, 160, 160);
    [self.qualityButton addTarget:self action:@selector(qualityButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    self.qualityButton.backgroundColor = [UIColor clearColor];
    [self.qualityButton setImage:[UIImage imageNamed:@"smiley"] forState:UIControlStateNormal];
    [self.qualityButton setImage:[UIImage imageNamed:@"not-smiley"] forState:UIControlStateSelected];
    
    self.closeButton = [UIButton new];
    self.closeButton.frame = CGRectMake(10 , 30, 40, 40);
    [self.closeButton addTarget:self action:@selector(dismissKeyboard) forControlEvents:UIControlEventTouchUpInside];
    [self.closeButton setImage:[UIImage imageNamed:@"reset"] forState:UIControlStateNormal];
    self.closeButton.backgroundColor = [UIColor clearColor];
    
    self.infoLabel = [UILabel new];
    self.infoLabel.frame = CGRectMake(0, self.qualityButton.bottom, self.width, self.height - self.qualityButton.bottom);
    self.infoLabel.textAlignment = NSTextAlignmentCenter;
    self.infoLabel.font = [UIFont fontWithName:@"AvenirNext-UltraLight" size:16.0f];
    self.infoLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.infoLabel.numberOfLines = 0;
    self.infoLabel.textColor = [UIColor whiteColor];
    self.infoLabel.text = @"Tap to toggle top 5 best/worst tracks by related artists.";
    
    [[vibrancyEffectView contentView] addSubview:self.closeButton];
    [[vibrancyEffectView contentView] addSubview:self.qualityButton];
    [[vibrancyEffectView contentView] addSubview:self.infoLabel];
    [[blurEffectView contentView] addSubview:vibrancyEffectView];
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
  if (self.qualityButton.selected) {
    [self.qualityButton setSelected:NO];
  } else {
    [self.qualityButton setSelected:YES];
  }
  
  [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
    self.infoLabel.alpha = 0.0f;
    self.qualityButton.imageView.transform = [AnimationHelper scaleCustomTransform:self.qualityButton withScale:110.0];
  } completion:^(BOOL finished) {
    
    self.qualityButton.imageView.transform = [AnimationHelper scaleCustomTransform:self.qualityButton withScale:100.0];
  }];
}
@end
