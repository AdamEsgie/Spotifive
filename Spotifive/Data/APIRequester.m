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

-(void)searchArtistsWithString:(NSString*)artistName success:(void (^)(SPTArtist*))success error:(void (^)(NSError*))errorBlock
{
  [self fetchToken:^(SPTSession *session) {
    
    [SPTRequest performSearchWithQuery:artistName queryType:SPTQueryTypeArtist session:session callback:^(NSError *error, id object) {
      
      if (error != nil) {
        NSLog(@"*** Auth error: %@", error);
        errorBlock(error);
        return;
      }
      
      NSArray *results = [(SPTListPage*)object items];
      SPTPartialArtist *partialArtist = [results firstObject];
      
      [SPTRequest requestItemFromPartialObject:partialArtist withSession:session callback:^(NSError *error, id object) {
        
        if (error != nil) {
          NSLog(@"*** Auth error: %@", error);
          errorBlock(error);
          return;
        }
        
        success(object);
        
      }];
    }];
    
  } error:^(NSError *error) {
    errorBlock(error);
  }];
}

-(void)generatePlaylistTracksRelatedToArtist:(SPTArtist*)artist withType:(BOOL)good success:(void (^)(NSArray*))success error:(void (^)(NSError*))errorBlock;
{
  __block NSArray *artistArray;
  
  [self fetchToken:^(SPTSession *session) {
    [artist requestRelatedArtists:session callback:^(NSError *error, id object) {
      if (error != nil) {
        NSLog(@"*** Auth error: %@", error);
        errorBlock(error);
        return;
      }
      
      artistArray = [NSArray arrayWithArray:object];
      
      if (artistArray.count >= 5) {
        artistArray = [artistArray subarrayWithRange:NSMakeRange(0, 5)];
      } else {
        errorBlock(error);
      }
      
      [self fillArtistAndTrackDictionaryForArtistArray:artistArray withType:good success:^(NSArray *arrayOfDictionaries) {
        
        success(arrayOfDictionaries);
        
      } error:^(NSError *error) {
        if (error != nil) {
          NSLog(@"*** Auth error: %@", error);
          errorBlock(error);
          return;
        }
      }];
    }];
  } error:^(NSError *error) {
    errorBlock(error);
  }];
}

-(void)fillArtistAndTrackDictionaryForArtistArray:(NSArray*)artistArray withType:(BOOL)good success:(void (^)(NSArray*))success error:(void (^)(NSError*))errorBlock
{
  __block NSMutableArray *arrayOfArtistDictionaries = [NSMutableArray array];
  
  __block NSInteger counter = 0;
  
  for (SPTArtist *artist in artistArray)
  {
    NSMutableDictionary *artistDict = [NSMutableDictionary dictionary];
    
    if (good) {
      
      [self searchTopTracksForArtist:artist success:^(SPTTrack *track) {
        
        if (track) {
          artistDict[@"artist"] = artist;
          artistDict[@"track"] = track;
          [arrayOfArtistDictionaries addObject:artistDict];
        }
        
        counter++;
        
        if (counter == 5) {
          success (arrayOfArtistDictionaries);
          return;
        }
        
      } error:^(NSError *error) {
        errorBlock(error);
        return;
      }];
      
    } else {
      
      [self searchWorstTracksForArtist:artist success:^(SPTTrack *track) {
        
        if (track) {
          artistDict[@"artist"] = artist;
          artistDict[@"track"] = track;
          [arrayOfArtistDictionaries addObject:artistDict];
        }
        
        counter++;

        if (counter == 5) {
          success (arrayOfArtistDictionaries);
          return;
        }
        
      } error:^(NSError *error) {
        errorBlock(error);
        return;
      }];
    }
  }
}

-(void)searchTopTracksForArtist:(SPTArtist*)artist success:(void (^)(SPTTrack*))success error:(void (^)(NSError*))errorBlock
{
  [self fetchToken:^(SPTSession *session) {
    [artist requestTopTracksForTerritory:kCountryCode withSession:session callback:^(NSError *error, id object) {
      success([object firstObject]);
    }];
  } error:^(NSError *error) {
    errorBlock(error);
  }];
}
-(void)searchWorstTracksForArtist:(SPTArtist*)artist success:(void (^)(SPTTrack*))success error:(void (^)(NSError*))errorBlock
{
  [self searcAllAlbumsForArtist:artist success:^(SPTAlbum *album) {
    
    if (album) {
    
      [self searcAllTracksForAlbum:album success:^(SPTTrack *track) {
        
        success(track);
      
      } error:^(NSError *error) {
        errorBlock(error);
        return;
      }];
    
    } else {
      success(nil);
    }
    
  } error:^(NSError *error) {
    errorBlock(error);
    return;
  }];
}

