//
//  TracksViewController.m
//  Spotifive
//
//  Created by Adam Salvitti-Gucwa on 9/25/14.
//  Copyright (c) 2014 Esgie. All rights reserved.
//

#import "TracksViewController.h"
#import "SettingsHelper.h"
#import "UIView+MCSizes.h"
#import "AnimationHelper.h"
#import <Spotify/Spotify.h>
#import "APIRequester.h"
#import "NowPlayingView.h"
#import "TrackQualityView.h"
#import "TrackTableViewCell.h"

static NSString *CellIdentifier = @"Register";

@interface TracksViewController () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate, TrackQualityViewDelegate, NowPlayingViewDelegate>

@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) NSArray *relatedArtists;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NowPlayingView *nowPlayingView;
@property (nonatomic, strong) SPTAudioStreamingController *player;
@property (nonatomic, strong) TrackQualityView *trackQualityView;
@property NSInteger currentIndex;
@property BOOL shouldGetTopTracks;
@property BOOL paused;

@end

@implementation TracksViewController

- (instancetype)initWithFrame:(CGRect)frame;
{
  self = [super init];
  if (self) {
    self.view.frame = frame;
    self.view.backgroundColor = [SettingsHelper spotifyGreenColor];
    self.shouldGetTopTracks = YES;
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
  
  [self setupTableView];
  [self setupContainerAndTextField];
  [self setupPlayer];
  [self setupNowPlayingView];
  
  if (!self.relatedArtists) {
    [self setupPlaceholder];
  }
}

-(void)setupPlaceholder
{
  self.infoLabel = [UILabel new];
  self.infoLabel.frame = CGRectMake(0, 0, self.view.width, self.view.height - self.containerView.height);
  self.infoLabel.textAlignment = NSTextAlignmentCenter;
  self.infoLabel.font = [SettingsHelper defaultTimerFont];
  self.infoLabel.lineBreakMode = NSLineBreakByWordWrapping;
  self.infoLabel.numberOfLines = 0;
  self.infoLabel.textColor = [UIColor whiteColor];
  self.infoLabel.text = @"Welcome To Spotifive";
  [self.view addSubview:self.infoLabel];
}

-(void)setupPlayer
{
  if (!self.player) {
    self.player = [SPTAudioStreamingController new];
    self.player.playbackDelegate = self;
  }
  
  [self.player loginWithSession:[SettingsHelper session] callback:^(NSError *error) {
    
    if (error != nil) {
      NSLog(@"*** Enabling playback got error: %@", error);
      return;
    }
  }];
}

-(void)setupNowPlayingView
{
  if (!self.nowPlayingView) {
    self.nowPlayingView = [[NowPlayingView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.tableView.top)];
    self.nowPlayingView.delegate = self;
    [self.view addSubview:self.nowPlayingView];
  }
}

-(void)setupTableView
{
  self.tableView = nil;
  self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 200, 320, CGRectGetHeight(self.view.bounds) - 200 - 64) style:UITableViewStylePlain];
  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  self.tableView.clipsToBounds = YES;
  self.tableView.showsVerticalScrollIndicator = NO;
  self.tableView.bounces = YES;
  self.tableView.backgroundColor = [UIColor clearColor];
  self.tableView.separatorColor = [SettingsHelper borderColor];
  self.tableView.contentOffset = CGPointZero;
  self.tableView.contentInset = UIEdgeInsetsMake(-6, 0, 0, 0);
  self.tableView.separatorInset = UIEdgeInsetsZero;
  self.tableView.allowsMultipleSelection = NO;
  self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
  [self.view addSubview:self.tableView];
  self.tableView.alpha = 0.0f;
}

