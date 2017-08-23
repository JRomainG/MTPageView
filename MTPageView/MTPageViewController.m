//
//  MTPageViewController.m
//  MTPageView
//
//  Created by Jean-Romain on 12/07/2017.
//  Copyright © 2017 JustKodding. All rights reserved.
//

#import "MTPageViewController.h"

@interface MTPageViewController ()

@end

@implementation MTPageViewController

- (id)init {
    self = [super init];
    
    if (self) {
        [self initializeView];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self initializeView];
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        [self initializeView];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeView {
    [self.navigationController.navigationBar setHidden:YES];
    [self setAutomaticallyAdjustsScrollViewInsets:NO];

    _tabContainers = [[NSMutableArray alloc] init];
    _currentIndex = 0;
    _tabSize = self.view.frame.size;
    _tabsAreVisible = YES;
    _hideStatusBar = NO;
    _enableRapideScroll = YES;
    _enableTabReordering = YES;
    
    // Create page control
    CGRect pageControlFrame = CGRectMake(0, self.view.frame.size.height - 18 - 44, self.view.frame.size.width, 10);
    self.pageControl = [[UIPageControl alloc] initWithFrame:pageControlFrame];
    [self.pageControl setNumberOfPages:0];
    [self.pageControl setHidesForSinglePage:YES];
    [self.pageControl setDefersCurrentPageDisplay:YES];
    [self.pageControl addTarget:self action:@selector(changeTab:withEvent:) forControlEvents:UIControlEventTouchDown];
    [self.pageControl setTintColor:[UIColor darkGrayColor]];
    [self.pageControl setPageIndicatorTintColor:[UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0]];
    [self.pageControl setCurrentPageIndicatorTintColor:[UIColor grayColor]];
    [self.view addSubview:self.pageControl];
    
    // Create scrollview
    self.scrollView = [[MTScrollView alloc] initWithFrame:self.view.bounds];
    [self.scrollView setParentController:self];
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    [self.scrollView setShowsVerticalScrollIndicator:NO];
    [self.scrollView setDelegate:self];
    [self.scrollView setScrollsToTop:NO];
    [self.scrollView setAutoresizesSubviews:YES];
    [self.scrollView setPagingEnabled:NO];
    [self.scrollView setDecelerationRate:UIScrollViewDecelerationRateFast];
    [self.view insertSubview:self.scrollView belowSubview:self.pageControl];
    
    // Create navigation bar
    self.navBar = [[MTNavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44 + [[UIApplication sharedApplication] statusBarFrame].size.height)];
    [self.navBar setHidden:YES];
    [self.view addSubview:self.navBar];
    
    // Create selectedToolbar, visible when one tab is selected
    self.selectedToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];

    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIImage *tabImage = [[UIImage imageNamed:@"Tabs"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIButton *button =  [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:tabImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(showTabs) forControlEvents:UIControlEventTouchUpInside];
    [button setFrame:CGRectMake(0, 0, 40, 40)];
    
    // The label is centered in the image's front square, which itself isn't centered in the view, so coordinates are a bit strange
    self.numberOfTabsLabel = [[UILabel alloc] initWithFrame:CGRectMake(11, 3.5, 14, 36)];
    [self.numberOfTabsLabel setFont:[UIFont systemFontOfSize:15 weight:UIFontWeightLight]];
    [self.numberOfTabsLabel setAdjustsFontSizeToFitWidth:YES];
    [self.numberOfTabsLabel setNumberOfLines:1];
    [self.numberOfTabsLabel setMinimumScaleFactor:0.5];
    [self.numberOfTabsLabel setText:@"1"];
    [self.numberOfTabsLabel setTextAlignment:NSTextAlignmentCenter];
    [self.numberOfTabsLabel setTextColor:self.view.tintColor];
    [self.numberOfTabsLabel setBackgroundColor:[UIColor clearColor]];
    [button addSubview:self.numberOfTabsLabel];
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:button];

    [self.selectedToolbar setItems:@[flexibleSpace, barButton]];
    [self.view addSubview:self.selectedToolbar];
    
    // Create deselectedToolbar, visible when the tabs are shown
    self.deselectedToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width, 44)];
    
    addTabButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addTab)];

    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", nil) style:UIBarButtonItemStyleDone target:self action:@selector(hideTabs)];

    [self.deselectedToolbar setItems:@[addTabButton, space, doneButton]];
    [self.view addSubview:self.deselectedToolbar];

    // Create title label
    float sizeFactor = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? kPortraitSizeFactor: kLandscapeSizeFactor;
    float offset = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? kPortraitTabDisplayOffset: kLandscapeTabDisplayOffset;
    float titleHeight = 20;
    // TODO: -5 is hacky, find why it's not centered without it
    float topSpace = self.tabSize.height * (1 - sizeFactor) / 2 + offset - [UIApplication sharedApplication].statusBarFrame.size.height - 5;
    float yPosition = [UIApplication sharedApplication].statusBarFrame.size.height + topSpace / 2 - titleHeight / 2 - 5;
    
    self.tabTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, yPosition, self.view.frame.size.width, titleHeight)];
    [self.tabTitleLabel setFont:[UIFont systemFontOfSize:17.0]];
    [self.tabTitleLabel setTextColor:[UIColor blackColor]];
    [self.tabTitleLabel setBackgroundColor:[UIColor clearColor]];
    [self.tabTitleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.tabTitleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [self.view insertSubview:self.tabTitleLabel aboveSubview:self.scrollView];

    [self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
    [self setTabSize:_tabSize];
    [self hideTabsAnimated:NO];
}

- (void)updateStatusBarDisplay {
    [self updateStatusBarDisplayForOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

- (void)updateStatusBarDisplayForOrientation:(UIInterfaceOrientation)orientation {
    BOOL shouldHideStatusBar = UIInterfaceOrientationIsLandscape(orientation) && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
    
    [[UIApplication sharedApplication] setStatusBarHidden:self.hideStatusBar || shouldHideStatusBar];
}

- (BOOL)prefersStatusBarHidden {
    // Always hide the status bar in landscape if the device is a phone
    BOOL shouldHideStatusBar = UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
    
    return self.hideStatusBar || shouldHideStatusBar;
}

- (void)setEnableRapideScroll:(BOOL)enableRapideScroll {
    _enableRapideScroll = enableRapideScroll;
    
    if (enableRapideScroll) {
        [self.scrollView setPagingEnabled:NO];
    } else {
        [self.scrollView setPagingEnabled:YES];
    }
}

- (void)setEnableTabReordering:(BOOL)enableTabReordering {
    _enableTabReordering = enableTabReordering;
    
    if (enableTabReordering) {
        [self.scrollView.moveGestureRecognizer setEnabled:self.tabsAreVisible];
    } else {
        [self.scrollView.moveGestureRecognizer setEnabled:NO];
    }
}


#pragma mark - Frames and sizes

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [self.scrollView cancelTabActions];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        // Display / hide status bar
        [self updateStatusBarDisplay];
        
        // Reposition page control
        [self.pageControl setFrame:CGRectMake(0, size.height - 18 - 44, size.width, 10)];
        [self updatePageControlFrameForSize:size];
        
        // Reposition navigation bar
        [self.navBar setFrame:CGRectMake(0, 0, size.width, 44 + [[UIApplication sharedApplication] statusBarFrame].size.height)];

        // Reposition toolbars
        [self.selectedToolbar setFrame:CGRectMake(0, size.height - 44, size.width, 44)];
        [self.deselectedToolbar setFrame:CGRectMake(0, size.height - 44, size.width, 44)];

        // Update sizes
        [self setTabSize:size];
    } completion:nil];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)setTabSize:(CGSize)tabSize {
    _tabSize = tabSize;
    
    // Update content size
    int numberOfViews = [self tabsCount];
    CGSize contentSize = CGSizeMake(numberOfViews * tabSize.width, tabSize.height);
    CGPoint contentOffset = CGPointMake(self.currentIndex * tabSize.width, 0);
    
    [self.scrollView setContentSize:contentSize];
    [self.scrollView setContentOffset:contentOffset animated:NO];
    [self.scrollView setFrame:CGRectMake(0, 0, tabSize.width, tabSize.height)];
    
    // Reposition title label
    float sizeFactor = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? kPortraitSizeFactor: kLandscapeSizeFactor;
    float offset = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? kPortraitTabDisplayOffset: kLandscapeTabDisplayOffset;
    float titleHeight = self.tabTitleLabel.frame.size.height;
    float topSpace = self.tabSize.height * (1 - sizeFactor) / 2 + offset - [UIApplication sharedApplication].statusBarFrame.size.height - 5; // Fix this, there shouldn't be a -5
    float yPosition = [UIApplication sharedApplication].statusBarFrame.size.height + topSpace / 2 - titleHeight / 2;
    [self.tabTitleLabel setFrame:CGRectMake(0, yPosition, tabSize.width, titleHeight)];
    
    [self resizeTabsAnimated:NO];
}

