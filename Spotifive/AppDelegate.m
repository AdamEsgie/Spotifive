//
//  AppDelegate.m
//  Spotifive
//
//  Created by Adam Salvitti-Gucwa on 9/24/14.
//  Copyright (c) 2014 Esgie. All rights reserved.
//

#import "AppDelegate.h"
#import <Spotify/Spotify.h>
#import "MainNavigationController.h"
#import "SettingsHelper.h"

@interface AppDelegate ()
@property (nonatomic, strong) SPTSession *session;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  [self.window setRootViewController:[[MainNavigationController alloc] initWithFrame:self.window.bounds]];
  [self.window makeKeyAndVisible];
  
  return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
  
  if ([[SPTAuth defaultInstance] canHandleURL:url withDeclaredRedirectURL:[SettingsHelper callbackURL]]) {

    [[SPTAuth defaultInstance] handleAuthCallbackWithTriggeredAuthURL:url tokenSwapServiceEndpointAtURL:[SettingsHelper swapURL] callback:^(NSError *error, SPTSession *session) {
       
      if (error != nil) {
        NSLog(@"*** Auth error: %@", error);
      return;
      }

      [SettingsHelper setupSPTSession:session];

      MainNavigationController *controller = (MainNavigationController*)self.window.rootViewController;
      [controller didFinishAuthorizingUserWithSession];
      
     }];
    return YES;
  }
  
  return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application
{

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{

}

- (void)applicationWillTerminate:(UIApplication *)application
{

}

@end
