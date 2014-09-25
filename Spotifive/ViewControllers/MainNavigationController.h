//
//  ViewController.h
//  Spotifive
//
//  Created by Adam Salvitti-Gucwa on 9/24/14.
//  Copyright (c) 2014 Esgie. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SPTSession;

@interface MainNavigationController : UINavigationController

- (instancetype)initWithFrame:(CGRect)frame;
- (void)didFinishAuthorizingUserWithSession;

@end

