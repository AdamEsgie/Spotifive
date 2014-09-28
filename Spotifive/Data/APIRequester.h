//
//  APIHelper.h
//  yn
//
//  Created by Adam Salvitti-Gucwa on 9/3/14.
//  Copyright (c) 2014 DEDE. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SPTArtist, SPTTrack;

@interface APIRequester : NSObject

+(instancetype)sharedInstance;

-(void)searchArtistsWithString:(NSString*)artistName success:(void (^)(SPTArtist*))success error:(void (^)(NSError*))error;

-(void)generatePlaylistTracksRelatedToArtist:(SPTArtist*)artist withType:(BOOL)good success:(void (^)(NSArray*))success error:(void (^)(NSError*))error;

//-(void)searchTopTracksForArtist:(SPTArtist*)artist success:(void (^)(SPTTrack*))success error:(void (^)(NSError*))error;
//-(void)searchWorstTracksForArtist:(SPTArtist*)artist success:(void (^)(SPTTrack*))success error:(void (^)(NSError*))error;
@end
