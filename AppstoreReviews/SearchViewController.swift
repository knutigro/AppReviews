//
//  ApplicationSearchViewController.swift
//  App Reviews
//
//  Created by Knut Inge Grosland on 2015-04-13.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import Cocoa
import SwiftyJSON

protocol SearchViewControllerDelegate {
    func searchViewController(searchViewController : SearchViewController, didSelectApplication application: JSON)
    func searchViewControllerDidCancel(searchViewController : SearchViewController)
}

enum SearchViewControllerState {
    case Idle
    case Loading
}

class SearchViewController: NSViewController {

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!

    var items = [JSON]()
    var delegate: SearchViewControllerDelegate?
    var state : SearchViewControllerState = .Idle {
        didSet {
            switch self.state {
            case .Idle:
                self.progressIndicator.stopAnimation(nil)
            case .Loading:
                self.progressIndicator.startAnimation(nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.target = self
        self.tableView.doubleAction = Selector("doubleClickedCell:")
    }
}

// MARK: - Actions

extension SearchViewController {
    
    func doubleClickedCell(object : AnyObject) {
        if let rowNumber = self.tableView?.selectedRow {
            if rowNumber < self.items.count {
                let application = self.items[rowNumber]
                delegate?.searchViewController(self, didSelectApplication: application)
            }
        }
    }
    
    @IBAction func cancelButtonClicked(sender: AnyObject) {
        delegate?.searchViewControllerDidCancel(self)
    }
}

// MARK: - NSTableViewDataSource

extension SearchViewController : NSTableViewDataSource {
    
    func numberOfRowsInTableView(aTableView: NSTableView) -> Int {
        return self.items.count
    }
    
    func tableView(tableView: NSTableView, viewForTableColumn: NSTableColumn, row: Int) -> NSView {
        var cell = tableView.makeViewWithIdentifier(kApplicationCellIdentifier, owner: self) as! ApplicationCellView
        let application = self.items[row]
        cell.textField?.stringValue = application.trackName ?? ""
        cell.authorTextField?.stringValue = application.sellerName ?? ""
        
        if let urlString = application.artworkUrl60 {
            if let url = NSURL(string: urlString) {
                cell.imageView?.setImageWithUrl(url, placeHolderImage: nil)
            }
        }

        return cell;
    }
}

// MARK: NSResponder

extension SearchViewController {
    override func cancelOperation(sender: AnyObject?) {
        delegate?.searchViewControllerDidCancel(self)
    }
}

