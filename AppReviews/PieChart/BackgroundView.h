//
//  BackgroundView.h
//  SimplePieChart
//
//  Created by subo on 14-4-23.
//  Copyright (c) 2014年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface BackgroundView : NSView {
    NSColor *_backgroundColor;
    CGPoint _center;
}

@property (nonatomic,retain) NSColor *backgroundColor;
@property (nonatomic,assign) CGPoint center;

@end
