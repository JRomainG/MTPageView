//
//  MTTextField.h
//  MTPageView
//
//  Created by Jean-Romain on 16/07/2017.
//  Copyright © 2017 JustKodding. All rights reserved.
//

#import <UIKit/UIKit.h>

static const CGFloat kMinTextFieldHeight = 20.0f;
static const CGFloat kMinTextFieldFontSize = 8.0f;

@interface MTTextField : UITextField {
    UIFont *savedFont;
    BOOL isReduced;
}

@end
