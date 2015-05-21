//
//  PieChart.m
//  SimplePieChart
//
//  Created by subo on 14-4-23.
//  Copyright (c) 2014年 __MyCompanyName__. All rights reserved.
//

#import "PieChart.h"
#import <QuartzCore/QuartzCore.h>
#import "NSColor+CGColor.h"
#import "SliceLayer.h"



@interface PieChart ()

- (void)updateTimerFired:(NSTimer *)timer;
- (SliceLayer *)createSliceLayer;
- (void)updateLabelForLayer:(SliceLayer *)pieLayer value:(CGFloat)value;
- (void)notifyDelegateOfSelectionChangeFrom:(NSInteger)previousSelection to:(NSUInteger)newSelection;
- (NSDictionary *)textArrtribute;

@end

@implementation PieChart

static NSUInteger kDefaultSliceZOrder = 100;

@synthesize dataSource = _dataSource, delegate = _delegate;
@synthesize startPieAngle = _startPieAngle;
@synthesize animationSpeed = _animationSpeed;
@synthesize pieCenter = _pieCenter, pieRadius = _pieRadius;
@synthesize showText = _showText;
@synthesize textFont = _textFont, textColor = _textColor, textShadowColor = _textShadowColor, textRadius = _textRadius;
@synthesize selectedSliceStroke = _selectedSliceStroke, selectedSliceOffsetRadius = _selectedSliceOffsetRadius;
@synthesize showPercentage = _showPercentage;
@synthesize canSelect = _canSelect;

static CGPathRef CGPathCreateArc(CGPoint center, CGFloat radius, CGFloat startAngle, CGFloat endAngle) 
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, center.x, center.y);
    
    CGPathAddArc(path, NULL, center.x, center.y, radius, startAngle, endAngle, 0);
    CGPathCloseSubpath(path);
    
    return path;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.wantsLayer = YES;
        self.backgroundColor = [NSColor clearColor];
        _pieView = [[BackgroundView alloc] initWithFrame:frame];
        [_pieView setWantsLayer:YES];
        [_pieView setBackgroundColor:[NSColor clearColor]];
        [self addSubview:_pieView positioned:NSWindowAbove relativeTo:nil];
        
        _selectedSliceIndex = -1;
        _animations = [[NSMutableArray alloc] init];
        
        _animationSpeed = 0.5;
        _startPieAngle = M_PI_2*3;
        _selectedSliceStroke = 2.0;
        
        self.pieCenter = CGPointMake( frame.size.width/2, frame.size.height/2);
        self.pieRadius = MIN(frame.size.width/2, frame.size.height/2) - 10;
//        self.pieCenter = CGPointMake(frame.size.width/2, frame.size.height/2);
        self.textFont = [NSFont boldSystemFontOfSize:13];
        self.textColor = [NSColor whiteColor];
        _textRadius = _pieRadius/2;
        _selectedSliceOffsetRadius = MAX(10, _pieRadius/10);
        
        _showText = YES;
        _showPercentage = YES;
    }
    return self;
}

- (void)destoryTrackingArea {
    if (_trackingArea) {
        [self removeTrackingArea:_trackingArea];
        _trackingArea = nil;
    }
}

- (id)initWithFrame:(NSRect)frame Center:(CGPoint)center Radius:(CGFloat)radius
{
    self = [self initWithFrame:frame];
    if (self)
    {
        self.pieCenter = center;
        self.pieRadius = radius;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        self.wantsLayer = YES;
        _pieView = [[BackgroundView alloc] initWithFrame:self.bounds];
        [_pieView setBackgroundColor:[NSColor clearColor]];
        [self addSubview:_pieView positioned:NSWindowAbove relativeTo:nil];
        
        _selectedSliceIndex = -1;
        _animations = [[NSMutableArray alloc] init];
        
        _animationSpeed = 0.5;
        _startPieAngle = M_PI_2*2;
        _selectedSliceStroke = 2.0;
        
        CGRect bounds = [[self layer] bounds];
        self.pieRadius = MIN(bounds.size.width/2, bounds.size.height/2) - 10;
        
        self.textFont = [NSFont boldSystemFontOfSize:MAX((int)self.pieRadius/10, 5)];
        self.textColor = [NSColor whiteColor];
        _textRadius = _pieRadius/2;
        _selectedSliceOffsetRadius = MAX(10, _pieRadius/10);
        
        _showText = YES;
        _showPercentage = YES;
    }
    return self;
}

