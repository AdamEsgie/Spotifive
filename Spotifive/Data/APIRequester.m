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

-(void)searchTopTracksForArtist:(SPTArtist*)artist success:(void (^)(SPTTrack*))success error:(void (^)(NSError*))error
{
  [artist requestTopTracksForTerritory:kCountryCode withSession:[SettingsHelper session] callback:^(NSError *error, id object) {
    
      success([object firstObject]);
  }];
}
-(void)searchWorstTracksForArtist:(SPTArtist*)artist success:(void (^)(SPTTrack*))success error:(void (^)(NSError*))error
{
  [self searcAllAlbumsForArtist:artist success:^(SPTAlbum *album) {
    
    [self searcAllTracksForAlbum:album success:^(SPTTrack *track) {
      
      success(track);
    
    } error:^(NSError *error) {
      
    }];
    
  } error:^(NSError *error) {
    
  }];
}

-(void)searcAllAlbumsForArtist:(SPTArtist*)artist success:(void (^)(SPTAlbum*))success error:(void (^)(NSError*))error
{
  [artist requestAlbumsOfType:SPTAlbumTypeAlbum withSession:[SettingsHelper session] availableInTerritory:kCountryCode callback:^(NSError *error, id object) {
    
    if (error != nil) {
      NSLog(@"*** Auth error: %@", error);
      return;
    }
    
    SPTListPage *listPage = object;
    NSArray *albumsArray = [NSArray arrayWithArray:listPage.items];
    NSMutableArray *albumsArrayCopy = [NSMutableArray arrayWithArray:albumsArray];
    NSMutableArray *albumsByPopularity = [NSMutableArray array];
    
    for (int i = 0; i < albumsArray.count; i++)
    {
      [SPTRequest requestItemFromPartialObject:[albumsArray objectAtIndex:i] withSession:[SettingsHelper session] callback:^(NSError *error, id object) {
        
        if (error != nil) {
          NSLog(@"*** Auth error: %@", error);
          return;
        }
        
        [albumsByPopularity addObject:object];
        [albumsArrayCopy removeObject:[albumsArray objectAtIndex:i]];
        
        if (albumsArrayCopy.count < 1) {
          [albumsByPopularity sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"popularity" ascending:YES]]];
          success([albumsByPopularity firstObject]);
        }
        
      }];
    }
  }];
}

-(void)searcAllTracksForAlbum:(SPTAlbum*)album success:(void (^)(SPTTrack*))success error:(void (^)(NSError*))error
{
  NSArray *tracksArray = [NSArray arrayWithArray:album.firstTrackPage.items];
  NSMutableArray *tracksArrayCopy = [NSMutableArray arrayWithArray:tracksArray];
  NSMutableArray *tracksByPopularity = [NSMutableArray array];
  
  for (int i = 0; i < tracksArray.count; i++)
  {
    [SPTRequest requestItemFromPartialObject:[tracksArray objectAtIndex:i] withSession:[SettingsHelper session] callback:^(NSError *error, id object) {
      
      if (error != nil) {
        NSLog(@"*** Auth error: %@", error);
        return;
      }
      
      [tracksByPopularity addObject:object];
      [tracksArrayCopy removeObject:[tracksArray objectAtIndex:i]];
      
      if (tracksArrayCopy.count < 1) {
        [tracksByPopularity sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"popularity" ascending:YES]]];
        success([tracksByPopularity firstObject]);
      }
      
    }];
  }
}
@end
