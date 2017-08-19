//
//  MTScrollView.m
//  MTPageView
//
//  Created by Jean-Romain on 12/07/2017.
//  Copyright © 2017 JustKodding. All rights reserved.
//

#import "MTScrollView.h"

@implementation MTScrollView

- (id)init {
    self = [super init];
    
    if (self) {
        [self initScrollView];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initScrollView];
    }
    
    return self;
}

- (void)initScrollView {    
    self.moveGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self addGestureRecognizer:self.moveGestureRecognizer];
    
    self.closePanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleClosePan:)];
    [self.closePanGestureRecognizer requireGestureRecognizerToFail:self.moveGestureRecognizer];
    [self addGestureRecognizer:self.closePanGestureRecognizer];
    
    self.switchTabPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwitchPan:)];
    [self.switchTabPanGestureRecognizer setMinimumNumberOfTouches:2];
    [self.switchTabPanGestureRecognizer setDelaysTouchesBegan:NO];
    [self.switchTabPanGestureRecognizer setDelaysTouchesEnded:NO];
    [self.switchTabPanGestureRecognizer setMaximumNumberOfTouches:2];
    [self.switchTabPanGestureRecognizer setCancelsTouchesInView:NO];
    [self addGestureRecognizer:self.switchTabPanGestureRecognizer];
    
#warning Kinda hacky
    // Add a tap gesture recognizer to prevent scrollViewWillEndDragging being called by simply tapping the scroll view (usually after scrolling to change tab), making the view scroll back 1 tab
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];
    [self.tapGestureRecognizer setNumberOfTouchesRequired:1];
    [self.tapGestureRecognizer setNumberOfTapsRequired:1];
    [self addGestureRecognizer:self.tapGestureRecognizer];
    [self.panGestureRecognizer requireGestureRecognizerToFail:self.tapGestureRecognizer]; // This makes it so that tapGestureRecognizer fires before didEndDragging
    
    panDirection = MTPanDirectionNone;
    draggedContainer = nil;
    movedContainer = nil;
    originalCenter = CGPointZero;
    originalContentOffset = CGPointZero;
    touchLocation = CGPointZero;
    lastMoveGestureChangePosition = CGPointZero;
    moveScrollDistance = 0.0;
    [moveScrollTimer invalidate];
    moveScrollTimer = nil;
    lastMoveGestureChangeTime = nil;
}

- (void)cancelTabActions {
    // Cancel moving tab
    if (draggedContainer) {
        [self.parentController didCancelMovingTabAtIndex:draggedContainer.tab.index];
    }
    [UIView animateWithDuration:0.5 animations:^{
        [draggedContainer setCenter:originalCenter];
    } completion:nil];
    
    // Cancel closing tab
    if (panDirection == MTPanDirectionUp && draggedContainer) {
        [self.parentController didCancelClosingTabAtIndex:draggedContainer.tab.index];
    }
    [self.parentController setHideStatusBar:NO];
    [UIView animateWithDuration:0.10 animations:^{
        [self.parentController updateStatusBarDisplay];
        [[self.parentController tabTitleLabel] setAlpha:1.0];
    }];
    
    // Reset container appearance
    [UIView animateWithDuration:kMovingHighlightAnimationDuration animations:^{
        [movedContainer.leftArrow setAlpha:0.0];
        [movedContainer.rightArrow setAlpha:0.0];
        [movedContainer setAlpha:1.0];
        [draggedContainer setAlpha:1.0];
        
        [self resetMovingAppearance];
    }];
    
    // Cancel switching tab
    if (self.switchTabPanGestureRecognizer.isEnabled && panDirection == MTPanDirectionSide) {
        [self.parentController didCancelSwitchingTabAtIndex:self.parentController.currentIndex];
    }
    panDirection = MTPanDirectionNone;
    touchLocation = CGPointZero;
    
    // Reset status bar and title label's appearences
    [self.parentController setHideStatusBar:NO];
    [UIView animateWithDuration:0.10 animations:^{
        [self.parentController updateStatusBarDisplay];
        [[self.parentController tabTitleLabel] setAlpha:1.0];
    }];
    
    // Reset scroll
    [self setScrollEnabled:self.parentController.tabsAreVisible];
    panDirection = MTPanDirectionNone;
    draggedContainer = nil;
    movedContainer = nil;
    originalCenter = CGPointZero;
    originalContentOffset = CGPointZero;
    touchLocation = CGPointZero;
    lastMoveGestureChangePosition = CGPointZero;
    moveScrollDistance = 0.0;
    [moveScrollTimer invalidate];
    moveScrollTimer = nil;
    lastMoveGestureChangeTime = nil;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)handleTap {
    if (self.isDragging) {
        // Make scrollViewWillEndDragging ignore this
        BOOL scrollEnabled = self.isScrollEnabled;
        [self setScrollEnabled:NO];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self setScrollEnabled:scrollEnabled];
        });
    }
}

