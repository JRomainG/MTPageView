//
//  MTTextField.m
//  MTPageView
//
//  Created by Jean-Romain on 16/07/2017.
//  Copyright © 2017 JustKodding. All rights reserved.
//

#import "MTTextField.h"
#import "MTNavigationBar.h"

@implementation MTTextField

- (id)init {
    self = [super init];
    
    if (self) {
        [self initContent];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initContent];
    }
    
    return self;
}

- (void)initContent {
    savedFont = self.font;
    isReduced = NO;
    
    [self setBorderStyle:UITextBorderStyleRoundedRect];
    [self setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [self setAdjustsFontSizeToFitWidth:YES];
    [self setNeedsDisplay];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    if (frame.size.height < kMinTextFieldHeight) {
        if (!isReduced) {
            // Only need to do this once
            isReduced = YES;
            [self setTextAlignment:NSTextAlignmentCenter];
            [self setBorderStyle:UITextBorderStyleNone];
            [self setNeedsDisplay];

            [self setBackgroundColor:[UIColor clearColor]];
            
            if (!self.isFirstResponder) {
                [self.leftView setAlpha:0];
                [self.rightView setAlpha:0];
            }
        }
        
        float fontSize = savedFont.pointSize * (1 - fabs((frame.size.height - kMinTextFieldHeight) / kMinTextFieldHeight));
        fontSize = MAX(kMinTextFieldFontSize, fontSize);
        [super setFont:[UIFont fontWithName:savedFont.fontName size:fontSize]];
    } else {
        if (isReduced) {
            // Only need to do this once
            isReduced = NO;
            [self setTextAlignment:NSTextAlignmentLeft];
            [self setBorderStyle:UITextBorderStyleRoundedRect];
            [self setNeedsDisplay];
        
            [super setFont:savedFont];
        }
        
        float advancement = (frame.size.height - kMinTextFieldHeight) / ([self maxHeight] - kMinTextFieldHeight);
        [self setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:advancement]];
        
        if (!self.isFirstResponder) {
            [self.leftView setAlpha:advancement];
            [self.rightView setAlpha:advancement];
        }
    }
}

- (float)maxHeight {
    return [(MTNavigationBar *)self.superview maxHeight] - 2 * kNavBarTopDownMargin;
}

- (void)setFont:(UIFont *)font {
    savedFont = font;
    
    if (!isReduced) {
        [super setFont:font];
    }
}

@end
