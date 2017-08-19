//
//  MTPageViewController.h
//  MTPageView
//
//  Created by Jean-Romain on 12/07/2017.
//  Copyright © 2017 JustKodding. All rights reserved.
//

#import "MTPageViewTab.h"
#import "MTPageViewContainer.h"
#import "MTScrollView.h"
#import <UIKit/UIKit.h>

static const CGFloat kPortraitSizeFactor = 0.75f;
static const CGFloat kLandscapeSizeFactor = 0.7f;

static const CGFloat kPortraitTabDisplayOffset = -12.0f;
static const CGFloat kLandscapeTabDisplayOffset = -22.0f;

static const CGFloat kTabsShowAnimationDuration = 0.3f;
static const CGFloat kTabsCloseAnimationDuration = 0.4f;
static const CGFloat kDefaultTabScrollAnimationDuration = 0.2f;
static const CGFloat kAdditionalTabScrollAnimationDuration = 0.1f;
static const CGFloat kMaxTabScrollAnimationDuration = 1.0f;

static const CGFloat kPageControlDotRadius = 3.5f;
static const CGFloat kPageControlDotSpacing = 9.0f;

@class MTPageViewContainer;
@class MTScrollView;

@interface MTPageViewController : UIViewController <UIScrollViewDelegate> {
    UIBarButtonItem *addTabButton;
}

@property (nonatomic, strong, readonly) NSMutableArray *tabContainers;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) MTScrollView *scrollView;
@property (nonatomic, strong) MTNavigationBar *navBar;
@property (nonatomic, strong) UIToolbar *selectedToolbar;
@property (nonatomic, strong) UIToolbar *deselectedToolbar;
@property (nonatomic, strong) UILabel *tabTitleLabel;
@property (nonatomic, strong) UILabel *numberOfTabsLabel;

@property (nonatomic) CGSize tabSize;
@property (nonatomic, readonly) int currentIndex;
@property (nonatomic, readonly) BOOL tabsAreVisible;

/* Status bar display (used by MTScrollView when closing a tab) */
@property (nonatomic) BOOL hideStatusBar;


/* Customization */
@property (nonatomic) BOOL enableRapideScroll;
@property (nonatomic) BOOL enableTabReordering;


/* Tab management */

/**
 * Creates a new tab and adds it at the end of the tabs list.
 *
 * @return The newly created tab.
 */
- (MTPageViewTab *)addTab;

/**
 * Creates a new tab and adds it at the end of the tabs list.
 *
 * @param animated Whether the addition should be animated or not.
 * @return The newly created tab.
 */
- (MTPageViewTab *)addTabAnimated:(BOOL)animated;

/**
 * Creates a new tab and adds it at the end of the tabs list.
 *
 * @param title The title of the new tab.
 * @return The newly created tab.
 */
- (MTPageViewTab *)addTabWithTitle:(NSString *)title;

/**
 * Creates a new tab and adds it at the end of the tabs list.
 *
 * @param title The title of the new tab.
 * @param animated Whether the addition should be animated or not.
 * @return The newly created tab.
 */
- (MTPageViewTab *)addTabWithTitle:(NSString *)title animated:(BOOL)animated;

/**
 * Creates a new tab and adds it at the given index.
 *
 * @param index The index at which the new tab should be added.
 * @return The newly created tab.
 */
- (MTPageViewTab *)insertTabAtIndex:(int)index;

/**
 * Creates a new tab and adds it at the given index.
 *
 * @param index The index at which the new tab should be added.
 * @param animated Whether the addition should be animated or not.
 * @return The newly created tab.
 */
- (MTPageViewTab *)insertTabAtIndex:(int)index animated:(BOOL)animated;

/**
 * Creates a new tab and adds it at the given index.
 *
 * @param index The index at which the new tab should be added.
 * @param title The title of the new tab.
 * @return The newly created tab.
 */
- (MTPageViewTab *)insertTabAtIndex:(int)index withTitle:(NSString *)title;

/**
 * Creates a new tab and adds it at the given index.
 *
 * @param index The index at which the new tab should be added.
 * @param title The title of the new tab.
 * @param animated Whether the addition should be animated or not.
 * @return The newly created tab.
 */
- (MTPageViewTab *)insertTabAtIndex:(int)index withTitle:(NSString *)title animated:(BOOL)animated;

/**
 * Reorders tabs by moving a tab to a new index.
 *
 * @param fromIndex The index of the tab that should be moved.
 * @param toIndex The index to which the tab should be moved.
 */
- (void)moveTabAtIndex:(int)fromIndex toIndex:(int)toIndex;

/**
 * Reorders tabs by moving a tab to a new index.
 *
 * @param fromIndex The index of the tab that should be moved.
 * @param toIndex The index to which the tab should be moved.
 * @param animated Whether the reordering should be animated or not.
 */
