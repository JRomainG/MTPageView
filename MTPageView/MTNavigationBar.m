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
    // Add a custom cancel button to the navigation bar
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.cancelButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    [self.cancelButton setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [self.cancelButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin];
    [self addSubview:self.cancelButton];
    [self.cancelButton sizeToFit];
    [self.cancelButton setFrame:CGRectMake(self.frame.size.width - self.cancelButton.frame.size.width - kNavBarSideMargin, kNavBarTopDownMargin + [UIApplication sharedApplication].statusBarFrame.size.height, self.cancelButton.frame.size.width, kNavBarMaxHeight - 2 * kNavBarTopDownMargin)];

    // Use a custom title field for the navigation bar
    _textField = [[MTTextField alloc] initWithFrame:CGRectMake(kNavBarSideMargin, kNavBarTopDownMargin + [UIApplication sharedApplication].statusBarFrame.size.height, self.frame.size.width - self.cancelButton.frame.size.width - 3 * kNavBarSideMargin, self.frame.size.height - 2 * kNavBarTopDownMargin - [UIApplication sharedApplication].statusBarFrame.size.height)];
    [self.textField setBackgroundColor:[UIColor whiteColor]];
    [self.textField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [self.textField setDelegate:self];
    [self addSubview:self.textField];
    
    [self hideCancelButtonAnimated:NO];
}

- (void)cancelAction {
    [self.textField restoreSavedText];
    [self.textField resignFirstResponder];
}

- (void)showCancelButton {
    [self showCancelButtonAnimated:YES];
}

- (void)showCancelButtonAnimated:(BOOL)animated {
    [UIView animateWithDuration:kCancelButtonAnimationDuration * animated animations:^{
        [self.cancelButton setAlpha:1];
        [self.textField setFrame:CGRectMake(self.textField.frame.origin.x, self.textField.frame.origin.y, self.frame.size.width - self.cancelButton.frame.size.width - 3 * kNavBarSideMargin, self.textField.frame.size.height)];
    }];
}

- (void)hideCancelButton {
    [self hideCancelButtonAnimated:YES];
}

- (void)hideCancelButtonAnimated:(BOOL)animated {
    [UIView animateWithDuration:kCancelButtonAnimationDuration * animated animations:^{
        [self.cancelButton setAlpha:0];
        [self.textField setFrame:CGRectMake(kNavBarSideMargin, self.textField.frame.origin.y, self.frame.size.width - 2 * kNavBarSideMargin, self.textField.frame.size.height)];
    }];
}

- (float)statusBarHeight {
    // [UIApplication sharedApplication].statusBarFrame.size.height doesn't always give the right height when and orientation just changed
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) || UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // Status bar is displayed full height
        return [UIApplication sharedApplication].statusBarFrame.size.height;
    } else {
        // status bar should be hidden
        return 0;
    }
}

- (float)maxHeight {
    return kNavBarMaxHeight + [self statusBarHeight];
}

- (float)minHeight {
    return kNavBarMinHeight + [self statusBarHeight];
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

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    if (self.cancelButton.alpha > 0) {
        [self.textField setFrame:CGRectMake(kNavBarSideMargin, kNavBarTopDownMargin + [UIApplication sharedApplication].statusBarFrame.size.height, self.frame.size.width - self.cancelButton.frame.size.width - 3 * kNavBarSideMargin, self.frame.size.height - 2 * kNavBarTopDownMargin - [UIApplication sharedApplication].statusBarFrame.size.height)];
    } else {
        [self.textField setFrame:CGRectMake(kNavBarSideMargin, kNavBarTopDownMargin + [UIApplication sharedApplication].statusBarFrame.size.height, self.frame.size.width - 2 * kNavBarSideMargin, self.frame.size.height - 2 * kNavBarTopDownMargin - [UIApplication sharedApplication].statusBarFrame.size.height)];
    }
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
