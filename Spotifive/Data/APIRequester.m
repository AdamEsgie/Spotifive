//
//  APIHelper.m
//  yn
//
//  Created by Adam Salvitti-Gucwa on 9/3/14.
//  Copyright (c) 2014 DEDE. All rights reserved.
//

#import "APIRequester.h"
#import <UIKit/UIKit.h>
#import <Spotify/Spotify.h>
#import "SettingsHelper.h"

@implementation APIRequester

+ (instancetype)sharedInstance
{
  static APIRequester *sharedManager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedManager = [[self alloc] init];
  });
  return sharedManager;
}

-(void)searchArtistsRelatedToArtist:(NSString*)artistName success:(void (^)(NSArray*))success error:(void (^)(NSError*))error
{
  SPTSession *session = [SettingsHelper session];
  
  if (!session) return;
  
  [SPTRequest performSearchWithQuery:artistName queryType:SPTQueryTypeArtist session:session callback:^(NSError *error, id object) {
    
    if (error != nil) {
      NSLog(@"*** Auth error: %@", error);
      return;
    }
    
    NSArray *results = [(SPTListPage*)object items];
    SPTPartialArtist *partialArtist = [results firstObject];
    
    [SPTRequest requestItemFromPartialObject:partialArtist withSession:session callback:^(NSError *error, id object) {

      if (error != nil) {
        NSLog(@"*** Auth error: %@", error);
        return;
      }
      
      SPTArtist *artist = object;
      [artist requestRelatedArtists:session callback:^(NSError *error, id object) {
        if (error != nil) {
          NSLog(@"*** Auth error: %@", error);
          return;
        }
        
        NSArray *artistArray = [NSArray arrayWithArray:object];
        if (artistArray.count > 5) {
          success([artistArray subarrayWithRange:NSMakeRange(0, 5)]);
        } else {
          success(artistArray);
        }
        

      }];
    }];
  }];
}

@end
