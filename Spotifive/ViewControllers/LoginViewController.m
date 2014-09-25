//
//  LoginViewController.m
//  Spotifive
//
//  Created by Adam Salvitti-Gucwa on 9/25/14.
//  Copyright (c) 2014 Esgie. All rights reserved.
//

#import "LoginViewController.h"
#import <Spotify/Spotify.h>
#import "SettingsHelper.h"
#import "UIView+MCSizes.h"

@interface LoginViewController () <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation LoginViewController

- (instancetype)initWithFrame:(CGRect)frame;
{
  self = [super init];
  if (self) {
    self.view.frame = frame;
    self.view.backgroundColor = [UIColor whiteColor];
  }
  return self;
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  [self setupWebView];
  
  SPTAuth *auth = [SPTAuth defaultInstance];
  NSURL *loginURL = [auth loginURLForClientId:kClientId
                          declaredRedirectURL:[NSURL URLWithString:kCallbackURL]
                                       scopes:@[SPTAuthStreamingScope]];
  [self.webView loadRequest:[NSURLRequest requestWithURL:loginURL]];
}

- (void)setupWebView
{
  self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 20, self.view.width, self.view.height - 20)];
  self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
  self.webView.dataDetectorTypes = UIDataDetectorTypeAll;
  self.webView.scalesPageToFit = YES;
  self.webView.suppressesIncrementalRendering = NO;
  self.webView.scrollView.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);
  
  self.webView.backgroundColor = [UIColor whiteColor];
  self.webView.opaque = NO;
  self.webView.delegate = self;
  
  [self.view addSubview:self.webView];
}

@end
