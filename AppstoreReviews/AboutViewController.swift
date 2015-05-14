//
//  AboutViewController.swift
//  App Reviews
//
//  Created by Knut Inge Grosland on 2015-05-03.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//
import Cocoa
import StoreKit

class AboutViewController: NSViewController {
    
    @IBOutlet weak var versionLabel: NSTextField?
    @IBOutlet weak var premiumLabel: NSTextField?
    @IBOutlet weak var premiumButton: NSButton?
    @IBOutlet weak var restorePurchaseButton: NSButton?
    
//    - Notifications for an unlimited number of apps.
//    - Backup your reviews.

    var isPremium : Bool = false {
        didSet {
            if self.isPremium {
                var text = NSString(format: NSLocalizedString("Thank you for your support! \nPremium Licence.", comment: "about.premiumlabel.ispremium"), "") as! String

                if let premiumItem = InAppPurchaseManager.sharedInstance.premiumItem, let originalPurchaseDateMs = InAppPurchaseManager.sharedInstance.premiumItem?.originalPurchaseDateMs?.toInt() {
                    let date = NSDate(timeIntervalSince1970: NSTimeInterval(originalPurchaseDateMs))
                    var dateFormatter = NSDateFormatter()
                    dateFormatter.dateStyle = .MediumStyle
                }
                self.premiumLabel?.stringValue = text;
                self.premiumButton?.hidden = true
                self.restorePurchaseButton?.hidden = true
            } else {
                self.premiumButton?.hidden = false
                self.restorePurchaseButton?.hidden = false
                
                if let premium = InAppPurchaseManager.sharedInstance.premiumUpgradeProduct {
                    let text = NSLocalizedString("Appstore Reviews is free to use as long as we are in Beta. \n\nIf you still want to support the development, you can do this by buying the Premium License.", comment: "about.premiumlabel.ispremium")
//                    let text = NSString(format: NSLocalizedString("Buy %@ for %@ and you will get:\n\n%@", comment: "about.premiumlabel.ispremium"), premium.localizedTitle, premium.localizedPrice, premium.localizedDescription) as! String
                    self.premiumLabel?.stringValue = text;
                } else {
                    self.premiumLabel?.stringValue = "";
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let productsFetched = NSNotificationCenter.defaultCenter().addObserverForName(kInAppPurchaseManagerProductsFetchedNotification, object: nil, queue: nil) {  [weak self] notification in
            if let strongSelf = self {
                strongSelf.updatePremiumState()
            }
        }
        
        let transactionFailed = NSNotificationCenter.defaultCenter().addObserverForName(kInAppPurchaseManagerTransactionFailedNotification, object: nil, queue: nil) {  [weak self] notification in
            if let strongSelf = self {
                strongSelf.updatePremiumState()
            }
        }

        let transactionSucceeded = NSNotificationCenter.defaultCenter().addObserverForName(kInAppPurchaseManagerTransactionSucceededNotification, object: nil, queue: nil) {  [weak self] notification in
            if let strongSelf = self {
                strongSelf.updatePremiumState()
            }
        }
        
        self.versionLabel?.stringValue = NSApplication.v_versionBuild()
        
        self.updatePremiumState()
    }
    
    func updatePremiumState() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.isPremium = InAppPurchaseManager.sharedInstance.isPremiumUser()
        })
    }
    
    @IBAction func premiumButtonClicked(objects:AnyObject?) {
        InAppPurchaseManager.sharedInstance.purchasePremiumUpgrade()
    }

    @IBAction func restoreButtonClicked(objects:AnyObject?) {
        InAppPurchaseManager.sharedInstance.restoreCompletedTransactions()
    }

    
}

