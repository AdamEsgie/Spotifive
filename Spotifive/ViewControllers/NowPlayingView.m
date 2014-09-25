//
//  NowPlayingView.m
//  Spotifive
//
//  Created by Adam Salvitti-Gucwa on 9/25/14.
//  Copyright (c) 2014 Esgie. All rights reserved.
//

#import "NowPlayingView.h"
#import <Spotify/Spotify.h>

@interface NowPlayingView ()

@property (nonatomic, strong) UIImageView *coverView;

@end

@implementation NowPlayingView

- (instancetype)initWithFrame:(CGRect)frame;
{
  self = [super initWithFrame:frame];
  if (self) {
    self.frame = frame;
    self.coverView = [[UIImageView alloc] initWithFrame:self.bounds];
    [self addSubview:self.coverView];
  }
  return self;
}

-(void)addArtistCoverArt
{
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSError *error = nil;
    UIImage *image = nil;
    NSData *imageData = [NSData dataWithContentsOfURL:self.artist.largestImage.imageURL options:0 error:&error];
    
    if (imageData != nil) {
      image = [UIImage imageWithData:imageData];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
      self.coverView.image = image;
      if (image == nil) {
        NSLog(@"Couldn't load cover image with error: %@", error);
      }
    });
  });
  
}



@end
