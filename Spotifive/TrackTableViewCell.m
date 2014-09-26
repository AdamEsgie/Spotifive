//
//  TrackTableViewCell.m
//  Spotifive
//
//  Created by Adam Salvitti-Gucwa on 9/26/14.
//  Copyright (c) 2014 Esgie. All rights reserved.
//

#import "TrackTableViewCell.h"
#import "SettingsHelper.h"
#import "UIView+MCSizes.h"
#import "RefreshView.h"

@implementation TrackTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    
    self.textLabel.font = [SettingsHelper defaultLightFont];
    self.textLabel.textColor = [UIColor whiteColor];
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.indentationWidth = 24.0f;
    self.imageView.contentMode = UIViewContentModeScaleToFill;
  }
  return self;
}

- (void)prepareForReuse
{
  [super prepareForReuse];
}

- (void)layoutSubviews
{
  // Call super
  [super layoutSubviews];
  
  // Update the frame of the image view
  self.imageView.frame = CGRectMake(14, 7, 50 , 40);
  
  self.accessoryView.frame = CGRectMake(self.width - self.height, 0, self.height, self.height);
  self.accessoryView.backgroundColor = [UIColor yellowColor];
  // Update the frame of the text label
  self.textLabel.frame = CGRectMake(self.imageView.right + 10, 0, self.frame.size.width - self.imageView.right + 10 - self.accessoryView.width, self.height);
  
  // Update the frame of the subtitle label
  self.detailTextLabel.frame = CGRectMake(self.imageView.frame.origin.x + 40, self.detailTextLabel.frame.origin.y, self.frame.size.width - (self.imageView.frame.origin.x + 60), self.detailTextLabel.frame.size.height);
  
  // Update the separator
  self.separatorInset = UIEdgeInsetsMake(0, (self.indentationLevel * self.indentationWidth) + 50, 0, 0);
  
}

-(void)addPlayToAccessoryView
{
  UIView *view = [UIView new];

//  UIImageView *playView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"play"]];
//  playView.frame = self.accessoryView.frame;
//  [view addSubview:playView];
  
  self.accessoryView = view;
}

-(void)animateRefreshView
{
  [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
    self.refreshView.alpha = 0.0;
    self.refreshView.transform = CGAffineTransformMakeScale(0.75, 0.75);
  } completion:^(BOOL finished) {
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
      self.refreshView.transform = CGAffineTransformMakeScale(1.0, 1.0);
      self.refreshView.alpha = 1.0;
    } completion:^(BOOL finished) {
      [self animateRefreshView];
    }];
  }];
}

#pragma mark - dealloc
- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
