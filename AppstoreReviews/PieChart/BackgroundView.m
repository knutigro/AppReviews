//
//  BackgroundView.m
//  SimplePieChart
//
//  Created by subo on 14-4-23.
//  Copyright (c) 2014年 __MyCompanyName__. All rights reserved.
//

#import "BackgroundView.h"
#import "NSColor+CGColor.h"

@implementation BackgroundView

@synthesize backgroundColor = _backgroundColor;
@synthesize center = _center;

- (void)setBackgroundColor:(NSColor *)backgroundColor {
    _backgroundColor = backgroundColor;
    self.layer.backgroundColor = _backgroundColor.CGColor;
}

@end
