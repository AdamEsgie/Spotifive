//
//  ViewController.m
//  Spotifive
//
//  Created by Adam Salvitti-Gucwa on 9/24/14.
//  Copyright (c) 2014 Esgie. All rights reserved.
//

#import "MainNavigationController.h"
#import <Spotify/Spotify.h>
#import "SettingsHelper.h"
#import "LoginViewController.h"
#import "TracksViewController.h"
#import "APIRequester.h"
#import "ProgressHUD.h"

@interface MainNavigationController ()

@property (nonatomic, strong) TracksViewController *tracksController;
@property (nonatomic, strong) LoginViewController *loginController;

@end

@implementation MainNavigationController

- (instancetype)initWithFrame:(CGRect)frame;
{
  self = [super init];
  if (self) {
    self.view.frame = frame;
    self.navigationBarHidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
  }
  return self;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  SPTSession *session = [SettingsHelper session];
  
  if (session) {

    [[APIRequester sharedInstance] fetchToken:^(SPTSession *session) {
      [self setupTrackController];
      [self pushViewController:self.tracksController animated:NO];
    } error:^(NSError *error) {
      [ProgressHUD showError:@"Error Renewing Token"];
    }];
    
  } else {
    [self setupLoginController];
    [self pushViewController:self.loginController animated:NO];
    
  }
}

- (void)renewTokenAndEnablePlayback
{
  [[APIRequester sharedInstance] renewTokenAndEnablePlaybackWithSuccess:^(SPTSession *session) {
    
    [self didFinishAuthorizingUserWithSession];
    
  } error:^(NSError *error) {
    [ProgressHUD showError:@"Error renewing token"];
  }];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

- (void)setupTrackController
{
  if (!self.tracksController) {
    self.tracksController = [[TracksViewController alloc] initWithFrame:self.view.bounds];
  }
}

-(void)setupLoginController
{
  if (!self.loginController) {
    self.loginController = [[LoginViewController alloc] initWithFrame:self.view.bounds];
  }
}

-(void)didFinishAuthorizingUserWithSession
{
  [self setupTrackController];
  [self pushViewController:self.tracksController animated:YES];
}

@end