- (void)resizeTabsAnimated:(BOOL)animated {
    if (self.tabsAreVisible) {
        for (int i = 0; i < [self tabsCount]; i++) {
            MTPageViewContainer *container = [self.tabContainers objectAtIndex:i];
            float sizeFactor = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? kPortraitSizeFactor: kLandscapeSizeFactor;
            float offset = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? kPortraitTabDisplayOffset: kLandscapeTabDisplayOffset;
            
            float xMargin = self.tabSize.width * (1 - sizeFactor);
            float yMargin = self.tabSize.height * (1 - sizeFactor);
            
            CGAffineTransform translation = CGAffineTransformMakeTranslation(0, offset - kShadowSize);
            CGAffineTransform transform = CGAffineTransformScale(translation, sizeFactor, sizeFactor);
            [container setTransform:transform];

            [container.tab setFrame:CGRectMake(0, 0, self.tabSize.width, self.tabSize.height)];
            [container setFrame:CGRectMake(i * self.tabSize.width + xMargin / 2, yMargin / 2 - kShadowSize + offset, container.tab.frame.size.width, container.tab.frame.size.height)];
        }
    } else {
        for (int i = 0; i < [self tabsCount]; i++) {
            MTPageViewContainer *container = [self.tabContainers objectAtIndex:i];
            [container.tab setFrame:CGRectMake(0, 0, self.tabSize.width, self.tabSize.height)];
            [container setFrame:CGRectMake(i * self.tabSize.width, 0, container.tab.frame.size.width, container.tab.frame.size.height)];
        }
    }
}


