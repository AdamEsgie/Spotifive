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
#import "ProgressHUD.h"

static NSString *CellIdentifier = @"Register";

@interface TracksViewController () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate, TrackQualityViewDelegate, NowPlayingViewDelegate>

@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) NSArray *playlist;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NowPlayingView *nowPlayingView;
@property (nonatomic, strong) SPTAudioStreamingController *player;
@property (nonatomic, strong) TrackQualityView *trackQualityView;
@property (nonatomic, strong) SPTTrack *currentTrack;
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

  [self setupTableView];
  [self setupContainerAndTextField];
  [self setupPlayer];
  [self setupNowPlayingView];
  
  if (!self.playlist) {
    [self setupPlaceholder];
  }
}

-(void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
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
  self.infoLabel.text = @"Spotifive";
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
    self.textField.autocorrectionType = UITextAutocorrectionTypeNo;
    [self.containerView addSubview:self.textField];
    
    self.sendButton = [UIButton new];
    self.sendButton.frame = CGRectMake(self.containerView.width - searchButtonSize, self.containerView.height/2 - searchButtonSize/2, searchButtonSize, searchButtonSize);
    [self.sendButton addTarget:self action:@selector(search:) forControlEvents:UIControlEventTouchUpInside];
    [self.sendButton setImage:[UIImage imageNamed:@"search-icon"] forState:UIControlStateNormal];
    [self.containerView addSubview:self.sendButton];
  }
}

-(void)changeButtonFromSearchToSend
{
  [self.sendButton removeTarget:self action:@selector(search:) forControlEvents:UIControlEventTouchUpInside];
  [self.sendButton addTarget:self action:@selector(send:) forControlEvents:UIControlEventTouchUpInside];
  [self.sendButton setImage:[UIImage imageNamed:@"send-icon"] forState:UIControlStateNormal];
}

-(void)changeButtonFromSendToSearch
{
  [self.sendButton removeTarget:self action:@selector(send:) forControlEvents:UIControlEventTouchUpInside];
  [self.sendButton addTarget:self action:@selector(search:) forControlEvents:UIControlEventTouchUpInside];
  [self.sendButton setImage:[UIImage imageNamed:@"search-icon"] forState:UIControlStateNormal];
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
    
    [self changeButtonFromSearchToSend];
  }];

  [UIView animateWithDuration:duration animations:^{
    
    self.trackQualityView.alpha = 1.0f;
    self.infoLabel.alpha = 0.0f;
    
    [UIView setAnimationCurve:curve];
    self.containerView.frame = CGRectMake(self.containerView.origin.x, self.view.height - keyboardRect.size.height - self.containerView.height, self.containerView.width, self.containerView.height);
    
  } completion:^(BOOL finished) {
    
    self.trackQualityView = [[TrackQualityView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.containerView.top) andDelegate:self];
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
  [self.nowPlayingView setupSmileyWithOption:self.shouldGetTopTracks];
  
  [UIView animateWithDuration:duration animations:^{
    
    if (!self.playlist) {
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
  }];
  
  [ProgressHUD show:@"Finding artist"];
  
  [[APIRequester sharedInstance] searchArtistsWithString:self.textField.text success:^(SPTArtist *artist) {
   
    [ProgressHUD show:@"Creating playlist"];
    
    [[APIRequester sharedInstance] generatePlaylistTracksRelatedToArtist:artist withType:self.shouldGetTopTracks success:^(NSArray *playlist) {
    
      self.currentTrack = nil;
      self.playlist = nil;
      if ([self.player isPlaying]) {
        [self playOrPauseMusic];
      }
      self.playlist = playlist;
      [ProgressHUD dismiss];
      
      [self.tableView reloadData];
      [self.textField resignFirstResponder];
      [self changeButtonFromSendToSearch];
      
      [UIView animateWithDuration:0.5 animations:^{
        self.textField.alpha = 0.0f;
        self.tableView.alpha = 0.0f;
      } completion:^(BOOL finished) {
        
        self.textField.text = artist.name;
        
        [UIView animateWithDuration:0.5 animations:^{
          self.textField.alpha = 1.0f;
          self.tableView.alpha = 1.0f;
        } completion:^(BOOL finished) {
          
          [self.player playTrackProvider:[self.playlist objectAtIndex:0][@"track"] callback:^(NSError *error) {
            
            self.currentTrack = [self.playlist objectAtIndex:0][@"track"];
            
          }];
        }];
        
      }];
    } error:^(NSError *error) {
    
      [ProgressHUD showError:@"Error generating playlist"];
      self.textField.text = @"";
      [self.textField becomeFirstResponder];
      
    }];
  } error:^(NSError *error) {
    
    [ProgressHUD showError:@"Error finding artist"];
    self.textField.text = @"";
    [self.textField becomeFirstResponder];
    
  }];
}

#pragma mark - UITableViewDelegate
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [self.player playTrackProvider:[self.playlist objectAtIndex:indexPath.row][@"track"] callback:^(NSError *error) {
    if (error) {
      [ProgressHUD showError:@"Error"];
    }
  }];
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
  return self.playlist.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  
  TrackTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[TrackTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }
  
  [cell.playView removeFromSuperview];
  cell.playView = nil;
  
  SPTArtist *artist = [self.playlist objectAtIndex:indexPath.row][@"artist"];
  cell.textLabel.text = artist.name;
  cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:artist.smallestImage.imageURL]];
  
  return cell;
}

