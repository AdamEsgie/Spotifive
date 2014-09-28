//
//  NowPlayingView.m
//  Spotifive
//
//  Created by Adam Salvitti-Gucwa on 9/25/14.
//  Copyright (c) 2014 Esgie. All rights reserved.
//

#import "NowPlayingView.h"
#import <Spotify/Spotify.h>
#import "UIView+MCSizes.h"
#import "RefreshView.h"
#import "SettingsHelper.h"

@interface NowPlayingView ()

@property (nonatomic, strong) UILabel *trackLabel;
@property (nonatomic, strong) UILabel *timerLabel;
@property (nonatomic, strong) UIImageView *coverView;
@property (nonatomic, strong) UIView *tapView;
@property (nonatomic, strong) UIImageView *smileyImageView;
@property NSTimeInterval trackTime;
@property BOOL isLoadingImage;

@end

@implementation NowPlayingView

- (instancetype)initWithFrame:(CGRect)frame;
{
  self = [super initWithFrame:frame];
  if (self) {
    self.frame = frame;
    self.coverView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.coverView.contentMode = UIViewContentModeScaleAspectFill;
    self.coverView.clipsToBounds = YES;
    self.coverView.alpha = 0.35f;
    [self addSubview:self.coverView];
    
    self.smileyImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 25, 20, 20)];
    self.smileyImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.smileyImageView];
    
    self.trackLabel = [UILabel new];
    self.trackLabel.frame = CGRectMake(0, self.smileyImageView.bottom, self.width, 100);
    self.trackLabel.textColor = [UIColor whiteColor];
    self.trackLabel.font = [SettingsHelper defaultHeavyFont];
    self.trackLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.trackLabel.numberOfLines = 0;
    self.trackLabel.adjustsFontSizeToFitWidth = YES;
    self.trackLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.trackLabel];
    
    self.timerLabel = [UILabel new];
    self.timerLabel.frame = CGRectMake(0, self.trackLabel.bottom, self.width, cellHeight);
    self.timerLabel.textColor = [UIColor whiteColor];
    self.timerLabel.font = [SettingsHelper defaultTimerFont];
    self.timerLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.timerLabel];
    
    self.tapView = [[UIView alloc] init];
    self.tapView.frame = self.frame;
    [self addSubview:self.tapView];
    
    UIGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pauseOrPlay)];
    [self.tapView setGestureRecognizers:[NSArray arrayWithObject:tap]];
  }
  return self;
}

-(void)addArtistCoverArtForArtist:(SPTArtist*)artist
{
  self.isLoadingImage = YES;
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSError *error = nil;
    UIImage *image = nil;
    NSData *imageData = [NSData dataWithContentsOfURL:artist.largestImage.imageURL options:0 error:&error];
    
    if (imageData != nil) {
      image = [UIImage imageWithData:imageData];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
      
      self.coverView.image = image;
      self.isLoadingImage = NO;
      
      if (image == nil) {
        NSLog(@"Couldn't load cover image with error: %@", error);
      }
    });
  });
  
}

-(void)updateLabelsWithName:(NSString*)name andInterval:(NSTimeInterval)interval
{
  if (name) {
    self.trackLabel.text = name;
  }
  self.trackTime = interval;
  [self startTrackTimer];
}

-(void)startTrackTimer
{
  [self.timer invalidate];
  self.timer = nil;
  self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                   target:self
                                 selector:@selector(updateTrackTimerLabel)
                                 userInfo:nil
                                  repeats:YES];
}

-(void)updateTrackTimerLabel
{
  NSString *minutes = [NSString stringWithFormat: @"%d", (int)floor(self.trackTime/60)];
  NSString *seconds = [NSString stringWithFormat: @"%d", (int)round(self.trackTime - [minutes integerValue] * 60)];
  
  if ([seconds integerValue] < 10) {
    seconds = [NSString stringWithFormat:@"0%@",seconds];
  }
  
  if ([seconds integerValue] == 60) {
    minutes = [NSString stringWithFormat:@"%ld",[minutes integerValue] + 1];
    seconds = @"00";
  }
  
  if (self.trackTime == 0) {
    [self.timer invalidate];
  } else {
    self.timerLabel.text = [NSString stringWithFormat:@"%@:%@", minutes, seconds];
    self.trackTime--;
  }
}

-(void)pauseOrPlay
{
  [self.timer invalidate];
  [self.delegate playOrPauseMusic];
}

-(void)setupSmileyWithOption:(BOOL)option
{
  if (option) {
    self.smileyImageView.image = [UIImage imageNamed:@"smiley"];
  } else {
    self.smileyImageView.image = [UIImage imageNamed:@"not-smiley"];
  }
}
@end