- (void)moveTabAtIndex:(int)fromIndex toIndex:(int)toIndex animated:(BOOL)animated;

/**
 * Closes the currently selected tab.
 */
- (void)closeCurrentTab;

/**
 * Closes all the tabs.
 */
- (void)closeAllTabs;

/**
 * Closes the tab at the given index.
 *
 * @param index The index of the tab that should be closed.
 */
- (void)closeTabAtIndex:(int)index;

/**
 * Closes the tab at the given index.
 *
 * @param index The index of the tab that should be closed.
 * @param animated Whether the removal should be animated or not.
 */
- (void)closeTabAtIndex:(int)index animated:(BOOL)animated;

/**
 * Closes the tab at the given index.
 *
 * @param index The index of the tab that should be closed.
 * @param animated Whether the removal should be animated or not.
 * @param completion A block called when the tab finished being closed completed.
 */
- (void)closeTabAtIndex:(int)index animated:(BOOL)animated completion:(void (^) (BOOL finished))completion;


/* Tabs info */

/**
 * Gets the currenty selected tab.
 *
 * @return The current tab.
 */
- (MTPageViewTab *)currentTab;

/**
 * Gets the tab at the given index.
 *
 * @param index Index of the tab.
 * @return The tab at the index.
 */
- (MTPageViewTab *)tabAtIndex:(int)index;

/**
 * Gets the currenty selected tab's container.
 *
 * @return The current container.
 */
- (MTPageViewContainer *)currentContainer;

/**
 * Gets the container of the tab at the given index.
 *
 * @param index Index of the tab.
 * @return The container of the tab at the index.
 */
- (MTPageViewContainer *)containerAtIndex:(int)index;

/**
 * @return The number of tabs.
 */
- (int)tabsCount;

/**
 * Forces the update of the title displayed above the tab.
 */
- (void)updateDisplayedTitle;

/**
 * Forces the update of the selected tab, based on the scrollView's content offset.
 */
- (void)updateSelectedTabIndex;

/**
 * Forces the update of the selected tab, based on the scrollView's content offset.
 *
 * @param round Whether the computations should be made by finding the closest tab or by truncating the partial index.
 */
- (void)updateSelectedTabIndexRoundIndex:(BOOL)round;

/**
 * Forces the update of the page control's frame.
 */
- (void)updatePageControlFrame;

/**
 * Updates the displayed status bar.
 */
- (void)updateStatusBarDisplay;


/* Tabs display */
/**
 * Zooms out of the current tab to show all the open tabs.
 */
- (void)showTabs;

/**
 * Zooms out of the current tab to show all the open tabs.
 *
 * @param animated Whether the zoom should be animated or not.
 */
- (void)showTabsAnimated:(BOOL)animated;

/**
 * Zooms in to the current tab to focus on that particular view.
 */
- (void)hideTabs;

/**
 * Zooms in to the current tab to focus on that particular view.
 *
 * @param animated Whether the zoom should be animated or not.
 */
- (void)hideTabsAnimated:(BOOL)animated;


/* Convenient methods */

/**
 * Scrolls to the given tab index.
 *
 * @param index The index of the tab to which the scrollView should scroll.
 */
- (void)scrollToIndex:(int)index;

/**
 * Forces the update of the selected tab, based on the scrollView's content offset.
 *
 * @param index The index of the tab to which the scrollView should scroll.
 * @param animated Whether the scroll should be animated or not.
 */
- (void)scrollToIndex:(int)index animated:(BOOL)animated;

/**
 * Forces the update of the selected tab, based on the scrollView's content offset.
 *
 * @param index The index of the tab to which the scrollView should scroll.
 * @param completion A block called when the scroll completed.
 */
- (void)scrollToIndex:(int)index completion:(void (^) (BOOL finished))completion;

/**
 * Forces the update of the selected tab, based on the scrollView's content offset.
 *
 * @param index The index of the tab to which the scrollView should scroll.
 * @param animated Whether the scroll should be animated or not.
 * @param completion A block called when the scroll completed.
 */
- (void)scrollToIndex:(int)index animated:(BOOL)animated completion:(void (^)(BOOL finished))completion;


/**
 * Gets the closest index to the given point.
 *
 * @param point The position at which the tab should be found.
 * @return Index of the tab.
 */
- (int)tabIndexAtPoint:(CGPoint)point;


/* Overridable methods */

/**
 * Use to override the creation of a tab in order to customize it or use a different class.
 *
 * @param index The index at which the tab will be added.
 * @param title The title of the tab.
 * @return The tab that should be added.
 */
- (MTPageViewTab *)newTabAtIndex:(int)index withTitle:(NSString *)title;

