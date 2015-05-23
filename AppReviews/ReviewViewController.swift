//
//  ViewController.swift
//  App Reviews
//
//  Created by Knut Inge Grosland on 2015-04-08.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import Cocoa

class ReviewViewController: NSViewController {

    @IBOutlet weak var tableView: NSTableView?
    @IBOutlet var reviewArrayController: ReviewArrayController?
    
    var managedObjectContext: NSManagedObjectContext!

    var application: Application? {
        didSet {
            self.reviewArrayController?.application = self.application
            if let application = self.application {
                ReviewManager.appUpdater().resetNewReviewsCountForApplication(application.objectID)
            }
            self.tableView?.reloadData()
        }
    }
    // MARK: - Init & teardown
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.managedObjectContext = ReviewManager.managedObjectContext()
    }
}

// MARK: NSTableViewDelegate

extension ReviewViewController: NSTableViewDelegate {

    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {

        let review = self.reviewArrayController?.arrangedObjects[row] as? Review
        var height = review?.content.size(tableView.frame.size.width - 85, font: NSFont.systemFontOfSize(13)).height ?? 0
        
        return height + 80
    }
}

// MARK: Actions

extension ReviewViewController {
    
    @IBAction func copyReviewToClipBoardClicked(menuItem: NSMenuItem) {
        if self.tableView?.clickedRow > 0 && self.tableView?.clickedRow < self.reviewArrayController?.arrangedObjects.count {
            if let review = self.reviewArrayController?.arrangedObjects[self.tableView!.clickedRow] as? Review {
                var pasteBoard = NSPasteboard.generalPasteboard()
                pasteBoard.clearContents()
                pasteBoard.writeObjects([review.toString()])
            }
        }
    }

    @IBAction func openReviewClicked(menuItem: NSMenuItem) {
        if self.tableView?.clickedRow > 0 && self.tableView?.clickedRow < self.reviewArrayController?.arrangedObjects.count {
            if let review = self.reviewArrayController?.arrangedObjects[self.tableView!.clickedRow] as? Review {
                if let url = NSURL(string: review.uri) {
                    NSWorkspace.sharedWorkspace().openURL(url)
                }
            }
        }
    }

    @IBAction func saveReviewClicked(menuItem: NSMenuItem) {
        if self.tableView?.clickedRow > 0 && self.tableView?.clickedRow < self.reviewArrayController?.arrangedObjects.count {
            if let review = self.reviewArrayController?.arrangedObjects[self.tableView!.clickedRow] as? Review {
                var savePanel = NSSavePanel()
                savePanel.title = review.title
                savePanel.nameFieldStringValue = review.title
                savePanel.allowedFileTypes = [kUTTypeText]
                let result = savePanel.runModal()
                if result != NSFileHandlingPanelCancelButton {
                    if let url = savePanel.URL {
                        var error: NSError?
                        review.toString().writeToURL(url, atomically: true, encoding: NSUTF8StringEncoding, error: &error)
                    }
                }
            }
        }
    }
}