#pragma mark - Showing and hiding tabs

- (void)scaleDownTabsAndContainersAnimated:(BOOL)animated {
    for (int i = 0; i < [self tabsCount]; i++) {
        MTPageViewContainer *container = [self.tabContainers objectAtIndex:i];
        [container showHeader];
        
        float sizeFactor = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? kPortraitSizeFactor: kLandscapeSizeFactor;
        float offset = UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? kPortraitTabDisplayOffset: kLandscapeTabDisplayOffset;

        float xMargin = self.tabSize.width * (1 - sizeFactor);
        float yMargin = self.tabSize.height * (1 - sizeFactor);
        
        // Smoothly animate zooming out and then update the frames
        [UIView animateWithDuration:kTabsShowAnimationDuration * animated animations:^{
            CGAffineTransform translation = CGAffineTransformMakeTranslation(0, offset - kShadowSize);
            CGAffineTransform transform = CGAffineTransformScale(translation, sizeFactor, sizeFactor);
            [container setTransform:transform];
        } completion:^(BOOL finished) {
            [container.tab setFrame:CGRectMake(0, 0, self.tabSize.width, self.tabSize.height)];
            [container setFrame:CGRectMake(i * self.tabSize.width + xMargin / 2, yMargin / 2 - kShadowSize + offset, container.tab.frame.size.width, container.tab.frame.size.height)];
        }];
    }
}

- (void)scaleUpTabsAndContainersAnimated:(BOOL)animated {
    for (int i = 0; i < [self tabsCount]; i++) {
        MTPageViewContainer *container = [self.tabContainers objectAtIndex:i];
        [container hideHeader];
        
        // Smoothly animate zooming in and then update the frames
        [UIView animateWithDuration:kTabsShowAnimationDuration * animated animations:^{
            [container setTransform:CGAffineTransformIdentity];
            [container setFrame:CGRectMake(i * self.tabSize.width, 0, container.tab.frame.size.width, container.tab.frame.size.height)]; // Required to have the right origin during the animation
        } completion:^(BOOL finished) {
            [container.tab setFrame:CGRectMake(0, 0, self.tabSize.width, self.tabSize.height)];
            [container setFrame:CGRectMake(i * self.tabSize.width, 0, container.tab.frame.size.width, container.tab.frame.size.height)];
        }];
    }
}

- (void)showTabs {
    [self showTabsAnimated:YES];
}

- (void)showTabsAnimated:(BOOL)animated {
    [self.tabTitleLabel setText:[self.currentTab title]];

    if (self.tabsAreVisible) {
        return;
    }

    [self tabsWillBecomeVisible];
    [self.currentTab.scrollBarManager tabsWillBecomeVisible];

    _tabsAreVisible = YES;
    [self.selectedToolbar setUserInteractionEnabled:NO];
    [self.scrollView.switchTabPanGestureRecognizer setEnabled:NO];
    
    [UIView animateWithDuration:animated * kTabsShowAnimationDuration animations:^{
        [self scaleDownTabsAndContainersAnimated:animated];
        [self.pageControl setAlpha:1.0];
        [self.tabTitleLabel setAlpha:1.0];
        [self.selectedToolbar setAlpha:0.0];
        [self.deselectedToolbar setAlpha:1.0];
        [self.navigationController.navigationBar setAlpha:0.0];
        [self.navBar setAlpha:0.0];
    } completion:^(BOOL finished) {
        [self.deselectedToolbar setUserInteractionEnabled:YES];
        [self.navigationController.navigationBar setHidden:YES];
        [self.navBar setHidden:YES];
        
        [self.scrollView setScrollEnabled:YES];
        [self.scrollView.panGestureRecognizer setEnabled:YES];
        [self.scrollView.moveGestureRecognizer setEnabled:self.enableTabReordering];
        [self.scrollView.closePanGestureRecognizer setEnabled:YES];
        [self.scrollView.tapGestureRecognizer setEnabled:YES];
        
        [self tabsDidBecomeVisible];
    }];
}

