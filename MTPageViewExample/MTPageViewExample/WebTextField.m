//
//  WebTextField.m
//  MTPageView
//
//  Created by Jean-Romain on 17/07/2017.
//  Copyright © 2017 JustKodding. All rights reserved.
//

#import "WebTextField.h"

@implementation WebTextField

- (id)init {
    self = [super init];
    
    if (self) {
        [self initButtons];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initButtons];
    }
    
    return self;
}

- (void)initButtons {
    self.refreshButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.refreshButton setFrame:CGRectMake(0, 0, 29, 29)];
    [self.refreshButton setBackgroundColor:[UIColor clearColor]];
    [self.refreshButton setImage:[[UIImage imageNamed:@"Reload"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.refreshButton setTintColor:[UIColor grayColor]];
    [self.refreshButton addTarget:self action:@selector(refreshAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self setRightView:self.refreshButton];
    [self setRightViewMode:UITextFieldViewModeAlways];

    self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.cancelButton setFrame:CGRectMake(0, 0, 29, 29)];
    [self.cancelButton setBackgroundColor:[UIColor clearColor]];
    [self.cancelButton setImage:[[UIImage imageNamed:@"StopLoading"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.cancelButton setTintColor:[UIColor grayColor]];
    [self.cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];

    self.tlsButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.tlsButton setFrame:CGRectMake(0, 0, 29, 29)];
    [self.tlsButton setBackgroundColor:[UIColor clearColor]];
    [self.tlsButton setImage:[[UIImage imageNamed:@"Secure"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.tlsButton setTintColor:[UIColor grayColor]];
    [self.tlsButton addTarget:self action:@selector(showTLSAction) forControlEvents:UIControlEventTouchUpInside];

    [self setLeftView:self.tlsButton];
    [self setLeftViewMode:UITextFieldViewModeAlways];

    [self.rightView setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin];
    [self.leftView setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin];
    
    [self setBackgroundColor:[UIColor whiteColor]];
    [self setClearButtonMode:UITextFieldViewModeWhileEditing];
    [self setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [self setAutocorrectionType:UITextAutocorrectionTypeNo];
    [self setReturnKeyType:UIReturnKeyGo];
    [self setKeyboardType:UIKeyboardTypeWebSearch];
}

- (BOOL)becomeFirstResponder {
    [super setRightViewMode:UITextFieldViewModeNever];
    [super setLeftViewMode:UITextFieldViewModeNever];
    [self setTextAlignment:NSTextAlignmentLeft];

    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
    [super setRightViewMode:_rightViewMode];
    [super setLeftViewMode:_leftViewMode];
    [self setTextAlignment:NSTextAlignmentCenter];

    return [super resignFirstResponder];
}

- (void)setRightViewMode:(UITextFieldViewMode)rightViewMode {
    _rightViewMode = rightViewMode;
    
    if (!self.isFirstResponder) {
        [super setRightViewMode:rightViewMode];
    }
}

- (void)setLeftViewMode:(UITextFieldViewMode)leftViewMode {
    _leftViewMode = leftViewMode;
    
    if (!self.isFirstResponder) {
        [super setLeftViewMode:leftViewMode];
    }
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];

    if (self.isFirstResponder) {
        [super setRightViewMode:UITextFieldViewModeNever];
        [super setLeftViewMode:UITextFieldViewModeNever];
    } else {
        [super setRightViewMode:_rightViewMode];
        [super setLeftViewMode:_leftViewMode];
    }
    
    if (self.isFirstResponder) {
        [self setTextAlignment:NSTextAlignmentLeft];
    } else {
        [self setTextAlignment:NSTextAlignmentCenter];
    }
}


#pragma mark - Actions

- (void)refreshAction {
    
}

- (void)cancelAction {
    
}

- (void)showTLSAction {
    
}

@end
