//
//  MTScrollBarManager.h
//  MTPageView
//
//  Created by Jean-Romain on 16/07/2017.
//  Copyright © 2017 JustKodding. All rights reserved.
//

#import "MTNavigationBar.h"
#import <UIKit/UIKit.h>

static const CGFloat kMinScrollBeforeShowingBar = 4.0f;
static const CGFloat kBarsAnimationDuration = 0.1f;

@interface MTScrollBarManager : UIView <UIScrollViewDelegate, UITextFieldDelegate> {
    CGPoint lastOffset;
    BOOL isDragging;
    BOOL areTabsVisible;
}

@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) MTNavigationBar *navBar;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *displayedView;
@property (nonatomic, readonly) BOOL areBarsHidden;

- (id)initWithNavBar:(MTNavigationBar *)navBar andToolBar:(UIToolbar *)toolBar andScrollView:(UIScrollView *)scrollView;

- (void)showBars;
- (void)showBarsAnimated:(BOOL)animated;
- (void)hideBars;
- (void)hideBarsAnimated:(BOOL)animated;

- (void)tabsWillBecomeHidden;
- (void)tabsWillBecomeVisible;

@end
