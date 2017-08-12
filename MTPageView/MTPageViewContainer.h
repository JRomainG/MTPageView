//
//  MTPageViewContainer.h
//  MTPageView
//
//  Created by Jean-Romain on 12/07/2017.
//  Copyright © 2017 JustKodding. All rights reserved.
//

#import "MTPageViewTab.h"
#import "MTPageViewController.h"
#import "MTGradiantAlphaView.h"
#import <UIKit/UIKit.h>

static const CGFloat kArrowViewAlpha = 0.7;
static const CGFloat kArrowViewMargin = 10;
static const CGFloat kArrowViewHeight = 50;
static const CGFloat kHeaderViewHeight = 25;
static const CGFloat kHeaderFontSize = 15.0;
static const CGFloat kShadowSize = 5;
static const CGFloat kShadowAlpha = 0.4;

@class MTPageViewController;

@interface MTPageViewContainer : UIView {
    UIButton *removeButton;
    UIView *headerView;
    UILabel *subtitleLabel;
    UITapGestureRecognizer *tapGestureRecognizer;
}

@property (nonatomic, strong) MTPageViewTab *tab;
@property (nonatomic, strong) MTPageViewController *parentController;
@property (nonatomic, strong) MTGradiantAlphaView *leftArrow;
@property (nonatomic, strong) MTGradiantAlphaView *rightArrow;

- (void)updateFrameWithContentSize:(CGSize)size;

- (void)hideHeader;
- (void)showHeader;

@end
