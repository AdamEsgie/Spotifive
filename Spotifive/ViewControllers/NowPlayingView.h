//
//  NowPlayingView.h
//  Spotifive
//
//  Created by Adam Salvitti-Gucwa on 9/25/14.
//  Copyright (c) 2014 Esgie. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SPTArtist;

@interface NowPlayingView : UIView

@property (nonatomic, strong) SPTArtist *artist;
@property (nonatomic, strong) UIView *refreshView;

-(instancetype)initWithFrame:(CGRect)frame;
-(void)addArtistCoverArt;
-(void)updateLabelsWithName:(NSString*)name andInterval:(NSTimeInterval)interval;

@end
