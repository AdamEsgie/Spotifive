//
//  AnimationHelper.m
//  Twic
//
//  Created by Adam Salvitti-Gucwa on 8/11/14.
//  Copyright (c) 2014 esgie. All rights reserved.
//

#import "AnimationHelper.h"

@implementation AnimationHelper

+(CGAffineTransform)scaleShrinkView:(UIView*)view
{
  return CGAffineTransformScale(view.transform, 0.01, 0.01);
}
+(CGAffineTransform)scaleExpandView:(UIView*)view
{
  return CGAffineTransformScale(view.transform, 100.0, 100.0);
}

+(CGAffineTransform)scaleCustomTransform:(UIView*)view withScale:(CGFloat)scale
{
  return CGAffineTransformScale(view.transform, scale, scale);
}

+(void)fadeToText:(NSString*)newString forLabel:(UILabel*)label withDuration:(NSTimeInterval)duration
{
  [UIView animateWithDuration:duration animations:^{
    label.alpha = 0.0f;
  } completion:^(BOOL finished) {
    label.text = newString;
    [UIView animateWithDuration:duration animations:^{
      label.alpha = 1.0f;
    } completion:^(BOOL finished) {
      
    }];
  }];
}

+(void)fadeToText:(NSString*)newString forTextField:(UITextField*)textField withDuration:(NSTimeInterval)duration
{
  [UIView animateWithDuration:duration animations:^{
    textField.alpha = 0.0f;
  } completion:^(BOOL finished) {
    textField.text = newString;
    [UIView animateWithDuration:duration animations:^{
      textField.alpha = 1.0f;
    } completion:^(BOOL finished) {
      
    }];
  }];
}

+(void)fadeToText:(NSString*)newString forButton:(UIButton*)button withDuration:(NSTimeInterval)duration
{
  [UIView animateWithDuration:0.3 animations:^{
    button.titleLabel.alpha = 0.0;
  } completion:^(BOOL finished) {
    [button setTitle:newString forState:UIControlStateNormal];
    [UIView animateWithDuration:0.3 animations:^{
      button.titleLabel.alpha = 1.0;
    }];
  }];
}

+(void)performWithDelay:(NSTimeInterval)delay andBlock:(delayedMethod)block;
{
  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
  dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    
    block();

  });
}

@end
