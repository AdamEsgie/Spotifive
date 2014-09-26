//
//  SettingsHelper.h
//  Spotifive
//
//  Created by Adam Salvitti-Gucwa on 9/24/14.
//  Copyright (c) 2014 Esgie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class SPTSession;

static NSString * kCountryCode = @"US";
static NSString * kSession = @"SpotifySession";
static NSString * const kClientId = @"da979439ae38465aab63ef3812610e09";
static NSString * const kCallbackURL = @"spotifive://";
static NSString * const kTokenSwapURL = @"http://spotifiver.appspot.com/swap";
static NSString * const kTokenRefreshServiceURL = @"http://spotifiver.appspot.com/refresh";

static const CGFloat cellHeight = 55;
static const CGFloat refreshSize = 40;
static const CGFloat searchButtonSize = 64;

typedef void (^delayedMethod)();

@interface SettingsHelper : NSObject

+ (SPTSession*)session;
+ (NSString*)uid;
+ (NSURL*)callbackURL;
+ (NSURL*)swapURL;
+ (void)setupSPTSession:(SPTSession *)session;
+ (UIColor*)spotifyGreenColor;
+ (UIColor*)borderColor;
+ (UIFont*)defaultLightFont;
+ (UIFont*)defaultRegularFont;
+ (UIFont*)defaultHeavyFont;
+ (UIFont*)defaultTimerFont;
+ (NSString*)placeholderText;

@end
