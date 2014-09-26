//
//  TrackTableViewCell.h
//  Spotifive
//
//  Created by Adam Salvitti-Gucwa on 9/26/14.
//  Copyright (c) 2014 Esgie. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RefreshView;

@interface TrackTableViewCell : UITableViewCell

@property (nonatomic,strong) RefreshView *refreshView;

-(void)addPlayToAccessoryView;

@end