- (void)handleClosePan:(UIPanGestureRecognizer *)gesture {
    CGPoint vel = [gesture velocityInView:self];

    if (panDirection == MTPanDirectionNone) {
        if (fabs(vel.x) > fabs(vel.y) && fabs(vel.x) > 50) {
            // User is trying to change tab
            panDirection = MTPanDirectionSide;
        } else if (fabs(vel.y) > fabs(vel.x) && vel.y < -50) { // We only care about speed < 0 because the user needs to swipe up to close the tab
            // User is trying to close a tab
            CGPoint location = [gesture locationInView:self.superview];
            int nearestIndex = [self.parentController tabIndexAtPoint:CGPointMake(location.x + self.contentOffset.x, location.y + self.contentOffset.y)];

            if (![self.parentController canCloseTabAtIndex:nearestIndex]) {
                // Can't close this tab
                return;
            }
            
            panDirection = MTPanDirectionUp;
            draggedContainer = [self.parentController.tabContainers objectAtIndex:nearestIndex];
            originalCenter = draggedContainer.center;
            [self.parentController scrollToIndex:nearestIndex animated:YES];
        }
    }
    
    if (panDirection == MTPanDirectionSide) {
        if (gesture.state == UIGestureRecognizerStateEnded) {
            panDirection = MTPanDirectionNone;
            return;
        }
    } else if (panDirection == MTPanDirectionUp) {
        CGFloat yDistance = [gesture translationInView:self].y;
        
        switch (gesture.state) {
            case UIGestureRecognizerStateBegan: {
                [self setScrollEnabled:NO];
                [self.parentController didBeginClosingTabAtIndex:draggedContainer.tab.index];
                break;
            }
                
            case UIGestureRecognizerStateChanged: {
                if (yDistance <= 0) {
                    // Don't animate if the user is swiping really fast, otherwise the tab is closed before the animation ends and it looks ugly
                    if (ABS(vel.y) <= 1000) {
                        // Hide the status bar and the title label
                        [self.parentController setHideStatusBar:YES];
                        [UIView animateWithDuration:0.10 animations:^{
                            [[self.parentController tabTitleLabel] setAlpha:0.0];
                            [self.parentController updateStatusBarDisplay];
                        }];
                    }
                    
                    // Move the tab up
                    [draggedContainer setCenter:CGPointMake(originalCenter.x, originalCenter.y + yDistance)];
                } else {
                    [draggedContainer setCenter:originalCenter];
                    [self.parentController setHideStatusBar:NO];
                    [UIView animateWithDuration:0.10 animations:^{
                        [[self.parentController tabTitleLabel] setAlpha:1.0];
                        [self.parentController updateStatusBarDisplay];
                    }];
                }
                break;
            };
                
            case UIGestureRecognizerStateCancelled: {
                [self.parentController didCancelClosingTabAtIndex:draggedContainer.tab.index];
                [self.parentController scrollToIndex:draggedContainer.tab.index];
                
                // Reset status bar and title label's appearences
                [self.parentController setHideStatusBar:NO];
                [UIView animateWithDuration:0.10 animations:^{
                    [self.parentController updateStatusBarDisplay];
                    [[self.parentController tabTitleLabel] setAlpha:1.0];
                }];
                
                // Reset scroll
                [self setScrollEnabled:YES];
                panDirection = MTPanDirectionNone;
                draggedContainer = nil;
                originalCenter = CGPointZero;
            }
                
            case UIGestureRecognizerStateFailed: {
                [self.parentController didCancelClosingTabAtIndex:draggedContainer.tab.index];
                [self.parentController scrollToIndex:draggedContainer.tab.index];
                
                // Reset status bar and title label's appearences
                [self.parentController setHideStatusBar:NO];
                [UIView animateWithDuration:0.10 animations:^{
                    [self.parentController updateStatusBarDisplay];
                    [[self.parentController tabTitleLabel] setAlpha:1.0];
                }];
                
                // Reset scroll
                [self setScrollEnabled:YES];
                panDirection = MTPanDirectionNone;
                draggedContainer = nil;
                originalCenter = CGPointZero;
            }
                
            case UIGestureRecognizerStateEnded: {
                if (-yDistance <= self.frame.size.height / 3 && vel.y >= -1500) {
                    // Moved the view less than 1/3rd of the view height, or is not moving fast enough to consider the user wants to close
                    [self.parentController didCancelClosingTabAtIndex:draggedContainer.tab.index];
                    [UIView animateWithDuration:0.5 animations:^{
                        [draggedContainer setCenter:originalCenter];
                    } completion:^(BOOL finished) {}];
                } else {
                    // Moved the view enough, or it's moving fast enough to consider the user wants to close
                    [self.parentController didFinishClosingTabAtIndex:draggedContainer.tab.index];

                    [UIView animateWithDuration:0.2 animations:^{
                        draggedContainer.alpha = 0;
                        [draggedContainer setCenter:CGPointMake(originalCenter.x, - originalCenter.y)];
                    } completion:^(BOOL finished) {
                        [self.parentController closeCurrentTab];
                    }];
                }
                
                // Reset status bar and title label's appearences
                [self.parentController setHideStatusBar:NO];
                [UIView animateWithDuration:0.10 animations:^{
                    [self.parentController updateStatusBarDisplay];
                    [[self.parentController tabTitleLabel] setAlpha:1.0];
                }];

                // Reset scroll
                [self setScrollEnabled:YES];
                panDirection = MTPanDirectionNone;
                draggedContainer = nil;
                originalCenter = CGPointZero;

                break;
            };
                
            default:
                break;
        }
    }
}