- (void)hideTabs {
    [self hideTabsAnimated:YES];
}

- (void)hideTabsAnimated:(BOOL)animated {
    if (!self.tabsAreVisible) {
        return;
    }
    
    [self tabsWillBecomeHidden];
    [self.currentTab.scrollBarManager tabsWillBecomeHidden];
    
    // Stop scrolling
    [self.scrollView setScrollEnabled:NO];
    CGPoint offset = self.scrollView.contentOffset;
    [self.scrollView setContentOffset:offset animated:NO];
    [self.scrollView setScrollEnabled:YES];

    _tabsAreVisible = NO;
    [self.scrollView setUserInteractionEnabled:NO];
    [self.scrollView setScrollEnabled:NO];
    [self.scrollView.closePanGestureRecognizer setEnabled:NO];
    [self.scrollView.moveGestureRecognizer setEnabled:NO];
    [self.scrollView.tapGestureRecognizer setEnabled:NO];
    [self.deselectedToolbar setUserInteractionEnabled:NO];
    [self.navigationController.navigationBar setAlpha:0.0]; // The hidden navigation bar's alpha is reset when changing orientation 
    [self.navigationController.navigationBar setHidden:NO];
    [self.navBar setAlpha:0.0];
    [self.navBar setHidden:NO];
    [self scrollToIndex:self.currentIndex animated:YES];
    
    [UIView animateWithDuration:animated * kTabsShowAnimationDuration animations:^{
        [self scaleUpTabsAndContainersAnimated:animated];
        [self scrollToIndex:self.currentIndex animated:NO];
        [self.pageControl setAlpha:0.0];
        [self.tabTitleLabel setAlpha:0.0];
        [self.selectedToolbar setAlpha:1.0];
        [self.deselectedToolbar setAlpha:0.0];
        [self.navigationController.navigationBar setAlpha:1.0];
        [self.navBar setAlpha:1.0];
    } completion:^(BOOL finished) {
        [self.selectedToolbar setUserInteractionEnabled:YES];
        [self.scrollView.switchTabPanGestureRecognizer setEnabled:YES];
        
        [self.scrollView setUserInteractionEnabled:YES];
        [self tabsDidBecomeHidden];
    }];
}


#pragma mark - Tabs info

- (MTPageViewTab *)currentTab {
    if (self.tabContainers.count == 0) {
        return nil;
    }
    
    return [(MTPageViewContainer *)[self.tabContainers objectAtIndex:self.currentIndex] tab];
}

- (MTPageViewTab *)tabAtIndex:(int)index {
    return [[self containerAtIndex:index] tab];
}

- (MTPageViewContainer *)currentContainer {
    if (self.tabContainers.count == 0) {
        return nil;
    }
    
    return (MTPageViewContainer *)[self.tabContainers objectAtIndex:self.currentIndex];
}

- (MTPageViewContainer *)containerAtIndex:(int)index {
    return [self.tabContainers objectAtIndex:index];
}

- (int)tabsCount {
    return (int)[self.tabContainers count];
}

- (void)updateDisplayedTitle {
    [self.tabTitleLabel setText:[self.currentTab title]];
}

- (void)updateSelectedTabIndex {
    [self updateSelectedTabIndexRoundIndex:NO];
}

- (void)updateSelectedTabIndexRoundIndex:(BOOL)round {
    int nearestIndex = [self privateTabIndexAtPoint:self.scrollView.contentOffset wiggle:0.0 roundIndex:round];
    
    [self.pageControl setCurrentPage:nearestIndex];
    _currentIndex = (int)nearestIndex;
    [self.tabTitleLabel setText:[self.currentTab title]];
}

- (void)updatePageControlFrame {
    [self updatePageControlFrameForSize:self.view.frame.size];
}

- (void)updatePageControlFrameForSize:(CGSize)size {
    // Find the true width of the page control
    // There is half a spacing on each side of the first and last page control dots
    float pageControlWidth = [self tabsCount] * (2 * kPageControlDotRadius + kPageControlDotSpacing);
    
    if (pageControlWidth > size.width) {
        // Page control is too large, "scroll" to show the current page dot
        float partialIndex = self.scrollView.contentOffset.x / self.tabSize.width;
        float xOrigin =  size.width / 2 - kPageControlDotSpacing * (partialIndex + 1 / 2) - kPageControlDotRadius * (2 * partialIndex + 1);
        
        if (xOrigin > kPageControlDotRadius + kPageControlDotSpacing / 2) {
            // Don't make the page control go too far right
            xOrigin = kPageControlDotRadius + kPageControlDotSpacing / 2;
        } else if (xOrigin + pageControlWidth + kPageControlDotSpacing < size.width) {
            // Don't make the page control go too far left
            // No need to use kPageControlDotRadius and kPageControlDotSpacing as they are included in pageControlWidth
            // TODO: Adding kPageControlDotSpacing is kinda hacky, find out why it's needed
            xOrigin = size.width - pageControlWidth - kPageControlDotSpacing;
        }
        
        // Have to change pageControl's width otherwise, strangly enough, the xOrigin isn't used correctly
        [self.pageControl setFrame:CGRectMake(xOrigin, self.pageControl.frame.origin.y, pageControlWidth, self.pageControl.frame.size.height)];
    } else {
        [self.pageControl setFrame:CGRectMake(0, self.pageControl.frame.origin.y, size.width, self.pageControl.frame.size.height)];
    }
}