- (void)setupContainerAndTextField
{
  if (!self.textField) {
    self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.height - 64, self.view.width, 64)];
    self.containerView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.containerView];
    
    self.textField = [[UITextField alloc] initWithFrame:CGRectMake(14, 0, self.containerView.width - 70, self.containerView.height)];
    self.textField.font = [SettingsHelper defaultRegularFont];
    self.textField.textColor = [SettingsHelper spotifyGreenColor];
    self.textField.tintColor = [SettingsHelper spotifyGreenColor];
    self.textField.delegate = self;
    self.textField.placeholder = [SettingsHelper placeholderText];
    [self.containerView addSubview:self.textField];
    
    self.sendButton = [UIButton new];
    self.sendButton.frame = CGRectMake(self.containerView.width - searchButtonSize, self.containerView.height/2 - searchButtonSize/2, searchButtonSize, searchButtonSize);
    [self.sendButton addTarget:self action:@selector(search:) forControlEvents:UIControlEventTouchUpInside];
    [self.sendButton setImage:[UIImage imageNamed:@"search-icon"] forState:UIControlStateNormal];
    [self.containerView addSubview:self.sendButton];
  }
}
#pragma mark - Keyboard Notifiations
- (void)keyboardWillShow:(NSNotification *)notification
{
  CGRect keyboardRect = [[[notification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
  NSTimeInterval duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
  UIViewAnimationCurve curve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
  
  [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
    self.sendButton.imageView.transform = [AnimationHelper scaleCustomTransform:self.sendButton withScale:80.0];
  } completion:^(BOOL finished) {
    self.sendButton.imageView.transform = [AnimationHelper scaleCustomTransform:self.sendButton withScale:100.0];
    
    [self.sendButton removeTarget:self action:@selector(search:) forControlEvents:UIControlEventTouchUpInside];
    [self.sendButton addTarget:self action:@selector(send:) forControlEvents:UIControlEventTouchUpInside];
    [self.sendButton setImage:[UIImage imageNamed:@"send-icon"] forState:UIControlStateNormal];
    
  }];

  [UIView animateWithDuration:duration animations:^{
    
    self.trackQualityView.alpha = 1.0f;
    self.infoLabel.alpha = 0.0f;
    
    [UIView setAnimationCurve:curve];
    self.containerView.frame = CGRectMake(self.containerView.origin.x, self.view.height - keyboardRect.size.height - self.containerView.height, self.containerView.width, self.containerView.height);
    
  } completion:^(BOOL finished) {
    
    self.trackQualityView = [[TrackQualityView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.containerView.top)];
    self.trackQualityView.delegate = self;
    self.trackQualityView.alpha = 0.0f;
    [self.view addSubview:self.trackQualityView];
    
    [UIView animateWithDuration:0.2 animations:^{
      self.trackQualityView.alpha = 1.0f;
    }];
    
  }];
}

-(void)keyboardWillHide:(NSNotification *)notification
{
  NSTimeInterval duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
  UIViewAnimationCurve curve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
  
  [self.trackQualityView removeFromSuperview];
  self.trackQualityView = nil;
  
  [UIView animateWithDuration:duration animations:^{
    
    if (!self.relatedArtists) {
      self.infoLabel.alpha = 1.0f;
    }
    
    [UIView setAnimationCurve:curve];
    self.containerView.frame = CGRectMake(self.containerView.origin.x, self.view.height - self.containerView.height, self.containerView.width, self.containerView.height);
    
  } completion:^(BOOL finished) {
    
  }];
}

#pragma mark - IBAction
-(IBAction)search:(id)sender
{
  [self.textField becomeFirstResponder];
}

-(IBAction)send:(id)sender
{
  [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
    self.sendButton.imageView.transform = [AnimationHelper scaleCustomTransform:self.sendButton withScale:80.0];
  } completion:^(BOOL finished) {
    self.sendButton.imageView.transform = [AnimationHelper scaleCustomTransform:self.sendButton withScale:100.0];
    
    [self.sendButton removeTarget:self action:@selector(send:) forControlEvents:UIControlEventTouchUpInside];
    [self.sendButton addTarget:self action:@selector(search:) forControlEvents:UIControlEventTouchUpInside];
    [self.sendButton setImage:[UIImage imageNamed:@"search-icon"] forState:UIControlStateNormal];
  }];
  
  [[APIRequester sharedInstance] searchArtistsWithString:self.textField.text success:^(SPTArtist *artist) {
   
    [[APIRequester sharedInstance] searchArtistsRelatedToArtist:artist success:^(NSArray *artists) {
      self.currentIndex = 0;
      self.relatedArtists = artists;
      
      [self.tableView reloadData];
      [self.textField resignFirstResponder];
      
      [UIView animateWithDuration:0.5 animations:^{
        self.textField.alpha = 0.0f;
        self.tableView.alpha = 0.0f;
      } completion:^(BOOL finished) {
        
        self.textField.text = artist.name;
        
        [UIView animateWithDuration:0.5 animations:^{
          self.textField.alpha = 1.0f;
          self.tableView.alpha = 1.0f;
        } completion:^(BOOL finished) {
          [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
          [self playTrackAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
          UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
          [(TrackTableViewCell*)cell addPlayToAccessoryView];
        }];
        
      }];
    } error:^(NSError *error) {
      
    }];
  } error:^(NSError *error) {
    
  }];
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
  [cell.accessoryView removeFromSuperview];
  cell.accessoryView = nil;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [self playTrackAtIndexPath:indexPath];
  UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
  [(TrackTableViewCell*)cell addPlayToAccessoryView];
}

#pragma mark - UITableViewDatasource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return cellHeight;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.relatedArtists.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
  TrackTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[TrackTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }
  
  SPTArtist *artist = [self.relatedArtists objectAtIndex:indexPath.row];
  cell.textLabel.text = artist.name;
  cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:artist.smallestImage.imageURL]];
  
  return cell;
}