- (void)handleSwitchPan:(UIPanGestureRecognizer *)gesture {
    if (!self.parentController.enableRapideScroll) {
        return;
    }
    
    CGPoint vel = [gesture velocityInView:self];
    
    if (CGPointEqualToPoint(touchLocation, CGPointZero)) {
        touchLocation = [gesture locationInView:self.parentController.currentContainer];
    }
    
    if (panDirection == MTPanDirectionNone && fabs(vel.x) > 50 && self.parentController.tabsCount > 1) {
        // User is trying to change tab, and there are at least 2 tabs
        if (touchLocation.x <= kSwitchGestureEdgeSize || touchLocation.x >= (self.parentController.currentContainer.bounds.size.width - kSwitchGestureEdgeSize)) {
            // User started from the edge of the screen
            panDirection = MTPanDirectionSide;
            [self.parentController didBeginSwitchingTabAtIndex:self.parentController.currentIndex];
        }
    }
    
    if (panDirection == MTPanDirectionSide) {
        CGFloat xDistance = [gesture translationInView:self].x;
        
        switch (gesture.state) {
            case UIGestureRecognizerStateChanged: {
                // Disable "impossible" drags to remove ugly transitions
                if (xDistance < 0 && self.parentController.currentIndex == self.parentController.tabsCount - 1) {
                    xDistance = 0;
                } else if (xDistance > 0 && self.parentController.currentIndex == 0) {
                    xDistance = 0;
                }
                
                // Only scroll up to 1 tab
                xDistance = MAX(-self.parentController.tabSize.width, MIN(self.parentController.tabSize.width, xDistance));
                
                [self setContentOffset:CGPointMake(self.parentController.currentIndex * self.parentController.tabSize.width - xDistance, self.contentOffset.y) animated:NO];
                
                break;
            };
                
            case UIGestureRecognizerStateCancelled: {
                [self.parentController didCancelSwitchingTabAtIndex:self.parentController.currentIndex];
                [self.parentController scrollToIndex:self.parentController.currentIndex];
                
                // Reset everything
                panDirection = MTPanDirectionNone;
                touchLocation = CGPointZero;
            }
                
            case UIGestureRecognizerStateFailed: {
                [self.parentController didCancelSwitchingTabAtIndex:self.parentController.currentIndex];
                [self.parentController scrollToIndex:self.parentController.currentIndex];
                
                // Reset everything
                panDirection = MTPanDirectionNone;
                touchLocation = CGPointZero;
            }
                
            case UIGestureRecognizerStateEnded: {
                if ((xDistance <= -100 || vel.x <= -300) && self.parentController.currentIndex < self.parentController.tabsCount - 1) {
                    // Moved enough to change tab (go right), and there is at least 1 tab on the right
                    [self.parentController.currentTab.scrollBarManager showBarsAnimated:YES];
                    [self.parentController scrollToIndex:self.parentController.currentIndex + 1];
                    [self.parentController didFinishSwitchingTabAtIndex:self.parentController.currentIndex toIndex:self.parentController.currentIndex + 1];
                } else if ((xDistance >= 100 || vel.x >= 300) && self.parentController.currentIndex > 0) {
                    // Moved enough to change tab (go left), and there is at least 1 tab on the left
                    [self.parentController.currentTab.scrollBarManager showBarsAnimated:YES];
                    [self.parentController scrollToIndex:self.parentController.currentIndex - 1];
                    [self.parentController didFinishSwitchingTabAtIndex:self.parentController.currentIndex toIndex:self.parentController.currentIndex - 1];
                } else {
                    // Scroll back to the previous index
                    [self.parentController.currentTab.scrollBarManager showBarsAnimated:YES];
                    [self.parentController scrollToIndex:self.parentController.currentIndex];
                    [self.parentController didCancelSwitchingTabAtIndex:self.parentController.currentIndex];
                }
                
                // Update the searchBar to match the selected tab
                [self.parentController updateDisplayedTitle];
                [self.parentController updateSelectedTabIndex];
                
                // Reset everything
                panDirection = MTPanDirectionNone;
                touchLocation = CGPointZero;
                
                break;
            };
                
            default: break;
        }
        
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        touchLocation = CGPointZero;
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)gesture {
    if (!self.parentController.enableTabReordering) {
        return;
    }
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            touchLocation = [gesture locationInView:self.superview];
            
            int nearestIndex = [self.parentController tabIndexAtPoint:CGPointMake(touchLocation.x + self.contentOffset.x, touchLocation.y + self.contentOffset.y)];
            
            if (![self.parentController canStartMovingTabAtIndex:nearestIndex]) {
                // Cancel the touch
                [gesture setEnabled:NO];
                [gesture setEnabled:YES];
                return;
            }
            
            [self setScrollEnabled:NO];
            
            float xDistance = [gesture locationInView:self.superview].x - self.superview.center.x;
            if (fabs(xDistance) < kDragMinFractionBeforeScroll * self.frame.size.width) {
                moveScrollDistance = 0;
            } else {
                moveScrollDistance = xDistance / 3;
            }
            
            draggedContainer = [self.parentController.tabContainers objectAtIndex:nearestIndex];
            originalCenter = draggedContainer.center;
            originalContentOffset = self.contentOffset;
            [self.parentController scrollToIndex:nearestIndex animated:YES];
            [self bringSubviewToFront:draggedContainer];
            
            [self.parentController didBeginMovingTabAtIndex:draggedContainer.tab.index];
            
            [UIView animateWithDuration:kMovingHighlightAnimationDuration animations:^{
                [draggedContainer setAlpha:kDraggedAlpha];
                CGAffineTransform translation = CGAffineTransformMakeTranslation(draggedContainer.transform.tx, draggedContainer.transform.ty);
                CGAffineTransform transform = CGAffineTransformScale(translation, draggedContainer.transform.a * kMovingSizeFactor, draggedContainer.transform.d * kMovingSizeFactor);
                [draggedContainer setTransform:transform];
                
                float touchDistance = touchLocation.x - self.frame.size.width / 2;
                [draggedContainer setCenter:CGPointMake(originalCenter.x + touchDistance, originalCenter.y)];
            } completion:^(BOOL finished) {
                moveScrollTimer = [NSTimer scheduledTimerWithTimeInterval:kScrollMoveDuration target:self selector:@selector(scrollToMoveTab) userInfo:nil repeats:YES];
            }];
            
            break;
        }
            
        case UIGestureRecognizerStateChanged: {
            // Find distance from the center of the view
            touchLocation = [gesture locationInView:self.superview];
            float xDistance = [gesture locationInView:self.superview].x - self.superview.center.x;
            
            if (fabs(xDistance) < kDragMinFractionBeforeScroll * self.frame.size.width) {
                moveScrollDistance = 0;
            } else {
                moveScrollDistance = xDistance / 3;
            }
            
            // If the user's finger moved enough, stop accerlerating the movement
            if (fabs(touchLocation.x - lastMoveGestureChangePosition.x) > kScrollMoveMarginBeforeSpeedIncreaseCancel) {
                lastMoveGestureChangePosition = touchLocation;
                lastMoveGestureChangeTime = [NSDate date];
            }
            break;
        };
        
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed: {
            if (draggedContainer) {
                [self.parentController didCancelClosingTabAtIndex:draggedContainer.tab.index];
                [self.parentController scrollToIndex:draggedContainer.tab.index];

                [self resetMoving];
            }
            break;
        }
        
        case UIGestureRecognizerStateEnded: {
            if (!draggedContainer) {
                break;
            }
            
            BOOL movedTab = NO;
            
            if (movedContainer && [self shouldShowLeftArrowForContainer:movedContainer]) {
                // Moved draggedContainer to movedContainer's index
                [self.parentController didFinishMovingTabAtIndex:draggedContainer.tab.index toIndex:movedContainer.tab.index + 1];
                [self.parentController moveTabAtIndex:draggedContainer.tab.index toIndex:movedContainer.tab.index + 1];
                movedTab = YES;
            } else if (movedContainer && [self shouldShowRightArrowForContainer:movedContainer]) {
                // Moved draggedContainer to movedContainer's index - 1
                [self.parentController didFinishMovingTabAtIndex:draggedContainer.tab.index toIndex:movedContainer.tab.index];
                [self.parentController moveTabAtIndex:draggedContainer.tab.index toIndex:movedContainer.tab.index];
                movedTab = YES;
            } else {
                // Don't move the container
                [self.parentController didCancelClosingTabAtIndex:draggedContainer.tab.index];
                [self.parentController scrollToIndex:draggedContainer.tab.index];
            }
            
            // Reset container appearance
            [UIView animateWithDuration:kMovingHighlightAnimationDuration animations:^{
                [movedContainer.leftArrow setAlpha:0.0];
                [movedContainer.rightArrow setAlpha:0.0];
                [movedContainer setAlpha:1.0];

                [draggedContainer setAlpha:1.0];
                
                if (!movedTab) {
                    // Moving the tab resets its size and position
                    [self resetMovingAppearance];
                }
            }];
            
            // Reset scroll
            [self setScrollEnabled:YES];
            draggedContainer = nil;
            movedContainer = nil;
            originalCenter = CGPointZero;
            originalContentOffset = CGPointZero;
            touchLocation = CGPointZero;
            lastMoveGestureChangePosition = CGPointZero;
            moveScrollDistance = 0.0;
            [moveScrollTimer invalidate];
            moveScrollTimer = nil;
            lastMoveGestureChangeTime = nil;
            
            [self.parentController updateSelectedTabIndex];
            [self.parentController updatePageControlFrame];
            [self.parentController updateDisplayedTitle];

            break;
        };
            
        default:
            break;
    }
}

