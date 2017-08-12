//
//  CustomWebView.m
//  MTPageView
//
//  Created by Jean-Romain on 03/08/2017.
//  Copyright © 2017 JustKodding. All rights reserved.
//

#import "CustomWebView.h"
#import "MTScrollBarManager.h"

@implementation CustomWebView

- (id)init {
    self = [super init];
    
    if (self) {
        [self initWebView];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initWebView];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self initWebView];
    }
    
    return self;
}

- (void)initWebView {
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self setBackgroundColor:[UIColor lightGrayColor]];
    [self loadRequest:[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://apple.com"]]];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];    
}

@end
