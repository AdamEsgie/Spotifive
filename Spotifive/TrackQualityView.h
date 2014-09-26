//
//  TrackQualityView.h
//  Spotifive
//
//  Created by Adam Salvitti-Gucwa on 9/26/14.
//  Copyright (c) 2014 Esgie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TrackQualityViewDelegate <NSObject>

-(void)dismissKeyboard;
-(void)toggleQuality;

@end

@interface TrackQualityView : UIView

@property (nonatomic, weak) id <TrackQualityViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame;

@end
