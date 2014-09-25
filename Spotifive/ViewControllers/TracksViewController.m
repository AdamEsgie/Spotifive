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

static NSString *CellIdentifier = @"Register";

@interface TracksViewController () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, SPTAudioStreamingDelegate, SPTAudioStreamingPlaybackDelegate>

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) UIButton *sendButton;
@property (nonatomic, strong) NSArray *relatedArtists;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NowPlayingView *nowPlayingView;
@property (nonatomic, strong) SPTAudioStreamingController *player;
@property NSInteger currentIndex;
@property BOOL shouldGetTopTracks;

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
    [self.view addSubview:self.nowPlayingView];
  }
}

- (void)updateNowPlayingView
{
  self.nowPlayingView.artist = [self.relatedArtists objectAtIndex:self.currentIndex];
  [self.nowPlayingView addArtistCoverArt];
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
  self.tableView.contentInset = UIEdgeInsetsMake(-10, 0, 0, 0);
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
    UIImage *sendImage = [UIImage imageNamed:@"send-icon"];
    self.sendButton.frame = CGRectMake(self.containerView.width - 14 - sendImage.size.width, self.containerView.height/2 - sendImage.size.height/2, sendImage.size.width, sendImage.size.height);
    [self.sendButton addTarget:self action:@selector(searchForArtist:) forControlEvents:UIControlEventTouchUpInside];
    [self.sendButton setImage:sendImage forState:UIControlStateNormal];
    [self.containerView addSubview:self.sendButton];
  }
}
#pragma mark - Keyboard Notifiations
- (void)keyboardWillShow:(NSNotification *)notification
{
  CGRect keyboardRect = [[[notification userInfo] valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
  NSTimeInterval duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
  UIViewAnimationCurve curve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
  
  [UIView animateWithDuration:duration animations:^{
    
    [UIView setAnimationCurve:curve];
    self.containerView.frame = CGRectMake(self.containerView.origin.x, self.view.height - keyboardRect.size.height - self.containerView.height, self.containerView.width, self.containerView.height);
    
  } completion:^(BOOL finished) {
    
  }];
}

-(void)keyboardWillHide:(NSNotification *)notification
{
  NSTimeInterval duration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
  UIViewAnimationCurve curve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
  
  [UIView animateWithDuration:duration animations:^{
    
    [UIView setAnimationCurve:curve];
    self.containerView.frame = CGRectMake(self.containerView.origin.x, self.view.height - self.containerView.height, self.containerView.width, self.containerView.height);
    
  } completion:^(BOOL finished) {
    
  }];
}

#pragma mark - IBAction
-(IBAction)searchForArtist:(id)sender
{
  [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
    self.sendButton.imageView.transform = [AnimationHelper scaleCustomTransform:self.sendButton withScale:80.0];
  } completion:^(BOOL finished) {
    self.sendButton.imageView.transform = [AnimationHelper scaleCustomTransform:self.sendButton withScale:100.0];
  }];
  
  [[APIRequester sharedInstance] searchArtistsRelatedToArtist:self.textField.text success:^(NSArray *artists) {
    
    self.currentIndex = 0;
    self.relatedArtists = artists;
    
    [self.tableView reloadData];
    [self.textField resignFirstResponder];

    [UIView animateWithDuration:0.5 animations:^{
      self.tableView.alpha = 0.0f;
    } completion:^(BOOL finished) {
      [UIView animateWithDuration:0.5 animations:^{
        self.tableView.alpha = 1.0f;
      } completion:^(BOOL finished) {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
        [self playTrackAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
        [self updateNowPlayingView];
      }];
      
    }];
    
  } error:^(NSError *error) {
    
    
  }];
}

#pragma mark - UITableViewDelegate

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [self playTrackAtIndexPath:indexPath];
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
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }
  
  cell.textLabel.font = [SettingsHelper defaultLightFont];
  cell.textLabel.textColor = [UIColor whiteColor];
  cell.backgroundColor = [UIColor clearColor];
  cell.selectionStyle = UITableViewCellSelectionStyleNone;
  
  SPTArtist *artist = [self.relatedArtists objectAtIndex:indexPath.row];
  cell.textLabel.text = artist.name;
  cell.imageView.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:artist.smallestImage.imageURL]];
  
  return cell;
}

#pragma mark - Track Player Delegates
-(void)playTrackAtIndexPath:(NSIndexPath *)indexPath
{
  SPTArtist *artist = [self.relatedArtists objectAtIndex:indexPath.row];
  
  if (self.shouldGetTopTracks) {
    [artist requestTopTracksForTerritory:kCountryCode withSession:[SettingsHelper session] callback:^(NSError *error, id object) {
      NSArray *tracks = [NSArray arrayWithArray:object];
      [self.player playTrackProvider:[tracks firstObject] callback:nil];
      self.currentIndex = indexPath.row;
      [self updateNowPlayingView];
    }];
  } else {
    
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
  if (isPlaying == NO) {
    [self playTrackAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex++ inSection:0]];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
    [self updateNowPlayingView];
  }
}

#pragma marl - UITextFieldDelegate

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
  textField.text = @"";
  return YES;
}


#pragma mark - dealloc

-(void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}
@end
