//
//  ReviewSplitViewController.swift
//  App Reviews
//
//  Created by Knut Inge Grosland on 2015-04-22.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import AppKit

class ReviewSplitViewController: NSSplitViewController {
    
    var application: Application? {
        didSet {
            reviewMenuViewController?.application = application
            reviewViewController?.application = application
        }
    }
    
    var reviewMenuViewController: ReviewMenuViewController?
    var reviewViewController: ReviewViewController?
    
    var menuSplitViewItem: NSSplitViewItem {
        return splitViewItems[0]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let reviewMenuViewController = menuSplitViewItem.viewController as? ReviewMenuViewController {
            self.reviewMenuViewController = reviewMenuViewController
            self.reviewMenuViewController?.application = application
        }
        if let reviewViewController = menuSplitViewItem.viewController as? ReviewViewController {
            self.reviewViewController = reviewViewController
            self.reviewViewController?.application = application
        }
        
        menuSplitViewItem.animator().collapsed = NSUserDefaults.review_isLeftMenuCollapsed()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        NSUserDefaults.review_setLeftMenuCollapsed(menuSplitViewItem.collapsed)
    }
    
    func toggleLeftMenu() {
        menuSplitViewItem.animator().collapsed = !menuSplitViewItem.collapsed
    }
}