- (void)setPieCenter:(CGPoint)pieCenter
{
    [_pieView setCenter:pieCenter];
    _pieCenter = CGPointMake(_pieView.frame.size.width/2, _pieView.frame.size.height/2);
}

- (void)setPieRadius:(CGFloat)pieRadius
{
    _pieRadius = pieRadius;
//    NSPoint origin = _pieView.frame.origin;
//    NSRect frame = NSMakeRect(origin.x + _pieCenter.x - pieRadius, origin.y + _pieCenter.y - pieRadius, pieRadius * 2, pieRadius * 2);
//    _pieCenter = CGPointMake(frame.size.width/2, frame.size.height/2);
//    [_pieView setFrame:frame];
    [_pieView.layer setCornerRadius:_pieRadius];
}

- (void)setPieBackgroundColor:(NSColor *)color
{
    [_pieView setBackgroundColor:color];
}

#pragma mark - ......:::::::: Manager Setting ::::::::......

- (void)setShowPercentage:(BOOL)showPercentage
{
    _showPercentage = showPercentage;
    for(SliceLayer *layer in _pieView.layer.sublayers)
    {
        CATextLayer *textLayer = [[layer sublayers] objectAtIndex:0];
        [textLayer setHidden:!_showText];
        if(!_showText) return;
        
        NSString *label;
        if(_showPercentage)
            label = [NSString stringWithFormat:@"%0.0f", layer.percentage*100];
        else
            label = (layer.text)?layer.text:[NSString stringWithFormat:@"%0.0f", layer.value];
        NSDictionary *attrDict = [NSDictionary dictionaryWithObject:self.textFont forKey:NSFontAttributeName];
        NSSize size = [label sizeWithAttributes:attrDict];
        
        if(M_PI * 2 * _textRadius * layer.percentage < MAX(size.width,size.height))
        {
            [textLayer setString:@""];
        }
        else
        {
            [textLayer setString:label];
            [textLayer setBounds:CGRectMake(0, 0, size.width, size.height)];
        }
    }
}

#pragma mark - ......:::::::: Pie Reload Data With Animation ::::::::......

