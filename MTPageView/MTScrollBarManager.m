//
//  MTScrollBarManager.m
//  MTPageView
//
//  Created by Jean-Romain on 16/07/2017.
//  Copyright © 2017 JustKodding. All rights reserved.
//

#import "MTScrollBarManager.h"
#import "MTPageViewController.h"

@implementation MTScrollBarManager

- (id)init {
    self = [super init];
    
    if (self) {
        [self initData];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initData];
    }
    
    return self;
}

- (id)initWithNavBar:(MTNavigationBar *)navBar andToolBar:(UIToolbar *)toolBar andScrollView:(UIScrollView *)scrollView {
    self = [super init];
    
    if (self) {
        _navBar = navBar;
        _toolbar = toolBar;
        _scrollView = scrollView;
        _displayedView = scrollView;
        [self initData];
    }
    
    return self;
}

- (void)initData {
    [self setHidden:YES];

    [self.scrollView setContentInset:UIEdgeInsetsMake(self.navBar.frame.origin.y + self.navBar.frame.size.height, 0, [self screenHeight] - self.toolbar.frame.origin.y, 0)];
    [self.scrollView setScrollIndicatorInsets:UIEdgeInsetsMake(self.navBar.frame.origin.y + self.navBar.frame.size.height, 0, [self screenHeight] - self.toolbar.frame.origin.y, 0)];
    [self.scrollView setContentOffset:CGPointMake(0, -self.scrollView.contentInset.top)];
    [self.scrollView setDelegate:self];

    lastOffset = self.scrollView.contentOffset;
    isDragging = NO;
    [self showBarsAnimated:NO];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}

- (float)screenHeight {
    return [UIScreen mainScreen].bounds.size.height;
}

- (void)deviceOrientationDidChange:(NSNotification *)notification {
    // Make sure we update the frame of the bars
    if (self.areBarsHidden) {
        [self forceHideBarsAnimated:NO];
    } else {
        [self forceShowBarsAnimated:NO];
    }
}

- (void)keyboardDidShow:(NSNotification *)notification {
    // Remove additionnal bottom inset as it will be added for the keyboard automatically
    float offset = [self screenHeight] - self.toolbar.frame.origin.y;
    offset /= 2;
    
    [self.scrollView setContentInset:UIEdgeInsetsMake(self.scrollView.contentInset.top, self.scrollView.contentInset.left, self.scrollView.contentInset.bottom - offset, self.scrollView.contentInset.right)];
    [self.scrollView setScrollIndicatorInsets:UIEdgeInsetsMake(self.scrollView.scrollIndicatorInsets.top, self.scrollView.scrollIndicatorInsets.left, self.scrollView.scrollIndicatorInsets.bottom - offset, self.scrollView.scrollIndicatorInsets.right)];
}

- (void)keyboardDidHide:(NSNotification *)notification {
    float offset = [self screenHeight] - self.toolbar.frame.origin.y;
    offset /= 2;
    
    [self.scrollView setContentInset:UIEdgeInsetsMake(self.scrollView.contentInset.top, self.scrollView.contentInset.left, self.scrollView.contentInset.bottom + offset, self.scrollView.contentInset.right)];
    [self.scrollView setScrollIndicatorInsets:UIEdgeInsetsMake(self.scrollView.scrollIndicatorInsets.top, self.scrollView.scrollIndicatorInsets.left, self.scrollView.scrollIndicatorInsets.bottom + offset, self.scrollView.scrollIndicatorInsets.right)];
}


#pragma mark - Scrollview delegate

- (void)showBars {
    [self showBarsAnimated:YES];
}

- (void)showBarsAnimated:(BOOL)animated {
    _areBarsHidden = NO;

    if (self.navBar.frame.size.height != self.navBar.maxHeight) {
        [self forceShowBarsAnimated:animated];
    }
}

- (void)forceShowBarsAnimated:(BOOL)animated {
    [UIView animateWithDuration:kBarsAnimationDuration * animated animations:^{
        [self.navBar setFrame:CGRectMake(self.navBar.frame.origin.x, self.navBar.frame.origin.y, self.navBar.frame.size.width, self.navBar.maxHeight)];
        [self.toolbar setFrame:CGRectMake(self.toolbar.frame.origin.x, [self screenHeight] - self.toolbar.frame.size.height, self.toolbar.frame.size.width, self.toolbar.frame.size.height)];
        [self.scrollView setContentInset:UIEdgeInsetsMake(self.navBar.frame.origin.y + self.navBar.frame.size.height, 0, [self screenHeight] - self.toolbar.frame.origin.y, 0)];
        [self.scrollView setScrollIndicatorInsets:UIEdgeInsetsMake(self.navBar.frame.origin.y + self.navBar.frame.size.height, 0, [self screenHeight] - self.toolbar.frame.origin.y, 0)];
    }];
}

- (void)hideBars {
    [self hideBarsAnimated:YES];
}

- (void)hideBarsAnimated:(BOOL)animated {
    _areBarsHidden = YES;

    if (self.navBar.frame.size.height != self.navBar.minHeight) {
        [self forceHideBarsAnimated:animated];
    }
}

