//
//  MTNavigationBar.m
//  MTPageView
//
//  Created by Jean-Romain on 16/07/2017.
//  Copyright © 2017 JustKodding. All rights reserved.
//

#import "MTNavigationBar.h"

@implementation MTNavigationBar

- (id)init {
    self = [super init];
    
    if (self) {
        [self initItems];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initItems];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self initItems];
    }
    
    return self;
}

- (void)initItems {
    CGRect navigationBarFrame = CGRectMake(0, 0, self.bounds.size.width, 44 + [[UIApplication sharedApplication] statusBarFrame].size.height);
    [self setFrame:navigationBarFrame];
    
    // Add a custom cancel button to the navigation bar
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.cancelButton setFrame:CGRectMake(self.frame.size.width - 50 - kNavBarSideMargin, kNavBarTopDownMargin, 50, self.frame.size.height - 2 * kNavBarTopDownMargin)];
    [self.cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [self.cancelButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight];
    [self addSubview:self.cancelButton];
    
    // Use a custom title field for the navigation bar
    self.textField = [[MTTextField alloc] initWithFrame:CGRectMake(kNavBarSideMargin, kNavBarTopDownMargin, self.frame.size.width - self.cancelButton.frame.size.width - 3 * kNavBarSideMargin, self.frame.size.height - 2 * kNavBarTopDownMargin)];
    [self.textField setBackgroundColor:[UIColor whiteColor]];
    [self.textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [self.textField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self.textField setDelegate:self];
    [self addSubview:self.textField];
    
    [self hideCancelButtonAnimated:NO];
}

- (void)cancelAction {
    [self.textField resignFirstResponder];
}

- (void)showCancelButton {
    [self showCancelButtonAnimated:YES];
}

- (void)showCancelButtonAnimated:(BOOL)animated {
    [UIView animateWithDuration:kCancelButtonAnimationDuration * animated animations:^{
        [self.cancelButton setAlpha:1];
        [self.textField setFrame:CGRectMake(kNavBarSideMargin, kNavBarTopDownMargin, self.frame.size.width - self.cancelButton.frame.size.width - 3 * kNavBarSideMargin, self.frame.size.height - 2 * kNavBarTopDownMargin)];
    }];
}

- (void)hideCancelButton {
    [self hideCancelButtonAnimated:YES];
}

- (void)hideCancelButtonAnimated:(BOOL)animated {
    [UIView animateWithDuration:kCancelButtonAnimationDuration * animated animations:^{
        [self.cancelButton setAlpha:0];
        [self.textField setFrame:CGRectMake(kNavBarSideMargin, kNavBarTopDownMargin, self.frame.size.width - 2 * kNavBarSideMargin, self.frame.size.height - 2 * kNavBarTopDownMargin)];
    }];
}

- (float)maxHeight {
    return kNavBarMaxHeight;
}

- (float)minHeight {
    return kNavBarMinHeight;
}

- (void)setTextField:(MTTextField *)textField {
    CGRect frame = self.textField.frame;
    [self.textField removeFromSuperview];
    _textField = nil;
    
    _textField = textField;
    [self addSubview:self.textField];
    [self.textField setFrame:frame];
    [self.textField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [self.textField setDelegate:self];
}


#pragma mark - UITextField delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self showCancelButton];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self hideCancelButton];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.textField resignFirstResponder];
    return YES;
}

@end
