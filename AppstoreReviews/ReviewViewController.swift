//
//  ViewController.swift
//  AppstoreReviews
//
//  Created by Knut Inge Grosland on 2015-04-08.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import Cocoa

class ReviewViewController: NSViewController {

    @IBOutlet weak var tableView: NSTableView?
    @IBOutlet var reviewArrayController: ReviewArrayController?
    
    var managedObjectContext : NSManagedObjectContext!
    private let dbController = DBController()

    var application : Application? {
        didSet {
            self.reviewArrayController?.application = self.application
            self.tableView?.reloadData()
        }
    }
    
    // MARK: - Init & teardown
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.managedObjectContext = DBController.sharedInstance.persistentStack.managedObjectContext
    }
}

// MARK: NSTableViewDelegate

extension ReviewViewController : NSTableViewDelegate {

    func tableView(tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        
        
//        let col: AnyObject = tableView.tableColumns[0]
//        
//        let cell = col.dataCell as! NSTextFieldCell
//        
//
//        
//        
////
////        struct Static {
////            static var token : dispatch_once_t = 0
////            static var sizingCell : ReviewCellView!
////        }
////        dispatch_once(&Static.token, { () -> Void in
////            Static.sizingCell = nil
//////            Static.sizingCell = tableView.makeViewWithIdentifier("ReviewCellView", owner: self) as? ReviewCellView
////        })
//        let review = self.reviewArrayController?.arrangedObjects[row] as? Review
//        if let content = review?.content {
////            Static.sizingCell?.textField?.stringValue = content
////            cell.textField?.stringValue = content
//                cell.stringValue = content
//            
////            var size = cell.cellSize
////            let width = size.width
//            
//            // Make the frame very high, while keeping the width
////            size.height = CGFloat.max
//            
//            let size: CGSize = (content as NSString).sizeWithAttributes([NSFontAttributeName: NSFont.systemFontOfSize(14.0)])
//
////            CGSize size = [string sizeWithFont:font constrainedToSize:constrainSize lineBreakMode:NSLineBreakByWordWrapping];
//
//            // Calculate new height within the frame
//            // with practically infinite height.
//            
//            //        let height = Static.sizingCell?.textField?.cell()?.cellSizeForBounds(frame).height
//            let height = cell.textField?.cell()?.cellSizeForBounds(frame).height
//            
//            
//            println("height \(height)")
//
        
            
//            CGRect textRect = [text boundingRectWithSize:size
//                options:NSStringDrawingUsesLineFragmentOrigin
//                attributes:@{NSFontAttributeName:FONT}
//            context:nil];
//            
//            CGSize size = textRect.size;
//        }
        
//
//        return cell.frame.size.height + height!
        
        return 150
    }
}
    
