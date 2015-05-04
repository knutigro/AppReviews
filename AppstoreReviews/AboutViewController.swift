//
//  AboutViewController.swift
//  AppstoreReviews
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
    
    var isPremium : Bool = false {
        didSet {
            if self.isPremium {
                self.premiumButton?.hidden = true
                let text = NSString(format: NSLocalizedString("Premium", comment: "about.premiumlabel.ispremium"), "") as! String
                self.premiumLabel?.stringValue = text;
            } else {
                self.premiumButton?.hidden = false
                
                if let premium = InAppPurchaseManager.sharedInstance.premiumUpgradeProduct {
                    let text = NSString(format: NSLocalizedString("Buy %@ for %@ and you will get:\n\n%@", comment: "about.premiumlabel.ispremium"), premium.localizedTitle, premium.localizedPrice, premium.localizedDescription) as! String
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
            self.isPremium = InAppPurchaseManager.sharedInstance.isPremium()
        })
    }
    
    @IBAction func premiumButtonClicked(objects:AnyObject?) {
        InAppPurchaseManager.sharedInstance.purchasePremiumUpgrade()
    }
}