#pragma mark - Track Player Delegates
-(void)playTrackAtIndexPath:(NSIndexPath *)indexPath
{
  if (self.relatedArtists.count > 0) {
    
    SPTArtist *artist = [self.relatedArtists objectAtIndex:indexPath.row];
    self.nowPlayingView.artist = artist;
    [self.nowPlayingView addArtistCoverArt];
  
    if (self.shouldGetTopTracks) {
      [[APIRequester sharedInstance] searchTopTracksForArtist:artist success:^(SPTTrack *track) {
        [self.player playTrackProvider:track callback:nil];
        [self.nowPlayingView updateLabelsWithName:track.name andInterval:track.duration];
        self.currentIndex = indexPath.row;
      } error:^(NSError *error) {

      }];
    } else {
      [[APIRequester sharedInstance] searchWorstTracksForArtist:artist success:^(SPTTrack *track) {
        [self.player playTrackProvider:track callback:nil];
        [self.nowPlayingView updateLabelsWithName:track.name andInterval:track.duration];
        self.currentIndex = indexPath.row;
      } error:^(NSError *error) {
        
      }];
    }
  } else {
    // show progress hud error here
    
    
  }
}

- (void)audioStreaming:(SPTAudioStreamingController *)audioStreaming didReceiveMessage:(NSString *)message
{
  UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Message from Spotify"
                                                      message:message
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
  [alertView show];
}

- (void) audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangePlaybackStatus:(BOOL)isPlaying
{
  if (isPlaying == NO && !self.paused) {
    self.currentIndex++;
    [self playTrackAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0]];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
    
  }
}

- (void) audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangeToTrack:(NSDictionary *)trackMetadata
{

}

#pragma mark - UITextFieldDelegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
  textField.text = @"";
  return YES;
}

#pragma mark - TrackQualityView Delegate
-(void)dismissKeyboard
{
  [self.textField resignFirstResponder];
  [self.sendButton removeTarget:self action:@selector(send:) forControlEvents:UIControlEventTouchUpInside];
  [self.sendButton addTarget:self action:@selector(search:) forControlEvents:UIControlEventTouchUpInside];
  [self.sendButton setImage:[UIImage imageNamed:@"search-icon"] forState:UIControlStateNormal];
}

-(void)toggleQuality
{
  if (self.shouldGetTopTracks) {
    self.shouldGetTopTracks = NO;
  } else {
    self.shouldGetTopTracks = YES;
  }
}

#pragma mark - NowPlaying Delegate
-(void)playOrPauseMusic
{
  if (self.player.isPlaying) {
    self.paused = YES;
    [self.nowPlayingView.timer invalidate];
    [self.player setIsPlaying:NO callback:nil];
  } else {
    self.paused = NO;
    NSString *trackLength = self.player.currentTrackMetadata[SPTAudioStreamingMetadataTrackDuration];
    [self.nowPlayingView updateLabelsWithName:nil andInterval:[trackLength doubleValue] - self.player.currentPlaybackPosition];
    [self.player setIsPlaying:YES callback:nil];
  }
}

#pragma mark - dealloc

-(void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
@end