- (void)reloadData
{
    if (_dataSource)
    {
        CALayer *parentLayer = [_pieView layer];
        parentLayer.position = CGPointMake(NSMinX(_pieView.frame) - NSMinX(self.frame), 
                                           NSMinY(_pieView.frame) - NSMinY(self.frame));
        NSArray *slicelayers = [parentLayer sublayers];
        
        _selectedSliceIndex = -1;
        [slicelayers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            SliceLayer *layer = (SliceLayer *)obj;
            if(layer.isSelected)
                [self setSliceDeselectedAtIndex:idx];
        }];
        
        double startToAngle = 0.0;
        double endToAngle = startToAngle;
        
        NSUInteger sliceCount = [_dataSource numberOfSlicesInPieChart:self];
        
        double sum = 0.0;
        double values[sliceCount];
        for (int index = 0; index < sliceCount; index++) {
            values[index] = [_dataSource pieChart:self valueForSliceAtIndex:index];
            sum += values[index];
        }
        
        //计算每一项的角度
        double angles[sliceCount];
        for (int index = 0; index < sliceCount; index++) {
            double div;
            if (sum == 0)
                div = 0;
            else
                div = values[index] / sum; 
            angles[index] = M_PI * 2 * div;
        }
        
        [CATransaction begin];
        [CATransaction setAnimationDuration:_animationSpeed];
        
        __block NSMutableArray *layersToRemove = nil;
        
        BOOL isOnStart = ([slicelayers count] == 0 && sliceCount);
        NSInteger diff = sliceCount - [slicelayers count];
        layersToRemove = [NSMutableArray arrayWithArray:slicelayers];
        
        BOOL isOnEnd = ([slicelayers count] && (sliceCount == 0 || sum <= 0));
        if(isOnEnd)
        {
            for(SliceLayer *layer in _pieView.layer.sublayers){
                [self updateLabelForLayer:layer value:0];
                [layer createArcAnimationForKey:@"startAngle"
                                      fromValue:[NSNumber numberWithDouble:_startPieAngle]
                                        toValue:[NSNumber numberWithDouble:_startPieAngle] 
                                       Delegate:self];
                [layer createArcAnimationForKey:@"endAngle" 
                                      fromValue:[NSNumber numberWithDouble:_startPieAngle]
                                        toValue:[NSNumber numberWithDouble:_startPieAngle] 
                                       Delegate:self];
            }
            [CATransaction commit];
            return;
        }
        
        for(int index = 0; index < sliceCount; index ++)
        {
            SliceLayer *layer;
            double angle = angles[index];
            endToAngle += angle;
            double startFromAngle = _startPieAngle + startToAngle;
            double endFromAngle = _startPieAngle + endToAngle;
            
            if( index >= [slicelayers count] )
            {
                layer = [self createSliceLayer];
                if (isOnStart)
                    startFromAngle = endFromAngle = _startPieAngle;
                [parentLayer addSublayer:layer];
                diff--;
            }
            else
            {
                SliceLayer *onelayer = [slicelayers objectAtIndex:index];
                if(diff == 0 || onelayer.value == (CGFloat)values[index])
                {
                    layer = onelayer;
                    [layersToRemove removeObject:layer];
                }
                else if(diff > 0)
                {
                    layer = [self createSliceLayer];
                    [parentLayer insertSublayer:layer atIndex:index];
                    diff--;
                }
                else if(diff < 0)
                {
                    while(diff < 0) 
                    {
                        [onelayer removeFromSuperlayer];
                        [parentLayer addSublayer:onelayer];
                        diff++;
                        onelayer = [slicelayers objectAtIndex:index];
                        if(onelayer.value == (CGFloat)values[index] || diff == 0)
                        {
                            layer = onelayer;
                            [layersToRemove removeObject:layer];
                            break;
                        }
                    }
                }
            }
            
            layer.value = values[index];
            layer.percentage = (sum)?layer.value/sum:0;
            NSColor *color = nil;
            if([_dataSource respondsToSelector:@selector(pieChart:colorForSliceAtIndex:)])
            {
                color = [_dataSource pieChart:self colorForSliceAtIndex:index];
            }
            
            if(!color)
            {
                color = [NSColor colorWithDeviceHue:((index/8)%20)/20.0+0.02 saturation:(index%8+3)/10.0 brightness:91/100.0 alpha:1.0];
            }
            
            [layer setFillColor:color.CGColor];
            if([_dataSource respondsToSelector:@selector(pieChart:textForSliceAtIndex:)])
            {
                layer.text = [_dataSource pieChart:self textForSliceAtIndex:index];
            }
            
            [self updateLabelForLayer:layer value:values[index]];
            [layer createArcAnimationForKey:@"startAngle"
                                  fromValue:[NSNumber numberWithDouble:startFromAngle]
                                    toValue:[NSNumber numberWithDouble:startToAngle+_startPieAngle] 
                                   Delegate:self];
            [layer createArcAnimationForKey:@"endAngle" 
                                  fromValue:[NSNumber numberWithDouble:endFromAngle]
                                    toValue:[NSNumber numberWithDouble:endToAngle+_startPieAngle] 
                                   Delegate:self];
            startToAngle = endToAngle;
        }
        [CATransaction setDisableActions:YES];
        for(SliceLayer *layer in layersToRemove)
        {
            [layer setFillColor:[self backgroundColor].CGColor];
            [layer setDelegate:nil];
            [layer setZPosition:0];
            CATextLayer *textLayer = [[layer sublayers] objectAtIndex:0];
            [textLayer setHidden:YES];
        }
        
        [layersToRemove enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [obj removeFromSuperlayer];
        }];
        
        [layersToRemove removeAllObjects];
        
        for(SliceLayer *layer in _pieView.layer.sublayers)
        {
            [layer setZPosition:kDefaultSliceZOrder];
        }
                
        [CATransaction setDisableActions:NO];
        [CATransaction commit];
    }
}

