//
//  SettingsHelper.m
//  Spotifive
//
//  Created by Adam Salvitti-Gucwa on 9/24/14.
//  Copyright (c) 2014 Esgie. All rights reserved.
//

#import "SettingsHelper.h"
#import "SSKeychain.h"
#import <Spotify/Spotify.h>

@implementation SettingsHelper

+ (SPTSession*)session
{
  id sessionData = [[NSUserDefaults standardUserDefaults] objectForKey:kSession];
  return sessionData ? [NSKeyedUnarchiver unarchiveObjectWithData:sessionData] : nil;
}

+ (NSString*)uid
{
  return [[[UIDevice currentDevice] identifierForVendor] UUIDString];
}

+ (NSURL*)callbackURL
{
  return [NSURL URLWithString:kCallbackURL];
}

+ (NSURL*)swapURL
{
  return [NSURL URLWithString:kTokenSwapURL];
}

+ (void)setupSPTSession:(SPTSession *)session
{
  NSData *sessionData = [NSKeyedArchiver archivedDataWithRootObject:session];
  [[NSUserDefaults standardUserDefaults] setObject:sessionData forKey:kSession];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
