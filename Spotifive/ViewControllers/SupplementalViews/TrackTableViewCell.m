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
  
  self.playView.frame = CGRectMake(self.width - self.height, 0, self.height, self.height);
//  self.accessoryView.backgroundColor = [UIColor yellowColor];
  // Update the frame of the text label
  self.textLabel.frame = CGRectMake(self.imageView.right + 10, 0, self.frame.size.width - self.imageView.right + 10 - self.playView.width, self.height);
  
  // Update the frame of the subtitle label
  self.detailTextLabel.frame = CGRectMake(self.imageView.frame.origin.x + 40, self.detailTextLabel.frame.origin.y, self.frame.size.width - (self.imageView.frame.origin.x + 60), self.detailTextLabel.frame.size.height);
  
  // Update the separator
  self.separatorInset = UIEdgeInsetsMake(0, (self.indentationLevel * self.indentationWidth) + 50, 0, 0);
  
}

-(void)addPlayToAccessoryView
{
  self.playView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"play"]];
  [self addSubview:self.playView];
}


#pragma mark - dealloc
- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
