//
//  MTScrollView.h
//  MTPageView
//
//  Created by Jean-Romain on 12/07/2017.
//  Copyright © 2017 JustKodding. All rights reserved.
//

#import "MTPageViewController.h"
#import <UIKit/UIKit.h>

/*!
 * @typedef MTPanDirection
 * @brief A list of pan directions.
 * @constant MTPanDirectionNone Value used when no gesture has been reognized yet.
 * @constant MTPanDirectionUp Value used when the user is scrolling upwards.
 * @constant MTPanDirectionSide Value used when the user is scrolling on the side.
 */
typedef enum {
    MTPanDirectionNone,
    MTPanDirectionUp,
    MTPanDirectionSide,
} MTPanDirection;

static const CGFloat kMovingSizeFactor = 0.9f;
static const CGFloat kMovingHighlightAnimationDuration = 0.2f;
static const CGFloat kScrollMoveDuration = 0.1f;
static const CGFloat kScrollTimeBeforeSpeedIncrease = 1.0f;
static const CGFloat kScrollSpeedIncrement = 3.0f;
static const CGFloat kScrollMoveMaxSpeed = 150.0f;
static const CGFloat kScrollMoveMarginBeforeSpeedIncreaseCancel = 10.0f;
static const CGFloat kMovedAlpha = 0.6f;
static const CGFloat kDraggedAlpha = 0.8f;
static const CGFloat kDragMinFractionBeforeScroll = 0.1f;
static const CGFloat kSwitchGestureEdgeSize = 80.0f;

@class MTPageViewController;
@class MTPageViewContainer;

@interface MTScrollView : UIScrollView {
    MTPageViewContainer *draggedContainer; // The container that the user long-pressed and that is scrolling
    MTPageViewContainer *movedContainer; // The container underneath the dragged containere that is being slightly shifted on the side
    MTPanDirection panDirection;
    CGPoint originalCenter;
    CGPoint originalContentOffset;
    CGPoint touchLocation;
    CGPoint lastMoveGestureChangePosition;
    NSDate *lastMoveGestureChangeTime;
    NSTimer *moveScrollTimer;
    float moveScrollDistance;
}

@property (nonatomic, strong) UIPanGestureRecognizer *switchTabPanGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer *closePanGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *moveGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic, strong) MTPageViewController *parentController;

- (void)cancelTabActions;

@end
