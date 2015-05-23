//
//  PieChart.swift
//  App Reviews
//
//  Created by Knut Inge Grosland on 2015-05-04.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import AppKit

class ReviewPieChartController: NSViewController {
    
    @IBOutlet weak var pieChart: PieChart?
    
    var slices = [Float]()
    var sliceColors: [NSColor]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sliceColors = [NSColor.reviewRed(), NSColor.reviewOrange(), NSColor.reviewYellow(), NSColor.reviewGreen(), NSColor.reviewBlue()]
        
        if let pieChart = self.pieChart {
            pieChart.dataSource = self
            pieChart.delegate = self
            pieChart.pieCenter = CGPointMake(240, 240)
            pieChart.showPercentage = false
        }
    }
}

extension ReviewPieChartController: PieChartDataSource {
    
    func numberOfSlicesInPieChart(pieChart: PieChart!) -> UInt {
        return UInt(self.slices.count)
    }
    
    func pieChart(pieChart: PieChart!, valueForSliceAtIndex index: UInt) -> CGFloat {
        return CGFloat(self.slices[Int(index)])
    }
    
    func pieChart(pieChart: PieChart!, colorForSliceAtIndex index: UInt) -> NSColor! {
        return self.sliceColors[Int(index) % self.sliceColors.count]
    }
    
    func pieChart(pieChart: PieChart!, textForSliceAtIndex index: UInt) -> String! {
        return (NSString(format: NSLocalizedString("%i Stars", comment: "review.slice.tooltip"), index + 1) as String)
    }
}

extension ReviewPieChartController: PieChartDelegate {
    func pieChart(pieChart: PieChart!, toopTipStringAtIndex index: UInt) -> String! {
        let number = self.slices[Int(index)]
        return (NSString(format: NSLocalizedString("Number of ratings: ", comment: "review.slice.tooltip"), number) as String)
    }
}

