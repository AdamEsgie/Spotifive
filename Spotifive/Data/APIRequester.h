//
//  APIHelper.h
//  yn
//
//  Created by Adam Salvitti-Gucwa on 9/3/14.
//  Copyright (c) 2014 DEDE. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SPTListPage;

@interface APIRequester : NSObject

+(instancetype)sharedInstance;

-(void)searchArtistsRelatedToArtist:(NSString*)artistName success:(void (^)(NSArray*))success error:(void (^)(NSError*))error;
@end
