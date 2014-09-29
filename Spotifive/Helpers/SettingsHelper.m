//
//  SettingsHelper.m
//  Spotifive
//
//  Created by Adam Salvitti-Gucwa on 9/24/14.
//  Copyright (c) 2014 Esgie. All rights reserved.
//

#import "SettingsHelper.h"
#import <Spotify/Spotify.h>
#import "APIRequester.h"

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

+ (UIColor*)spotifyGreenColor
{
  return [UIColor colorWithRed:129/255.0f green:183/255.0f blue:26/255.0f alpha:1.0f];
}

+ (UIColor*)borderColor
{
  return [UIColor colorWithRed:255/255.0f green:255/255.0f blue:255/255.0f alpha:0.25f];
}

+ (UIFont*)defaultLightFont
{
  return [UIFont fontWithName:@"AvenirNext-UltraLight" size:30.0f];
}

+ (UIFont*)defaultRegularFont
{
  return [UIFont fontWithName:@"AvenirNext-Regular" size:30.0f];
}

+ (UIFont*)defaultHeavyFont
{
  return [UIFont fontWithName:@"AvenirNext-Heavy" size:30.0f];
}

+ (UIFont*)defaultTimerFont
{
  return [UIFont fontWithName:@"AvenirNext-Heavy" size:60.0f];
}

+ (NSString*)placeholderText
{
  return @"Enter an artist";
}
@end