#pragma mark - Overridable methods

- (MTPageViewTab *)newTabAtIndex:(int)index withTitle:(NSString *)title {
    // Create tab
    MTPageViewTab *newTab = [[MTPageViewTab alloc] initWithFrame:CGRectMake(0, 0, self.tabSize.width, self.tabSize.height)];
    [newTab setFrame:self.view.bounds];
    [newTab setIndex:index];
    [newTab setBackgroundColor:[UIColor whiteColor]];
    [newTab setTitle:title];
    
    return newTab;
}

- (MTPageViewContainer *)newContainerForTab:(MTPageViewTab *)tab {
    // Create container view for the given tab
    MTPageViewContainer *newContainer = [[MTPageViewContainer alloc] initWithFrame:CGRectMake(self.tabSize.width * [self tabsCount], 0, tab.frame.size.width, tab.frame.size.height)];
    [newContainer setTab:tab];
    [newContainer setParentController:self];
    
    return newContainer;
}

- (BOOL)canStartMovingTabAtIndex:(int)index {
    return YES;
}

- (BOOL)canMoveTabAtIndex:(int)index toIndex:(int)toIndex {
    return YES;
}

- (BOOL)canAddTab {
    return YES;
}

- (BOOL)canCloseTabAtIndex:(int)index {
    return YES;
}


#pragma mark - Events

- (void)willAddNewTabAtIndex:(int)index {}
- (void)didAddNewTabAtIndex:(int)index {}
- (void)willMoveTabAtIndex:(int)fromIndex toIndex:(int)toIndex {}
- (void)didMoveTabAtIndex:(int)fromIndex toIndex:(int)toIndex {}
- (void)willCloseTabAtIndex:(int)index {}
- (void)didCloseTabAtIndex:(int)index {}
- (void)tabsWillBecomeVisible {}
- (void)tabsDidBecomeVisible {}
- (void)tabsWillBecomeHidden {}
- (void)tabsDidBecomeHidden {}
- (void)didBeginMovingTabAtIndex:(int)index {}
- (void)didCancelMovingTabAtIndex:(int)index {}
- (void)didFinishMovingTabAtIndex:(int)fromIndex toIndex:(int)toIndex {}
- (void)didBeginClosingTabAtIndex:(int)index {}
- (void)didCancelClosingTabAtIndex:(int)index {}
- (void)didFinishClosingTabAtIndex:(int)index {}
- (void)didBeginSwitchingTabAtIndex:(int)index {}
- (void)didCancelSwitchingTabAtIndex:(int)index {}
- (void)didFinishSwitchingTabAtIndex:(int)fromIndex toIndex:(int)toIndex {}


#pragma mark - Page control

- (MTPageViewTab *)addTab {
    return [self addTabAnimated:YES];
}

- (MTPageViewTab *)addTabAnimated:(BOOL)animated {
    return [self addTabWithTitle:nil animated:animated];
}

- (MTPageViewTab *)addTabWithTitle:(NSString *)title {
    return [self addTabWithTitle:title animated:YES];
}

- (MTPageViewTab *)addTabWithTitle:(NSString *)title animated:(BOOL)animated {
    if (![self canAddTab]) {
        return nil;
    }
    
    [self willAddNewTabAtIndex:[self tabsCount]];
    
    // Create the tab and a matching container
    MTPageViewTab *newTab = [self newTabAtIndex:[self tabsCount] withTitle:title];
    MTPageViewContainer *newContainer = [self newContainerForTab:newTab];

    // Add tab
    [self.tabContainers addObject:newContainer];
    [self.pageControl setNumberOfPages:[self tabsCount]];
    [self.numberOfTabsLabel setText:[NSString stringWithFormat:@"%d", [self tabsCount]]];
    [self.scrollView addSubview:newContainer];
    
    // Update content size
    CGSize contentSize = self.scrollView.contentSize;
    contentSize.width += self.tabSize.width;
    [self.scrollView setContentSize:contentSize];
    
    if (animated) {
        // Prevent the user from interaction with elements while the tab is being added
        [self.scrollView setUserInteractionEnabled:NO];
        [self.deselectedToolbar setUserInteractionEnabled:NO];
        
        if (self.tabsAreVisible) {
            // Scale down the new tab
            [self scaleDownTabsAndContainersAnimated:NO];
        } else {
            // Show tabs to animate the addition
            [self showTabsAnimated:YES];
        }
        
        // Scroll to the new tab
        [self scrollToIndex:newTab.index completion:^(BOOL finished) {
            [self hideTabsAnimated:YES];
            [self didAddNewTabAtIndex:newTab.index];
            [self.scrollView setUserInteractionEnabled:YES];
            [self.deselectedToolbar setUserInteractionEnabled:YES];
        }];
    } else {
        [self didAddNewTabAtIndex:newTab.index];
    }
    
    [addTabButton setEnabled:[self canAddTab]];
    
    return newTab;
}

