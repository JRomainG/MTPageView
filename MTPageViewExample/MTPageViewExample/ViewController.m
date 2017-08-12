//
//  ViewController.m
//  MTPageView
//
//  Created by Jean-Romain on 12/07/2017.
//  Copyright © 2017 JustKodding. All rights reserved.
//

#import "ViewController.h"
#import "MTNavigationBar.h"
#import "WebTextField.h"

@interface ViewController ()

@end

@implementation ViewController {
    CustomWebView *exampleWebView;
    MTPageViewTab *exampleWebViewTab;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [(MTNavigationBar *)self.navigationController.navigationBar setTextField:[[WebTextField alloc] init]];
    
    [[self addTabAnimated:NO] setBackgroundColor:[UIColor redColor]];
    [[self addTabAnimated:NO] setBackgroundColor:[UIColor orangeColor]];
    [[self addTabAnimated:NO] setBackgroundColor:[UIColor yellowColor]];
    [[self addTabAnimated:NO] setBackgroundColor:[UIColor greenColor]];
    [[self addTabAnimated:NO] setBackgroundColor:[UIColor cyanColor]];
    [[self addTabAnimated:NO] setBackgroundColor:[UIColor blueColor]];
    [[self addTabAnimated:NO] setBackgroundColor:[UIColor magentaColor]];
    [[self addTabAnimated:NO] setBackgroundColor:[UIColor purpleColor]];
    [[self addTabAnimated:NO] setBackgroundColor:[UIColor brownColor]];
}

- (void)viewWillAppear:(BOOL)animated {
    // Create a webView
    exampleWebView = [[CustomWebView alloc] initWithFrame:self.view.bounds];
    // [exampleWebView.scrollView.pinchGestureRecognizer requireGestureRecognizerToFail:self.scrollView.switchTabPanGestureRecognizer];
    // [exampleWebView.scrollView.panGestureRecognizer requireGestureRecognizerToFail:self.scrollView.switchTabPanGestureRecognizer];
    
    // Create a new tab
    exampleWebViewTab = [self insertTabAtIndex:0 animated:NO];
    
    // Add the webView into it
    [exampleWebViewTab addSubview:exampleWebView];

    // Make its tabBar and navbar hide when scrolling
    MTScrollBarManager *scrollBarManager = [[MTScrollBarManager alloc] initWithNavBar:(MTNavigationBar *)self.navigationController.navigationBar andToolBar:self.selectedToolbar andScrollView:exampleWebView.scrollView];
    [exampleWebViewTab setScrollBarManager:scrollBarManager];
    
    // Scroll to this tab
    [self scrollToIndex:0 animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Overridable methods

- (MTPageViewTab *)newTabAtIndex:(int)index withTitle:(NSString *)title {
    // Override this to use a custom tab
    MTPageViewTab *newTab = [super newTabAtIndex:index withTitle:title];
    UILabel *numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, newTab.frame.size.width, 100)];
    [numberLabel setText:[NSString stringWithFormat:@"%d", index + 1]];
    [numberLabel setFont:[UIFont systemFontOfSize:100]];
    [numberLabel setTextAlignment:NSTextAlignmentCenter];
    [numberLabel setCenter:newTab.center];
    [numberLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin];
    [newTab addSubview:numberLabel];

    return newTab;
}

- (MTPageViewContainer *)newContainerForTab:(MTPageViewTab *)tab {
    // Override this to use a custom container
    return [super newContainerForTab:tab];
}

- (BOOL)canCloseTabAtIndex:(int)index {
    return [self tabAtIndex:index] != exampleWebViewTab;
}

- (BOOL)canStartMovingTabAtIndex:(int)index {
    return index != exampleWebViewTab.index;
}

- (BOOL)canMoveTabAtIndex:(int)index toIndex:(int)toIndex {
    return toIndex != exampleWebViewTab.index;
}

- (BOOL)canAddTab {
    return self.tabsCount < 99;
}


#pragma mark - Events

- (void)willAddNewTabAtIndex:(int)index {}
- (void)didAddNewTabAtIndex:(int)index {}
- (void)willMoveTabAtIndex:(int)fromIndex toIndex:(int)toIndex {}
- (void)didMoveTabAtIndex:(int)fromIndex toIndex:(int)toIndex {}
- (void)willCloseTabAtIndex:(int)index {}
- (void)didCloseTabAtIndex:(int)index {}
- (void)tabsWillBecomeVisible {
    [exampleWebView.scrollView setShowsVerticalScrollIndicator:NO];
    [exampleWebView.scrollView setShowsHorizontalScrollIndicator:NO];
}
- (void)tabsDidBecomeVisible {}
- (void)tabsWillBecomeHidden {}
- (void)tabsDidBecomeHidden {
    [exampleWebView.scrollView setShowsVerticalScrollIndicator:YES];
    [exampleWebView.scrollView setShowsHorizontalScrollIndicator:YES];
    [exampleWebView.scrollView flashScrollIndicators];
}

- (void)didBeginMovingTabAtIndex:(int)index {
#ifdef DEBUG
    NSLog(@"Picked up tab at index %d", index);
#endif
}

- (void)didCancelMovingTabAtIndex:(int)index {
#ifdef DEBUG
    NSLog(@"Didn't move it");
#endif
}

- (void)didFinishMovingTabAtIndex:(int)fromIndex toIndex:(int)toIndex {
#ifdef DEBUG
    NSLog(@"Moved it to index %d", toIndex);
#endif
}

- (void)didBeginClosingTabAtIndex:(int)index {}
- (void)didCancelClosingTabAtIndex:(int)index {}
- (void)didFinishClosingTabAtIndex:(int)index {}

- (void)didBeginSwitchingTabAtIndex:(int)index {
    [exampleWebView.scrollView.pinchGestureRecognizer setEnabled:NO];
    [exampleWebView.scrollView.panGestureRecognizer setEnabled:NO];
}

- (void)didCancelSwitchingTabAtIndex:(int)index {
    [exampleWebView.scrollView.pinchGestureRecognizer setEnabled:YES];
    [exampleWebView.scrollView.panGestureRecognizer setEnabled:YES];
}

- (void)didFinishSwitchingTabAtIndex:(int)fromIndex toIndex:(int)toIndex {
    [exampleWebView.scrollView.pinchGestureRecognizer setEnabled:YES];
    [exampleWebView.scrollView.panGestureRecognizer setEnabled:YES];
}


@end
