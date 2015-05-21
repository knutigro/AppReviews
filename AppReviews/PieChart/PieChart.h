//
//  PieChart.h
//  SimplePieChart
//
//  Created by subo on 14-4-23.
//  Copyright (c) 2014年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BackgroundView.h"

@class PieChart;

@protocol PieChartDataSource <NSObject>

@required
- (NSUInteger)numberOfSlicesInPieChart:(PieChart *)pieChart;
- (CGFloat)pieChart:(PieChart *)pieChart valueForSliceAtIndex:(NSUInteger)index;

@optional
- (NSColor *)pieChart:(PieChart *)pieChart colorForSliceAtIndex:(NSUInteger)index;
- (NSString *)pieChart:(PieChart *)pieChart textForSliceAtIndex:(NSUInteger)index;

@end

@protocol PieChartDelegate <NSObject>

@optional
- (void)pieChart:(PieChart *)pieChart willSelectSliceAtIndex:(NSUInteger)index;
- (void)pieChart:(PieChart *)pieChart didSelectSliceAtIndex:(NSUInteger)index;
- (void)pieChart:(PieChart *)pieChart willDeselectSliceAtIndex:(NSUInteger)index;
- (void)pieChart:(PieChart *)pieChart didDeselectSliceAtIndex:(NSUInteger)index;
- (NSString *)pieChart:(PieChart *)pieChart toopTipStringAtIndex:(NSUInteger)index;

@end

@interface PieChart : BackgroundView {
    
    CGFloat                     _startPieAngle;
    CGFloat                     _animationSpeed;
    CGPoint                     _pieCenter;
    CGFloat                     _pieRadius;
    BOOL                        _showText;
    NSFont                      *_textFont;
    NSColor                     *_textColor;
    NSColor                     *_textShadowColor;
    CGFloat                     _textRadius;
    CGFloat                     _selectedSliceStroke;
    CGFloat                     _selectedSliceOffsetRadius;
    BOOL                        _showPercentage;
    BOOL                        _canSelect;
    
    @private
    NSInteger _selectedSliceIndex;
    //pie view, contains all slices
    BackgroundView  *_pieView;
    
    //animation control
    NSTimer *_animationTimer;
    NSMutableArray *_animations;
    
    NSTrackingArea *_trackingArea;
}

@property (nonatomic,assign) id<PieChartDataSource> dataSource;
@property (nonatomic,assign) id<PieChartDelegate> delegate;
@property (nonatomic,assign) CGFloat startPieAngle;
@property (nonatomic,assign) CGFloat animationSpeed;
@property (nonatomic,assign) CGPoint pieCenter;                 
@property (nonatomic,assign) CGFloat pieRadius;                 //半径
@property (nonatomic,assign,getter = isShowText) BOOL showText;
@property (nonatomic,retain) NSFont *textFont;
@property (nonatomic,retain) NSColor *textColor;
@property (nonatomic,retain) NSColor *textShadowColor;
@property (nonatomic,assign) CGFloat textRadius;
@property (nonatomic,assign) CGFloat selectedSliceStroke;
@property (nonatomic,assign) CGFloat selectedSliceOffsetRadius;
@property (nonatomic,assign,getter = isShowPercentage) BOOL showPercentage;
@property (nonatomic,assign) BOOL canSelect;

- (id)initWithFrame:(NSRect)frame Center:(CGPoint)center Radius:(CGFloat)radius;
- (void)reloadData;
- (void)setPieBackgroundColor:(NSColor *)color;

- (void)setSliceSelectedAtIndex:(NSInteger)index;
- (void)setSliceDeselectedAtIndex:(NSInteger)index;

@end
