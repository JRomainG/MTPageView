//
//  MTPageViewContainer.m
//  MTPageView
//
//  Created by Jean-Romain on 12/07/2017.
//  Copyright © 2017 JustKodding. All rights reserved.
//

#import "MTPageViewContainer.h"
#import "MTPageViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation MTPageViewContainer

- (id)init {
    self = [super init];
    if (self) {
        [self initializeContainer];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeContainer];
    }
    return self;
}

- (void)initializeContainer {
    [self setAutoresizesSubviews:YES];
    
    // Add a shadow under the view
    self.layer.shadowOffset = CGSizeMake(0, kShadowSize);
    self.layer.shadowRadius = 4;
    
    // Create a view to display information
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, kHeaderViewHeight)];
    [headerView setBackgroundColor:[UIColor blackColor]];
    [headerView setAlpha:0.0];
    [self addSubview:headerView];
    
    // Add a remove button
    removeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [removeButton setFrame:CGRectMake(0, 0, kHeaderViewHeight, kHeaderViewHeight)];
    [removeButton setTitle:[NSString stringWithFormat:@"%C", 0x2715] forState:UIControlStateNormal];
    [removeButton.titleLabel setFont:[UIFont systemFontOfSize:kHeaderFontSize + 2]];
    [removeButton.titleLabel setNumberOfLines:1];
    [removeButton.titleLabel setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];
    [removeButton addTarget:self action:@selector(closeTab) forControlEvents:UIControlEventTouchUpInside];
    [removeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [headerView addSubview:removeButton];
    
    // Add a subtitle in the view
    subtitleLabel = [[UILabel alloc] init];
    [subtitleLabel setFrame:CGRectMake(kHeaderViewHeight, 0, self.frame.size.width - 2 * kHeaderViewHeight, kHeaderViewHeight)];
    [subtitleLabel setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
    [subtitleLabel setText:NSLocalizedString(@"New tab", nil)];
    [subtitleLabel setTextColor:[UIColor whiteColor]];
    [subtitleLabel setFont:[UIFont boldSystemFontOfSize:kHeaderFontSize]];
    [subtitleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [subtitleLabel setTextAlignment:NSTextAlignmentCenter];
    [subtitleLabel setNumberOfLines:1];
    [headerView addSubview:subtitleLabel];
    
    // Add a tap gesture recognizer to check when the tab should be selected
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectTab)];
    [tapGestureRecognizer setNumberOfTouchesRequired:1];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [tapGestureRecognizer setEnabled:NO];
    [self addGestureRecognizer:tapGestureRecognizer];
    
    // Create a leftArrow view displayed when the tab is being moved to a new position
    self.leftArrow = [[MTGradiantAlphaView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width / 2, self.frame.size.height)];
    [self.leftArrow setGradiantDirection:MTGradiantDirectionLeftToRight];
    [self.leftArrow setBackgroundColor:[UIColor lightGrayColor]];
    [self.leftArrow setAlpha:0.0];
    
    UIImageView *leftArrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kArrowViewMargin, self.leftArrow.frame.size.height / 2 - kArrowViewHeight / 2, kArrowViewHeight, kArrowViewHeight)];
    [leftArrowImageView setImage:[[UIImage imageNamed:@"LeftArrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [leftArrowImageView setTintColor:[UIColor blackColor]];
    [leftArrowImageView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin];
    [leftArrowImageView setAlpha:0.8];
    [self.leftArrow addSubview:leftArrowImageView];
    [self insertSubview:self.leftArrow belowSubview:headerView];
    
    // Create a rightArrow view displayed when the tab is being moved to a new position
    self.rightArrow = [[MTGradiantAlphaView alloc] initWithFrame:CGRectMake(self.frame.size.width / 2, 0, self.frame.size.width / 2, self.frame.size.height)];
    [self.rightArrow setGradiantDirection:MTGradiantDirectionRightToLeft];
    [self.rightArrow setBackgroundColor:[UIColor lightGrayColor]];
    [self.rightArrow setAlpha:0.0];
    
    UIImageView *rightArrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.leftArrow.frame.size.width - kArrowViewMargin - kArrowViewHeight, self.leftArrow.frame.size.height / 2 - kArrowViewHeight / 2, kArrowViewHeight, kArrowViewHeight)];
    [rightArrowImageView setImage:[[UIImage imageNamed:@"RightArrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    [rightArrowImageView setTintColor:[UIColor blackColor]];
    [rightArrowImageView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin];
    [rightArrowImageView setAlpha:0.8];
    [self.rightArrow addSubview:rightArrowImageView];
    [self insertSubview:self.rightArrow belowSubview:self.leftArrow];
}

- (void)layoutSubviews {
    [removeButton setHidden:![self.parentController canCloseTabAtIndex:self.tab.index]];
}

- (void)setTab:(MTPageViewTab *)tab {
    [self.tab removeFromSuperview];
    _tab = tab;
    
    if (tab) {
        [self setHidden:NO];
        [self insertSubview:tab belowSubview:self.rightArrow];
        [self updateFrameWithContentSize:tab.frame.size];
    } else {
        [self setHidden:YES];
    }
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self updateFrameWithContentSize:frame.size];
}

- (void)updateFrameWithContentSize:(CGSize)size {
    [headerView setFrame:CGRectMake(0, 0, size.width, kHeaderViewHeight)];
    [self.leftArrow setFrame:CGRectMake(0, 0, self.frame.size.width / 2, self.frame.size.height)];
    [self.rightArrow setFrame:CGRectMake(self.frame.size.width / 2, 0, self.frame.size.width / 2, self.frame.size.height)];
}

- (void)hideHeader {
    [tapGestureRecognizer setEnabled:NO];

    [UIView animateWithDuration:kTabsShowAnimationDuration animations:^{
        [headerView setAlpha:0.0];
    } completion:^(BOOL finished) {
        [self.layer setShadowOpacity:0.0];
        [self.layer setMasksToBounds:YES];
        [self.tab setUserInteractionEnabled:YES];
    }];
}

- (void)showHeader {
    [self.layer setMasksToBounds:NO];
    [self.tab setUserInteractionEnabled:NO];

    [UIView animateWithDuration:kTabsShowAnimationDuration animations:^{
        [self.layer setShadowOpacity:kShadowAlpha];
        [headerView setAlpha:1.0];
    } completion:^(BOOL finished) {
        [tapGestureRecognizer setEnabled:YES];
    }];
}

- (void)closeTab {
    [self.parentController closeTabAtIndex:self.tab.index animated:YES];
}

- (void)selectTab {
    [self.parentController scrollToIndex:self.tab.index animated:NO];
    [self.parentController hideTabs];
}

@end