- (void)updateTimerFired:(NSTimer *)timer;
{   
    CALayer *parentLayer = [_pieView layer];
    NSArray *pieLayers = [parentLayer sublayers];
    
    [pieLayers enumerateObjectsUsingBlock:^(CAShapeLayer * obj, NSUInteger idx, BOOL *stop) {
        
        NSNumber *presentationLayerStartAngle = [[obj presentationLayer] valueForKey:@"startAngle"];
        CGFloat interpolatedStartAngle = [presentationLayerStartAngle doubleValue];
        
        NSNumber *presentationLayerEndAngle = [[obj presentationLayer] valueForKey:@"endAngle"];
        CGFloat interpolatedEndAngle = [presentationLayerEndAngle doubleValue];
        
        CGPathRef path = CGPathCreateArc(_pieCenter, _pieRadius, interpolatedStartAngle, interpolatedEndAngle);
        [obj setPath:path];
        CFRelease(path);
        
        {
            CALayer *labelLayer = [[obj sublayers] objectAtIndex:0];
            CGFloat interpolatedMidAngle = (interpolatedEndAngle + interpolatedStartAngle) / 2;        
            [CATransaction setDisableActions:YES];
            [labelLayer setPosition:CGPointMake(_pieCenter.x + (_textRadius * cos(interpolatedMidAngle)), _pieCenter.y + (_textRadius * sin(interpolatedMidAngle)))];
            [CATransaction setDisableActions:NO];
        }
    }];
}

- (void)animationDidStart:(CAAnimation *)anim
{
    if (_animationTimer == nil) {
        static float timeInterval = 1.0/60.0;
        // Run the animation timer on the main thread.
        // We want to allow the user to interact with the UI while this timer is running.
        // If we run it on this thread, the timer will be halted while the user is touching the screen (that's why the chart was disappearing in our collection view).
        _animationTimer= [NSTimer timerWithTimeInterval:timeInterval target:self selector:@selector(updateTimerFired:) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:_animationTimer forMode:NSRunLoopCommonModes];
    }
    
    [_animations addObject:anim];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)animationCompleted
{
    [_animations removeObject:anim];
    
    if ([_animations count] == 0) {
        [_animationTimer invalidate];
        _animationTimer = nil;
    }
}

#pragma mark - ......:::::::: Selection Notification ::::::::......