- (void)resetMoving {
    [self resetMovingAppearance];
    
    // Reset scroll
    [self setScrollEnabled:YES];
    draggedContainer = nil;
    movedContainer = nil;
    originalCenter = CGPointZero;
    originalContentOffset = CGPointZero;
    touchLocation = CGPointZero;
    lastMoveGestureChangePosition = CGPointZero;
    moveScrollDistance = 0.0;
    [moveScrollTimer invalidate];
    moveScrollTimer = nil;
    lastMoveGestureChangeTime = nil;
    
    [self.parentController updateSelectedTabIndex];
    [self.parentController updatePageControlFrame];
    [self.parentController updateDisplayedTitle];
}

- (void)resetMovingAppearance {
    // Reset container appearance
    [UIView animateWithDuration:kMovingHighlightAnimationDuration animations:^{
        [movedContainer.leftArrow setAlpha:0.0];
        [movedContainer.rightArrow setAlpha:0.0];
        [movedContainer setAlpha:1.0];
        [draggedContainer setAlpha:1.0];
        
        CGAffineTransform translation = CGAffineTransformMakeTranslation(draggedContainer.transform.tx, draggedContainer.transform.ty);
        CGAffineTransform transform = CGAffineTransformScale(translation, draggedContainer.transform.a / kMovingSizeFactor, draggedContainer.transform.d / kMovingSizeFactor);
        [draggedContainer setTransform:transform];
        
        [draggedContainer setCenter:originalCenter];
    }];
}

