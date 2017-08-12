//
//  MTPageViewTab.m
//  MTPageView
//
//  Created by Jean-Romain on 12/07/2017.
//  Copyright © 2017 JustKodding. All rights reserved.
//

#import "MTPageViewTab.h"
#import "MTPageViewContainer.h"

@implementation MTPageViewTab

- (void)setTitle:(NSString *)title {
    _title = title;
}

- (void)setScrollBarManager:(MTScrollBarManager *)scrollBarManager {
    [_scrollBarManager removeFromSuperview];
    
    _scrollBarManager = scrollBarManager;
    [self addSubview:scrollBarManager];    
}

@end