- (void)notifyDelegateOfSelectionChangeFrom:(NSInteger)previousSelection to:(NSUInteger)newSelection
{
    if (previousSelection != newSelection){
        BOOL hasPrevoids = NO;
        if(previousSelection != -1){
            hasPrevoids = YES;
            NSUInteger tempPre = previousSelection;
            if ([_delegate respondsToSelector:@selector(pieChart:willDeselectSliceAtIndex:)])
                [_delegate pieChart:self willDeselectSliceAtIndex:tempPre];
            [self setSliceDeselectedAtIndex:tempPre];
            previousSelection = newSelection;
            if([_delegate respondsToSelector:@selector(pieChart:didDeselectSliceAtIndex:)])
                [_delegate pieChart:self didDeselectSliceAtIndex:tempPre];
        }
        
        if (newSelection != -1){
            if([_delegate respondsToSelector:@selector(pieChart:willSelectSliceAtIndex:)])
                [_delegate pieChart:self willSelectSliceAtIndex:newSelection];
            
            if (hasPrevoids && previousSelection != -1) {
                double delayInSeconds = 0.3;
                //创建一个调度时间,相对于默认时钟或修改现有的调度时间。
                dispatch_time_t delayInNanoSeconds =dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                //推迟两纳秒执行
                dispatch_after(delayInNanoSeconds, dispatch_get_main_queue(), ^(void){
                    [self setSliceSelectedAtIndex:newSelection];
                    
                    _selectedSliceIndex = newSelection;
                    if([_delegate respondsToSelector:@selector(pieChart:didSelectSliceAtIndex:)])
                        [_delegate pieChart:self didSelectSliceAtIndex:newSelection];
                });
            }
            else {
                [self setSliceSelectedAtIndex:newSelection];
                
                _selectedSliceIndex = newSelection;
                if([_delegate respondsToSelector:@selector(pieChart:didSelectSliceAtIndex:)])
                    [_delegate pieChart:self didSelectSliceAtIndex:newSelection];
            }
        }
    }else if (newSelection != -1){
        SliceLayer *layer = [_pieView.layer.sublayers objectAtIndex:newSelection];
        if(_selectedSliceOffsetRadius > 0 && layer){
            if (layer.isSelected) {
                if ([_delegate respondsToSelector:@selector(pieChart:willDeselectSliceAtIndex:)])
                    [_delegate pieChart:self willDeselectSliceAtIndex:newSelection];
                [self setSliceDeselectedAtIndex:newSelection];
                if (newSelection != -1 && [_delegate respondsToSelector:@selector(pieChart:didDeselectSliceAtIndex:)])
                    [_delegate pieChart:self didDeselectSliceAtIndex:newSelection];
                previousSelection = _selectedSliceIndex = -1;
            }else{
                if ([_delegate respondsToSelector:@selector(pieChart:willSelectSliceAtIndex:)])
                    [_delegate pieChart:self willSelectSliceAtIndex:newSelection];
                [self setSliceSelectedAtIndex:newSelection];
                previousSelection = _selectedSliceIndex = newSelection;
                if (newSelection != -1 && [_delegate respondsToSelector:@selector(pieChart:didSelectSliceAtIndex:)])
                    [_delegate pieChart:self didSelectSliceAtIndex:newSelection];
            }
        }
    }
}

#pragma mark - ......:::::::: Selection Programmatically Without Notification ::::::::......

- (void)setSliceSelectedAtIndex:(NSInteger)index
{
    if(_selectedSliceOffsetRadius <= 0)
        return;
    SliceLayer *layer = [_pieView.layer.sublayers objectAtIndex:index];
    if (layer && !layer.isSelected) {
        CGPoint currPos = layer.position;
        double middleAngle = (layer.startAngle + layer.endAngle)/2.0;
        CGPoint newPos = CGPointMake(currPos.x + _selectedSliceOffsetRadius*cos(middleAngle), currPos.y + _selectedSliceOffsetRadius*sin(middleAngle));
        layer.position = newPos;
        layer.selected = YES;
    }
}

- (void)setSliceDeselectedAtIndex:(NSInteger)index
{
    if(_selectedSliceOffsetRadius <= 0)
        return;
    SliceLayer *layer = [_pieView.layer.sublayers objectAtIndex:index];
    if (layer && layer.isSelected) {
        layer.position = CGPointMake(0, 0);
        layer.selected = NO;
    }
}

#pragma mark - ......:::::::: Pie Layer Creation Method ::::::::......

- (SliceLayer *)createSliceLayer
{
    SliceLayer *pieLayer = [SliceLayer layer];
    [pieLayer setZPosition:0];
    [pieLayer setStrokeColor:NULL];
    
    CATextLayer *textLayer = [CATextLayer layer];
    CGFontRef font = CGFontCreateWithFontName((CFStringRef)[self.textFont fontName]);

    if (font) {
        [textLayer setFont:font];
        CFRelease(font);
    }
    [textLayer setFontSize:self.textFont.pointSize];
    [textLayer setAnchorPoint:CGPointMake(0.5, 0.5)];
    [textLayer setAlignmentMode:kCAAlignmentCenter];
    [textLayer setBackgroundColor:[NSColor clearColor].CGColor];
    [textLayer setForegroundColor:self.textColor.CGColor];
    if (self.textShadowColor) {
        [textLayer setShadowColor:self.textShadowColor.CGColor];
        [textLayer setShadowOffset:CGSizeZero];
        [textLayer setShadowOpacity:1.0f];
        [textLayer setShadowRadius:2.0f];
    }
    NSSize size = [@"0" sizeWithAttributes:[self textArrtribute]];
    [CATransaction setDisableActions:YES];
    [textLayer setFrame:CGRectMake(0, 0, size.width, size.height)];
    [textLayer setPosition:CGPointMake(_pieCenter.x + (_textRadius * cos(0)), _pieCenter.y + (_textRadius * sin(0)))];
    [CATransaction setDisableActions:NO];
    [pieLayer addSublayer:textLayer];
    return pieLayer;
}

