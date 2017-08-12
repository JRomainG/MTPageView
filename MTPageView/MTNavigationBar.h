//
//  MTNavigationBar.h
//  MTPageView
//
//  Created by Jean-Romain on 16/07/2017.
//  Copyright © 2017 JustKodding. All rights reserved.
//

#import "MTTextField.h"
#import <UIKit/UIKit.h>

static const CGFloat kNavBarTopDownMargin = 5.0f;
static const CGFloat kNavBarSideMargin = 5.0f;

static const CGFloat kCancelButtonAnimationDuration = 0.3f;

static const CGFloat kNavBarMinHeight = 10.0f;
static const CGFloat kNavBarMaxHeight = 44.0f;

@interface MTNavigationBar : UINavigationBar <UITextFieldDelegate>

@property (nonatomic, strong) MTTextField *textField;
@property (nonatomic, strong) UIButton *cancelButton;

- (void)showCancelButton;
- (void)showCancelButtonAnimated:(BOOL)animated;
- (void)hideCancelButton;
- (void)hideCancelButtonAnimated:(BOOL)animated;

- (float)maxHeight;
- (float)minHeight;

@end