#pragma mark - Track Player Delegates
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
  if (isPlaying == NO && !self.paused && self.playlist) {
    
    if ([(SPTTrack*)[self.playlist lastObject][@"track"] name] == self.currentTrack.name) {
      return;
    
    } else {
      for (int i = 0; i < self.playlist.count; i++)
      {
        NSDictionary *dict = [self.playlist objectAtIndex:i];
        if (self.currentTrack == dict[@"track"]) {
          [self.player playTrackProvider:[self.playlist objectAtIndex:i+1][@"track"] callback:^(NSError *error) {}];
        }
          
      }
    }

  } else if (isPlaying == YES) {
    
    NSString *trackName = self.player.currentTrackMetadata[SPTAudioStreamingMetadataTrackName];
    
    for (NSDictionary *dict in self.playlist)
    {
      if ([[(SPTTrack*)dict[@"track"] name] isEqualToString:trackName]) {
        self.currentTrack = dict[@"track"];
      }
    }
    
  }
}

- (void) audioStreaming:(SPTAudioStreamingController *)audioStreaming didChangeToTrack:(NSDictionary *)trackMetadata {
  
  if (trackMetadata == nil) {
    
    [self.nowPlayingView updateLabelsWithName:nil andInterval:0];
    
  } else {
    
    for (int i = 0; i < self.playlist.count; i++)
    {
      NSDictionary *dict = [self.playlist objectAtIndex:i];
      
      if ([[dict[@"track"] name] isEqualToString:trackMetadata[SPTAudioStreamingMetadataTrackName]]) {
        [self.nowPlayingView addArtistCoverArtForArtist:dict[@"artist"]];
        
        self.currentTrack = dict[@"track"];
        
        [(TrackTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]] addPlayToAccessoryView];
      } else {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        [[(TrackTableViewCell*)cell playView] removeFromSuperview];
        [(TrackTableViewCell*)cell setPlayView:nil];
      }
    }
    [self.nowPlayingView updateLabelsWithName:trackMetadata[SPTAudioStreamingMetadataTrackName] andInterval:[trackMetadata[SPTAudioStreamingMetadataTrackDuration] integerValue]];
  }
}

-(void)audioStreamingDidLosePermissionForPlayback:(SPTAudioStreamingController *)audioStreaming
{
  [self playOrPauseMusic];
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
  [ProgressHUD dismiss];
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

-(BOOL)currentQuality
{
  return self.shouldGetTopTracks;
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
