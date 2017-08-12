//
//  WebTextField.h
//  MTPageView
//
//  Created by Jean-Romain on 17/07/2017.
//  Copyright © 2017 JustKodding. All rights reserved.
//

#import "MTTextField.h"
#import <UIKit/UIKit.h>

@interface WebTextField : MTTextField {
    UITextFieldViewMode _rightViewMode;
    UITextFieldViewMode _leftViewMode;
}

@property (nonatomic, strong) UIButton *refreshButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *tlsButton;

@end