- (MTPageViewTab *)privateInsertTabWithoutScrollingAtIndex:(int)index withTitle:(NSString *)title {
    [self willAddNewTabAtIndex:index];
    
    // Create the tab and a matching container
    MTPageViewTab *newTab = [self newTabAtIndex:[self tabsCount] withTitle:title];
    MTPageViewContainer *newContainer = [self newContainerForTab:newTab];
    
    // Add tab
    [self.tabContainers insertObject:newContainer atIndex:index];
    [self.scrollView addSubview:newContainer];
    
    if (self.tabsAreVisible) {
        [self scaleDownTabsAndContainersAnimated:NO];
    } else {
        [self scaleUpTabsAndContainersAnimated:NO];
    }
    
    // Update indexes
    for (int i = 0; i < [self tabsCount]; i++) {
        MTPageViewContainer *container = [self.tabContainers objectAtIndex:i];
        [container.tab setIndex:i];
    }
    
    // Update content size
    CGSize contentSize = self.scrollView.contentSize;
    contentSize.width += self.tabSize.width;
    [self.scrollView setContentSize:contentSize];
    [self updatePageControlFrame];
    
    return newTab;
}

- (MTPageViewTab *)insertTabAtIndex:(int)index {
    return [self insertTabAtIndex:index animated:YES];
}

- (MTPageViewTab *)insertTabAtIndex:(int)index animated:(BOOL)animated {
    return [self insertTabAtIndex:index withTitle:nil animated:animated];
}

- (MTPageViewTab *)insertTabAtIndex:(int)index withTitle:(NSString *)title {
    return [self insertTabAtIndex:index withTitle:title animated:YES];
}

- (MTPageViewTab *)insertTabAtIndex:(int)index withTitle:(NSString *)title animated:(BOOL)animated {
    // Create tab
    MTPageViewTab *newTab = [self privateInsertTabWithoutScrollingAtIndex:index withTitle:title];
    
    // Update number of tabs
    [self.pageControl setNumberOfPages:[self tabsCount]];
    [self.numberOfTabsLabel setText:[NSString stringWithFormat:@"%d", [self tabsCount]]];
    
    if (animated) {
        // Prevent the user from interaction with elements while the tab is being added
        [self.scrollView setUserInteractionEnabled:NO];
        [self.deselectedToolbar setUserInteractionEnabled:NO];

        if (self.tabsAreVisible) {
            // Scale down the new tab
            [self scaleDownTabsAndContainersAnimated:NO];
            [self.tabTitleLabel setText:[newTab title]];
        } else {
            // Show tabs to animate the addition
            [self showTabsAnimated:YES];
        }
        
        // Scroll to the new tab
        [self scrollToIndex:newTab.index completion:^(BOOL finished) {
            [self hideTabsAnimated:YES];
            [self didAddNewTabAtIndex:newTab.index];
            [self.scrollView setUserInteractionEnabled:YES];
            [self.deselectedToolbar setUserInteractionEnabled:YES];
        }];
    } else {
        [self didAddNewTabAtIndex:newTab.index];
    }
    
    return newTab;
}

- (void)moveTabAtIndex:(int)fromIndex toIndex:(int)toIndex {
    [self moveTabAtIndex:fromIndex toIndex:toIndex animated:YES];
}

- (void)moveTabAtIndex:(int)fromIndex toIndex:(int)toIndex animated:(BOOL)animated {
    if (![self canMoveTabAtIndex:fromIndex toIndex:toIndex]) {
        [self scrollToIndex:fromIndex];
        return;
    }
    
    [self willMoveTabAtIndex:fromIndex toIndex:toIndex];
    
    MTPageViewContainer *tmp = [self.tabContainers objectAtIndex:fromIndex];
    [self.tabContainers removeObjectAtIndex:fromIndex];
    
    int newIndex = toIndex;
    if (fromIndex < toIndex) {
        // Removed an object before toIndex, so actually insert at toIndex - 1
        newIndex -= 1;
    }
    
    [self.tabContainers insertObject:tmp atIndex:newIndex];
    
    // Update indexes
    for (int i = 0; i < [self tabsCount]; i++) {
        MTPageViewContainer *container = [self.tabContainers objectAtIndex:i];
        [container.tab setIndex:i];
    }
    
    if (animated) {
        if (!self.tabsAreVisible) {
            [self showTabsAnimated:YES];
        }
        
        [UIView animateWithDuration:kTabsShowAnimationDuration animations:^{
            // Update positions
            [self setTabSize:self.tabSize];
            
            // Scroll to the moved tab
            [self scrollToIndex:newIndex animated:NO];
            
            // Update the title
            [self updateDisplayedTitle];
        } completion:^(BOOL finished) {
            [self didMoveTabAtIndex:fromIndex toIndex:toIndex];
        }];
    } else {
        [self didMoveTabAtIndex:fromIndex toIndex:toIndex];
    }
}