- (void)updateLabelForLayer:(SliceLayer *)pieLayer value:(CGFloat)value
{
    CATextLayer *textLayer = [[pieLayer sublayers] objectAtIndex:0];
    [textLayer setHidden:!_showText];
    if(!_showText) return;
    NSString *label;
    if(_showPercentage)
        label = [NSString stringWithFormat:@"%0.0f", pieLayer.percentage*100];
    else
        label = (pieLayer.text)?pieLayer.text:[NSString stringWithFormat:@"%0.0f", value];
    
    NSSize size = [label sizeWithAttributes:[self textArrtribute]];
    
    [CATransaction setDisableActions:YES];
    if(M_PI*2*_textRadius*pieLayer.percentage < MAX(size.width,size.height) || value <= 0)
    {
        [textLayer setString:@""];
    }
    else
    {
        [textLayer setString:label];
        [textLayer setFont:(__bridge CFTypeRef)(self.textFont)];
        [textLayer setBounds:CGRectMake(0, 0, size.width, size.height)];
    }
    [CATransaction setDisableActions:NO];
}

#pragma mark - ......:::::::: Mouse Event ::::::::......

- (NSInteger)getCurrentSelectedOnLocation:(CGPoint)point
{
    __block NSUInteger selectedIndex = -1;
    
    CALayer *parentLayer = [_pieView layer];
    NSArray *pieLayers = [parentLayer sublayers];
    
    [pieLayers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SliceLayer *pieLayer = (SliceLayer *)obj;
        CGPathRef path = [pieLayer path];
        
        if (CGPathContainsPoint(path, NULL, point, 0)) {
            [pieLayer setLineWidth:_selectedSliceStroke];
            [pieLayer setStrokeColor:[NSColor whiteColor].CGColor];
            [pieLayer setLineJoin:kCALineJoinBevel];
            [pieLayer setZPosition:MAXFLOAT];
            selectedIndex = idx;
        } else {
            [pieLayer setZPosition:kDefaultSliceZOrder];
            [pieLayer setLineWidth:0.0];
        }
    }];
    return selectedIndex;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent {return YES;}

- (void)mouseDown:(NSEvent *)theEvent {
    NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSInteger selectedIndex = [self getCurrentSelectedOnLocation:NSPointToCGPoint(point)];
    [self notifyDelegateOfSelectionChangeFrom:_selectedSliceIndex to:selectedIndex];
    CALayer *parentLayer = [_pieView layer];
    NSArray *pieLayers = [parentLayer sublayers];
    
    for (SliceLayer *pieLayer in pieLayers) {
        [pieLayer setZPosition:kDefaultSliceZOrder];
        [pieLayer setLineWidth:0.0];
    }
}

- (void)mouseExited:(NSEvent *)theEvent {
    CALayer *parentLayer = [_pieView layer];
    NSArray *pieLayers = [parentLayer sublayers];
    
    [pieLayers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SliceLayer *pieLayer = (SliceLayer *)obj;
        [pieLayer setLineWidth:0.0];
    }];
}

#pragma mark - ......:::::::: Private Method ::::::::......

- (NSDictionary *)textArrtribute {
    if (self.textFont) {
        return [NSDictionary dictionaryWithObject:self.textFont forKey:NSFontAttributeName];
    }
    
    return nil;
}

@end