- (BOOL)shouldShowRightArrowForContainer:(MTPageViewContainer *)container {
    return draggedContainer.center.x < container.center.x;
}

- (BOOL)shouldShowLeftArrowForContainer:(MTPageViewContainer *)container {
    return draggedContainer.center.x >= container.center.x;
}

- (void)scrollToMoveTab {
    // Add an arrow on the container that will be moved to insert the draggedContainer at the right index
    CGPoint location = [self.moveGestureRecognizer locationInView:self.superview];
    int nearestIndex = [self.parentController tabIndexAtPoint:CGPointMake(location.x + self.contentOffset.x, location.y + self.contentOffset.y)];
    __block MTPageViewContainer *movableContainer = [self.parentController.tabContainers objectAtIndex:nearestIndex];
    
    if (movableContainer != movedContainer) {        
        // This doesn't apply to the dragged container
        if (movableContainer.tab.index == draggedContainer.tab.index || ![self.parentController canMoveTabAtIndex:draggedContainer.tab.index toIndex:movableContainer.tab.index]) {
            // Don't add arrows on that container as it won't be moved
            movableContainer = nil;
        }
        
        [UIView animateWithDuration:kScrollMoveDuration delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            // Add arrow on movableContainer and remove it from movedContainer
            [movedContainer.leftArrow setAlpha:0.0];
            [movedContainer.rightArrow setAlpha:0.0];
            
            [movedContainer setAlpha:1.0];
            [movableContainer setAlpha:kMovedAlpha];
            
            // Find on which side the dragged container is
            if ([self shouldShowRightArrowForContainer:movableContainer]) {
                // Currently on the left of the container
                [movableContainer.leftArrow setAlpha:0.0];
                [movableContainer.rightArrow setAlpha:kArrowViewAlpha];
            } else {
                // Currently on the right of the container
                [movableContainer.leftArrow setAlpha:kArrowViewAlpha];
                [movableContainer.rightArrow setAlpha:0.0];
            }
        } completion:^(BOOL finished) {
            movedContainer = movableContainer;
        }];
    } else {
        [UIView animateWithDuration:kScrollMoveDuration delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
            // Find on which side the dragged container is
            if ([self shouldShowRightArrowForContainer:movableContainer]) {
                // Currently on the left of the container
                [movableContainer.leftArrow setAlpha:0.0];
                [movableContainer.rightArrow setAlpha:kArrowViewAlpha];
            } else {
                // Currently on the right of the container
                [movableContainer.leftArrow setAlpha:kArrowViewAlpha];
                [movableContainer.rightArrow setAlpha:0.0];
            }
        } completion:nil];
    }
    
    float distance = moveScrollDistance;
    float interval = [[NSDate date] timeIntervalSinceDate:lastMoveGestureChangeTime];
    
    if (fabs(distance) > 0 && interval > kScrollTimeBeforeSpeedIncrease) {
        float sign = distance / fabs(distance);
        distance += sign * MIN(kScrollMoveMaxSpeed, kScrollSpeedIncrement * (interval - kScrollTimeBeforeSpeedIncrease) / kScrollMoveDuration);
    }
    
    // Scroll through the tabs
    [UIView animateWithDuration:kScrollMoveDuration delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        // Don't scroll out of bounds of the scroll content
        float xContentOffset = MAX(0, MIN(self.contentOffset.x + distance, self.contentSize.width - self.parentController.tabSize.width));
        
        // Scroll based on the user's finger position
        [self setContentOffset:CGPointMake(xContentOffset, self.contentOffset.y)];
        
        // Position the view under the user's finger
        float touchDistance = touchLocation.x - self.frame.size.width / 2;
        float scrolledDistance = xContentOffset - originalContentOffset.x;
        [draggedContainer setCenter:CGPointMake(originalCenter.x + touchDistance + scrolledDistance, originalCenter.y)];
    } completion:^(BOOL finished) {
        [self.parentController updateSelectedTabIndexRoundIndex:YES];
        [self.parentController updatePageControlFrame];
        [self.parentController updateDisplayedTitle];
    }];
}

@end