- (void)closeCurrentTab {
    [self closeTabAtIndex:self.currentIndex];
}

- (void)closeAllTabs {
    [self closeTabsCount:self.tabsCount];
}

- (void)closeTabsCount:(int)tabsCount {
    if (tabsCount > 0) {
        [self closeTabAtIndex:0 animated:NO completion:^(BOOL finished) {
            [self closeTabsCount:tabsCount - 1];
        }];
    } else {
        [self scrollToIndex:0 completion:^(BOOL finished) {
            [self hideTabs];
        }];
    }
}

- (void)closeTabAtIndex:(int)index {
    [self closeTabAtIndex:index animated:YES];
}

- (void)closeTabAtIndex:(int)index animated:(BOOL)animated {
    [self closeTabAtIndex:index animated:animated completion:nil];
}

- (void)closeTabAtIndex:(int)index animated:(BOOL)animated completion:(void (^) (BOOL finished))completion {
    if (![self canCloseTabAtIndex:index]) {
        return;
    }
    
    [self showTabsAnimated:animated];
    [self willCloseTabAtIndex:index];
    
    __block MTPageViewContainer *closedContainer = [self.tabContainers objectAtIndex:index];
    
    // Scroll to the previous tab if this is the tab at the end of the list
    BOOL scrollToLeft = index == [self tabsCount] - 1;
    
    // Find out if we have to insert a new tab
    BOOL isLastTab = [self tabsCount] == 1;
    
    // Insert a new tab if the current one is the last one
    if (isLastTab) {
        [self privateInsertTabWithoutScrollingAtIndex:0 withTitle:nil];
        [self didAddNewTabAtIndex:0];
    }
    
    [UIView animateWithDuration:animated * kTabsCloseAnimationDuration animations:^{
        // Hide tab
        [closedContainer setAlpha:0.0];
        
        if (scrollToLeft) {
            // Scroll to new index
            [self scrollToIndex:index - 1 animated:NO];
        } else {
            // Scroll the other tabs to the left
            for (int i = index + 1; i < [self tabsCount]; i++) {
                MTPageViewContainer *container = [self.tabContainers objectAtIndex:i];
                [container setFrame:CGRectMake(container.frame.origin.x - self.tabSize.width, container.frame.origin.y, container.frame.size.width, container.frame.size.height)];
            }
        }
    } completion:^(BOOL finished) {
        // Remove closed tab from superview
        [closedContainer.tab removeFromSuperview];
        [closedContainer setTab:nil];
        [closedContainer removeFromSuperview];
        closedContainer = nil;
        
        // Update tab list and number of tabs
        [self.tabContainers removeObjectAtIndex:index + isLastTab];
        [self.pageControl setNumberOfPages:[self tabsCount]];
        [self.numberOfTabsLabel setText:[NSString stringWithFormat:@"%d", [self tabsCount]]];
        
        // Update content size
        CGSize contentSize = self.scrollView.contentSize;
        contentSize.width += self.tabSize.width;
        [self.scrollView setContentSize:contentSize];
        [self updatePageControlFrame];
        
        // Update indexes
        for (int i = 0; i < [self tabsCount]; i++) {
            MTPageViewContainer *container = [self.tabContainers objectAtIndex:i];
            [container.tab setIndex:i];
        }
        
        // Update remaining tabs' frames
        if (self.tabsAreVisible) {
            [self scaleDownTabsAndContainersAnimated:YES];
        } else {
            [self scaleUpTabsAndContainersAnimated:YES];
        }
        
        [self updateSelectedTabIndex];
        [self updateDisplayedTitle];
        [self updatePageControlFrame];
        [self didCloseTabAtIndex:index];
        [addTabButton setEnabled:[self canAddTab]];
        
        if (completion) {
            completion(finished);
        }
    }];
}