/**
 * Use to override the creation of a container in order to customize it or use a different class.
 *
 * @param tab The tab related to the container.
 * @return The container for the given tab.
 */
- (MTPageViewContainer *)newContainerForTab:(MTPageViewTab *)tab;

/**
 * Use to prevent some tabs from being moved at all.
 *
 * @return Boolean indicating if the reordering should begin.
 */
- (BOOL)canStartMovingTabAtIndex:(int)index;

/**
 * Use to prevent some tabs from being moved at certain indexes.
 *
 * @return Boolean indicating if the reordering should occure.
 */
- (BOOL)canMoveTabAtIndex:(int)index toIndex:(int)toIndex;

/**
 * Use to prevent too many tabs from being added.
 *
 * @return Boolean indicating if the addition should occure.
 */
- (BOOL)canAddTab;

/**
 * Use to prevent specific tabs from being closed.
 *
 * @return Boolean indicating if the removal should occure.
 */
- (BOOL)canCloseTabAtIndex:(int)index;


/* Events */

/**
 * Callback invoked before a new tab is added.
 *
 * @param index The index of the future tab.
 */
- (void)willAddNewTabAtIndex:(int)index;

/**
 * Callback invoked after a new tab has been added.
 *
 * @param index The index of the new tab.
 */
- (void)didAddNewTabAtIndex:(int)index;

/**
 * Callback invoked before a new tab is moved.
 *
 * @param fromIndex The index of the tab being moved.
 * @param toIndex The index to which the tab is being moved.
 */
- (void)willMoveTabAtIndex:(int)fromIndex toIndex:(int)toIndex;

/**
 * Callback invoked after a new tab has been moved.
 *
 * @param fromIndex The previous index of the tab.
 * @param toIndex The new index of the tab.
 */
- (void)didMoveTabAtIndex:(int)fromIndex toIndex:(int)toIndex;

/**
 * Callback invoked before a tab is closed.
 *
 * @param index The index of the tab that will be closed.
 */
- (void)willCloseTabAtIndex:(int)index;

/**
 * Callback invoked after a tab has been closed.
 *
 * @param index The old index of the tab that has been closed.
 */
- (void)didCloseTabAtIndex:(int)index;

/**
 * Callback invoked before the zoom out occures to show the tabs.
 */
- (void)tabsWillBecomeVisible;

/**
 * Callback invoked when the zoom out to show the tabs ended.
 */
- (void)tabsDidBecomeVisible;

/**
 * Callback invoked before the zoom in occures to focus on a single tab.
 */
- (void)tabsWillBecomeHidden;

/**
 * Callback invoked when the zoom in to focus on a single tab ended.
 */
- (void)tabsDidBecomeHidden;

/**
 * Callback invoked when the user long-presses a tab
 *
 * @param index The index of the tab.
 */
- (void)didBeginMovingTabAtIndex:(int)index;

/**
 * Callback invoked when the cancels the reordering or places a tab back where it was before the gesture.
 *
 * @param index The index of the tab.
 */
- (void)didCancelMovingTabAtIndex:(int)index;

/**
 * Callback invoked when the user's finger is lifted and a tab has to be moved.
 *
 * @param fromIndex The old index of the tab.
 * @param toIndex The new index of the tab.
 */
- (void)didFinishMovingTabAtIndex:(int)fromIndex toIndex:(int)toIndex;

/**
 * Callback invoked when the user starts swiping up a tab to close it.
 *
 * @param index The index of the tab.
 */
- (void)didBeginClosingTabAtIndex:(int)index;

/**
 * Callback invoked when the user cancels the swipe or places the tab back where it was before the gesture.
 *
 * @param index The index of the tab.
 */
- (void)didCancelClosingTabAtIndex:(int)index;

/**
 * Callback invoked when the user's finger is lifted and the tab should be closed.
 *
 * @param index The index of the now closed tab.
 */
- (void)didFinishClosingTabAtIndex:(int)index;

/**
 * Callback invoked when the user starts swiping with 2+ fingers to change tabs while a tab is focused.
 *
 * @param index The index of the tab.
 */
- (void)didBeginSwitchingTabAtIndex:(int)index;

/**
 * Callback invoked when the user cancels the swipe or places the tab back where it was before the gesture.
 *
 * @param index The index of the tab.
 */
- (void)didCancelSwitchingTabAtIndex:(int)index;

/**
 * Callback invoked when the user's fingers are lifted and the current tab should be changed.
 *
 * @param fromIndex The index of the previously focused tab.
 * @param toIndex The index of the newly focused tab.
 */
- (void)didFinishSwitchingTabAtIndex:(int)fromIndex toIndex:(int)toIndex;

@end