-(void)searcAllAlbumsForArtist:(SPTArtist*)artist success:(void (^)(SPTAlbum*))success error:(void (^)(NSError*))errorBlock
{
  [self fetchToken:^(SPTSession *session) {
    
    [artist requestAlbumsOfType:SPTAlbumTypeAlbum withSession:session availableInTerritory:kCountryCode callback:^(NSError *error, id object) {
      
      if (error != nil) {
        NSLog(@"*** Auth error: %@", error);
        return;
      }
      
      SPTArtist *artist = artist;
      SPTListPage *listPage = object;
      NSArray *albumsArray = [NSArray arrayWithArray:listPage.items];
      NSMutableArray *albumsArrayCopy = [NSMutableArray arrayWithArray:albumsArray];
      NSMutableArray *albumsByPopularity = [NSMutableArray array];
      
      if (albumsArray.count == 0) {
        success(nil);
      }
      
      for (int i = 0; i < albumsArray.count; i++)
      {
        [SPTRequest requestItemFromPartialObject:[albumsArray objectAtIndex:i] withSession:session callback:^(NSError *error, id object) {
          
          if (error != nil) {
            NSLog(@"*** Auth error: %@", error);
            return;
          }
          
          if (object) {
            [albumsByPopularity addObject:object];
          }
          
          [albumsArrayCopy removeObject:[albumsArray objectAtIndex:i]];
          
          if (albumsArrayCopy.count < 1) {
            [albumsByPopularity sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"popularity" ascending:YES]]];
            success([albumsByPopularity firstObject]);
          }
          
        }];
      }
    }];
  } error:^(NSError *error) {
    errorBlock(error);
  }];
}

-(void)searcAllTracksForAlbum:(SPTAlbum*)album success:(void (^)(SPTTrack*))success error:(void (^)(NSError*))errorBlock
{
  NSArray *tracksArray = [NSArray arrayWithArray:album.firstTrackPage.items];
  NSMutableArray *tracksArrayCopy = [NSMutableArray arrayWithArray:tracksArray];
  NSMutableArray *tracksByPopularity = [NSMutableArray array];
  
  [self fetchToken:^(SPTSession *session) {
   
    for (int i = 0; i < tracksArray.count; i++)
    {
      [SPTRequest requestItemFromPartialObject:[tracksArray objectAtIndex:i] withSession:session callback:^(NSError *error, id object) {
        
        if (error != nil) {
          NSLog(@"*** Auth error: %@", error);
          return;
        }
        
        if (object) {
          [tracksByPopularity addObject:object];
        }
        [tracksArrayCopy removeObject:[tracksArray objectAtIndex:i]];
        
        if (tracksArrayCopy.count < 1) {
          [tracksByPopularity sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"popularity" ascending:YES]]];
          success([tracksByPopularity firstObject]);
        }
        
      }];
    }
  } error:^(NSError *error) {
    errorBlock(error);
  }];
  
  
}

-(void)renewTokenAndEnablePlaybackWithSuccess:(void (^)(SPTSession*))success error:(void (^)(NSError *))errorBlock
{
  SPTSession *session = [SettingsHelper session];
  SPTAuth *auth = [SPTAuth defaultInstance];
  
  [auth renewSession:session withServiceEndpointAtURL:[NSURL URLWithString:kTokenRefreshServiceURL] callback:^(NSError *error, SPTSession *session) {
    if (error) {
      errorBlock(error);
      NSLog(@"*** Error renewing session: %@", error);
      return;
    }
    [SettingsHelper setupSPTSession:session];
    
    success(session);
  }];
  
}

-(void)fetchToken:(void (^)(SPTSession*))success error:(void (^)(NSError*))errorBlock;
{
  if ([[SettingsHelper session] isValid]) {
    success([SettingsHelper session]);
  } else {
    [self renewTokenAndEnablePlaybackWithSuccess:^(SPTSession *session) {
      success(session);
    } error:^(NSError *error) {
      errorBlock(error);
      return;
    }];
  }
}
@end
