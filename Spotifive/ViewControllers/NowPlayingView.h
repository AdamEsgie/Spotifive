//
//  NowPlayingView.h
//  Spotifive
//
//  Created by Adam Salvitti-Gucwa on 9/25/14.
//  Copyright (c) 2014 Esgie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol NowPlayingViewDelegate <NSObject>

-(void)playOrPauseMusic;

@end

@class SPTArtist;

@interface NowPlayingView : UIView

@property (nonatomic, weak) id <NowPlayingViewDelegate> delegate;
@property (nonatomic, strong) UIView *refreshView;
@property (nonatomic, strong) NSTimer *timer;

-(instancetype)initWithFrame:(CGRect)frame;
-(void)addArtistCoverArtForArtist:(SPTArtist*)artist;
-(void)updateLabelsWithName:(NSString*)name andInterval:(NSTimeInterval)interval;
-(void)setupSmileyWithOption:(BOOL)option;

@end
