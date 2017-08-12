//
//  MTGradiantAlphaView.m
//  MTPageView
//
//  Created by Jean-Romain on 13/07/2017.
//  Copyright © 2017 JustKodding. All rights reserved.
//

#import "MTGradiantAlphaView.h"

@implementation MTGradiantAlphaView

- (id)init {
    self = [super init];
    
    if (self) {
        [self initGradiant];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initGradiant];
    }
    
    return self;
}

- (void)initGradiant {
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.bounds;
    gradientLayer.colors = [NSArray arrayWithObjects:(id)self.backgroundColor.CGColor, (id)[UIColor clearColor].CGColor, nil];
    
    if (self.gradiantDirection == MTGradiantDirectionLeftToRight) {
        gradientLayer.startPoint = CGPointMake(0.1f, 0.5f);
        gradientLayer.endPoint = CGPointMake(1.0f, 0.5f);
    } else {
        gradientLayer.startPoint = CGPointMake(0.9f, 0.5f);
        gradientLayer.endPoint = CGPointMake(0.0f, 0.5f);
    }
    
    self.layer.mask = gradientLayer;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    [self initGradiant];
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self initGradiant];
}

@end
