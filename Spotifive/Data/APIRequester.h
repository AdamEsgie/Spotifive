//
//  APIHelper.h
//  yn
//
//  Created by Adam Salvitti-Gucwa on 9/3/14.
//  Copyright (c) 2014 DEDE. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SPTArtist, SPTTrack, SPTSession;

@interface APIRequester : NSObject

+(instancetype)sharedInstance;

-(void)searchArtistsWithString:(NSString*)artistName success:(void (^)(SPTArtist*))success error:(void (^)(NSError*))error;

-(void)generatePlaylistTracksRelatedToArtist:(SPTArtist*)artist withType:(BOOL)good success:(void (^)(NSArray*))success error:(void (^)(NSError*))error;

-(void)renewTokenAndEnablePlaybackWithSuccess:(void (^)(SPTSession*))success error:(void (^)(NSError*))error;
-(void)fetchToken:(void (^)(SPTSession*))success error:(void (^)(NSError*))error;
@end
