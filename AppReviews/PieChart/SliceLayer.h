//
//  SliceLayer.h
//  TidyMyMusic
//
//  Created by subo on 14-4-24.
//  Copyright (c) 2014年 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface SliceLayer : CAShapeLayer {
    CGFloat _value;
    CGFloat _percentage;
    double _startAngle;
    double _endAngle;
    BOOL _selected;
    NSString *_text;
}

@property (nonatomic, assign) CGFloat   value;
@property (nonatomic, assign) CGFloat   percentage;
@property (nonatomic, assign) double    startAngle;
@property (nonatomic, assign) double    endAngle;
@property (nonatomic, assign,getter = isSelected) BOOL      selected;
@property (nonatomic, copy) NSString  *text;

- (void)createArcAnimationForKey:(NSString *)key fromValue:(NSNumber *)from toValue:(NSNumber *)to Delegate:(id)delegate;

@end