- (void)forceHideBarsAnimated:(BOOL)animated {
    [UIView animateWithDuration:kBarsAnimationDuration * animated animations:^{
        [self.navBar setFrame:CGRectMake(self.navBar.frame.origin.x, self.navBar.frame.origin.y, self.navBar.frame.size.width, self.navBar.minHeight)];
        [self.toolbar setFrame:CGRectMake(self.toolbar.frame.origin.x, [self screenHeight], self.toolbar.frame.size.width, self.toolbar.frame.size.height)];
        [self.scrollView setContentInset:UIEdgeInsetsMake(self.navBar.frame.origin.y + self.navBar.frame.size.height, 0, [self screenHeight] - self.toolbar.frame.origin.y, 0)];
        [self.scrollView setScrollIndicatorInsets:UIEdgeInsetsMake(self.navBar.frame.origin.y + self.navBar.frame.size.height, 0, [self screenHeight] - self.toolbar.frame.origin.y, 0)];
    }];
}

- (void)tabsWillBecomeHidden {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.75 * kTabsShowAnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self forceShowBarsAnimated:YES];
        
        if (self.scrollView.contentOffset.y == -kHeaderViewHeight) {
            // Scroll back to the top
            [UIView animateWithDuration:0.5 * kTabsShowAnimationDuration animations:^{
                [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, -self.scrollView.contentInset.top)];
            } completion:nil];
        }
    });
}

- (void)tabsWillBecomeVisible {
    [self.scrollView setContentInset:UIEdgeInsetsMake(kHeaderViewHeight, 0, 0, 0)];
    [self.scrollView setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    [self showBars];
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x, -self.scrollView.contentInset.top)];
    [self.navBar.textField resignFirstResponder];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.navBar.textField resignFirstResponder];
    lastOffset = scrollView.contentOffset;
    isDragging = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if ([self screenHeight] >= scrollView.contentSize.height) {
        // Can't hide the navBar since the scrollView doesn't have enough content
        [self showBars];
        return;
    }
    
    if (scrollView.contentOffset.y + self.navBar.frame.origin.y + self.navBar.maxHeight <= 0) {
        // Scrolling above the view
        [self showBars];
        return;
    }
    
    if (scrollView.contentOffset.y >= scrollView.contentSize.height - [self screenHeight]) {
        // At the very bottom
        [self showBars];
        return;
    }
    
    if (!isDragging) {
        // Scroll wasn't directly created by user input, ignore it
        return;
    }
    
    float offset = scrollView.contentOffset.y - lastOffset.y;

    if (offset <= 0) {
        // Scrolling up to show the navBar
        if (self.navBar.frame.size.height == self.navBar.minHeight && (CGPointEqualToPoint(CGPointZero, lastOffset) || fabs(offset) < kMinScrollBeforeShowingBar)) {
            // Didn't fast enough and didn't start showing the navBar, ignore this
            lastOffset = scrollView.contentOffset;
            return;
        }
        
        // Start showing the navBar
        float newHeight = self.navBar.frame.size.height + fabs(offset);
        newHeight = MIN(newHeight, self.navBar.maxHeight);
        [self.navBar setFrame:CGRectMake(self.navBar.frame.origin.x, self.navBar.frame.origin.y, self.navBar.frame.size.width, newHeight)];
        
        // Start showing the toolBar
        float newOrigin = self.toolbar.frame.origin.y - fabs(offset);
        newOrigin = MAX([self screenHeight] - self.toolbar.frame.size.height, newOrigin);
        [self.toolbar setFrame:CGRectMake(self.toolbar.frame.origin.x, newOrigin, self.toolbar.frame.size.width, self.toolbar.frame.size.height)];
        
        // Update the view's frame
        [scrollView setContentInset:UIEdgeInsetsMake(self.navBar.frame.origin.y + newHeight, 0, [self screenHeight] - newOrigin, 0)];
        [scrollView setScrollIndicatorInsets:UIEdgeInsetsMake(self.navBar.frame.origin.y + newHeight, 0, [self screenHeight] - newOrigin, 0)];
    } else {
        // Scrolling down to hide the navBar
        
        // Start hiding the navBar
        float newHeight = self.navBar.frame.size.height - fabs(offset);
        newHeight = MAX(newHeight, self.navBar.minHeight);
        [self.navBar setFrame:CGRectMake(self.navBar.frame.origin.x, self.navBar.frame.origin.y, self.navBar.frame.size.width, newHeight)];
        
        // Start hiding the toolBar
        float newOrigin = self.toolbar.frame.origin.y + fabs(offset);
        newOrigin = MIN([self screenHeight], newOrigin);
        [self.toolbar setFrame:CGRectMake(self.toolbar.frame.origin.x, newOrigin, self.toolbar.frame.size.width, self.toolbar.frame.size.height)];
        
        // Update the view's frame
        [scrollView setContentInset:UIEdgeInsetsMake(self.navBar.frame.origin.y + newHeight, 0, [self screenHeight] - newOrigin, 0)];
        [scrollView setScrollIndicatorInsets:UIEdgeInsetsMake(self.navBar.frame.origin.y + newHeight, 0, [self screenHeight] - newOrigin, 0)];
    }
    
    lastOffset = scrollView.contentOffset;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if ((self.navBar.frame.size.height - self.navBar.minHeight) / self.navBar.maxHeight < 0.5) {
        [self hideBars];
    } else {
        [self showBars];
    }
    
    lastOffset = CGPointZero;
    isDragging = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ((self.navBar.frame.size.height - self.navBar.minHeight) / self.navBar.maxHeight < 0.5) {
        [self hideBars];
    } else {
        [self showBars];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    lastOffset = CGPointZero;
    
    if ((self.navBar.frame.size.height - self.navBar.minHeight) / self.navBar.maxHeight < 0.5) {
        [self hideBars];
    } else {
        [self showBars];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    lastOffset = CGPointZero;
    
    if ((self.navBar.frame.size.height - self.navBar.minHeight) / self.navBar.maxHeight < 0.5) {
        [self hideBars];
    } else {
        [self showBars];
    }
}

@end
