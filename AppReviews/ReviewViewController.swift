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
    
    var selectedCell: NSTableCellView?
    
    var selectedReview: Review? {
        if tableView?.selectedRow >= 0 && tableView?.selectedRow < reviewArrayController?.arrangedObjects.count {
            return reviewArrayController?.arrangedObjects[tableView!.selectedRow] as? Review
        } else {
            return nil
        }
    }

    var application: Application? {
        didSet {
            reviewArrayController?.application = application
            if let application = application {
                ReviewManager.appUpdater().resetNewReviewsCountForApplication(application.objectID)
            }
            tableView?.reloadData()
        }
    }
    // MARK: - Init & teardown
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        managedObjectContext = ReviewManager.managedObjectContext()
        
        let applicationMonitor = NSNotificationCenter.defaultCenter().addObserverForName(NSViewFrameDidChangeNotification, object: nil, queue: nil) {  [weak self] notification in
            
            // Resize TableViewCellHeights when View is resized.
            if let tableView = notification.object as? NSTableView {
                let visibleRows = tableView.rowsInRect(self!.view.frame)
                NSAnimationContext.beginGrouping()
                NSAnimationContext.currentContext().duration = 0
                tableView.noteHeightOfRowsWithIndexesChanged(NSIndexSet(indexesInRange: visibleRows))
                NSAnimationContext.endGrouping()
            }
        }
    }
    
}

// MARK: NSTableViewDelegate

extension ReviewViewController: NSTableViewDelegate {

    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {

        let review = reviewArrayController?.arrangedObjects[row] as? Review
        var height = review?.content.size(tableView.frame.size.width - 85, font: NSFont.systemFontOfSize(13)).height ?? 0
        
        return height + 80
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        if let row = notification.object?.selectedRow {
            selectedCell = notification.object?.viewAtColumn(0, row: row, makeIfNecessary: false) as? NSTableCellView
        }
    }
}

// MARK: Actions

extension ReviewViewController {
    
    @IBAction func shareSelectedReview(sender: AnyObject?) {
        if let review = self.selectedReview, let textField = self.selectedCell?.textField {
            var sharingServicePicker = NSSharingServicePicker(items: [review.toString()])
            sharingServicePicker.delegate = self
            sharingServicePicker.showRelativeToRect(textField.bounds, ofView: textField, preferredEdge: NSMinYEdge)
        } else {
            var alert = NSAlert()
            alert.messageText = NSLocalizedString("Select a review to share.", comment: "review.share.nothingSelected")
            alert.beginSheetModalForWindow(self.view.window!, completionHandler:nil)
        }
    }
    
    @IBAction func copyReviewToClipBoardClicked(menuItem: NSMenuItem) {
        if let review = self.selectedReview {
            var pasteBoard = NSPasteboard.generalPasteboard()
            pasteBoard.clearContents()
            pasteBoard.writeObjects([review.toString()])
        }
    }

    @IBAction func openReviewClicked(menuItem: NSMenuItem) {
        if let review = self.selectedReview {
            if let url = NSURL(string: review.uri) {
                NSWorkspace.sharedWorkspace().openURL(url)
            }
        }
    }

    @IBAction func saveReviewClicked(menuItem: NSMenuItem) {
        if let review = self.selectedReview {
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

// MARK: - NSSharingServicePickerDelegate

extension ReviewViewController: NSSharingServicePickerDelegate {
    
}