- (void)changeTab:(UIPageControl *)pageControl withEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:pageControl];
    
    // Find the true width of the page control
    // There is half a spacing on each side of the first and last page control dots
    float pageControlWidth = [self tabsCount] * (2 * kPageControlDotRadius + kPageControlDotSpacing);
    int index = 0;
    
    if (pageControlWidth < self.pageControl.frame.size.width) {
        // Page control doesn't take the whole view width
        float margin = (self.pageControl.frame.size.width - pageControlWidth) / 2;
        
        if (location.x < margin) {
            // Touched left of the first dot, scroll to currentIndex - 1
            index = [self currentIndex] - 1;
        } else if (location.x > margin + pageControlWidth) {
            // Touched right of the last dot, scroll to currentIndex + 1
            index = [self currentIndex] + 1;
        } else {
            // Touched an actual dot
            float xLocation = location.x - margin; // Location in visible part of the page control
            index = roundf(xLocation / (2 * kPageControlDotRadius + kPageControlDotSpacing)) - 1;
            
            if (index < self.currentIndex) {
                index = self.currentIndex - 1;
            } else if (index > self.currentIndex) {
                index = self.currentIndex + 1;
            }
        }
        
        
    } else {
        // Page control takes up the whole space, so the user touched an actual dot
        index = roundf((location.x) / (2 * kPageControlDotRadius + kPageControlDotSpacing)) - 1;
        
        if (index < self.currentIndex) {
            index = self.currentIndex - 1;
        } else if (index > self.currentIndex) {
            index = self.currentIndex + 1;
        }
    }
    
    index = MAX(0, MIN([self tabsCount] - 1, index));
    [self scrollToIndex:index];
}

- (int)tabIndexAtPoint:(CGPoint)point {
    return [self privateTabIndexAtPoint:point wiggle:0.0];
}

- (int)privateTabIndexAtPoint:(CGPoint)point wiggle:(float)wiggle {
    return [self privateTabIndexAtPoint:point wiggle:wiggle roundIndex:NO];
}

- (int)privateTabIndexAtPoint:(CGPoint)point wiggle:(float)wiggle roundIndex:(BOOL)round {
    // Find index at which the page should stop (add wiggle to the point)
    NSInteger nearestIndex;
    
    if (round) {
        nearestIndex = roundf((point.x + wiggle) / self.tabSize.width);
    } else {
        nearestIndex = (NSInteger)((point.x + wiggle) / self.tabSize.width);
    }
    
    // Prevent the index from being too big
    nearestIndex = MAX(0, MIN(nearestIndex, [self tabsCount] - 1));
    
    return (int)nearestIndex;
}


#pragma mark - Scroll control

- (void)scrollToIndex:(int)index {
    [self scrollToIndex:index animated:YES];
}

- (void)scrollToIndex:(int)index animated:(BOOL)animated {
    [self scrollToIndex:index animated:animated completion:nil];
}

- (void)scrollToIndex:(int)index completion:(void (^)(BOOL finished))completion {
    [self scrollToIndex:index animated:YES completion:completion];
}

- (void)scrollToIndex:(int)index animated:(BOOL)animated completion:(void (^)(BOOL finished))completion {
    // Compute the duration based on the number of tabs to scroll
    float duration = MIN(kDefaultTabScrollAnimationDuration + kAdditionalTabScrollAnimationDuration * abs(self.currentIndex - index), kMaxTabScrollAnimationDuration);

    // Force scrollView to stop scrolling
    BOOL scrollEnabled = self.scrollView.scrollEnabled;
    [self.scrollView setScrollEnabled:NO];
    [self.scrollView setScrollEnabled:scrollEnabled];
    _currentIndex = index;
    
    [UIView animateWithDuration:animated * duration delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.scrollView setContentOffset:CGPointMake(index * self.tabSize.width, 0)];
    } completion:^(BOOL finished) {
        [self updateSelectedTabIndex];
        [self updatePageControlFrame];
        
        if (completion)
            completion(finished);
    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.scrollEnabled) {
        [self updateSelectedTabIndexRoundIndex:YES];        
        [self updatePageControlFrame];
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (!self.enableRapideScroll || !scrollView.scrollEnabled)
        return;
    
    // Add a bit of "wiggle" to make changing tabs easier, or use roundf() when the user is scrolling slowly to select the closest
    float wiggle = 0;
    BOOL roundIndex = NO;
    
    if (velocity.x > 10) {
        wiggle = 50;
    } else if (velocity.x < -10) {
        wiggle = -50;
    } else {
        roundIndex = YES;
    }
    
    int nearestIndex = [self privateTabIndexAtPoint:*targetContentOffset wiggle:wiggle roundIndex:roundIndex];
    
    // Find the position of that index
    float xOffset = nearestIndex * self.tabSize.width;
    
    // Change the target content offset
    *targetContentOffset = CGPointMake(xOffset, targetContentOffset->y);
    [scrollView setContentOffset:*targetContentOffset animated:YES];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate && scrollView.scrollEnabled) {
        [self updateSelectedTabIndex];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (!scrollView.scrollEnabled) {
        return;
    }
    
    [self updateSelectedTabIndex];
    
    int nearestIndex = [self tabIndexAtPoint:self.scrollView.contentOffset];

    if (nearestIndex != self.currentIndex) {
        [self scrollToIndex:(int)nearestIndex];
    }
}

@end
