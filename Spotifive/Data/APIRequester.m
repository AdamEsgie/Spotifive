//
//  APIHelper.m
//  yn
//
//  Created by Adam Salvitti-Gucwa on 9/3/14.
//  Copyright (c) 2014 DEDE. All rights reserved.
//

#import "APIRequester.h"
#import <UIKit/UIKit.h>

@interface APIRequester ()

@end

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


@end
