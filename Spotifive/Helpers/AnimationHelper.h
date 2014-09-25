//
//  AnimationHelper.h
//  Twic
//
//  Created by Adam Salvitti-Gucwa on 8/11/14.
//  Copyright (c) 2014 esgie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingsHelper.h"

@interface AnimationHelper : NSObject

+(CGAffineTransform)scaleShrinkView:(UIView*)view;
+(CGAffineTransform)scaleExpandView:(UIView*)view;
+(CGAffineTransform)scaleCustomTransform:(UIView*)view withScale:(CGFloat)scale;
+(void)fadeToText:(NSString*)newString forLabel:(UILabel*)label withDuration:(NSTimeInterval)duration;
+(void)performWithDelay:(NSTimeInterval)delay andBlock:(delayedMethod)block;
+(void)fadeToText:(NSString*)newString forTextField:(UITextField*)textField withDuration:(NSTimeInterval)duration;
+(void)fadeToText:(NSString*)newString forButton:(UIButton*)button withDuration:(NSTimeInterval)duration;
@end
