//
//  InAppPurchaseManager.swift
//  AppstoreReviews
//
//  Created by Knut Inge Grosland on 2015-05-03.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import AppKit
import StoreKit

let kInAppPurchaseManagerProductsFetchedNotification      = "kInAppPurchaseManagerProductsFetchedNotification"
let kInAppPurchaseManagerTransactionFailedNotification    = "kInAppPurchaseManagerTransactionFailedNotification"
let kInAppPurchaseManagerTransactionSucceededNotification = "kInAppPurchaseManagerTransactionSucceededNotification"

let kInAppPurchaseManagerTransactionKey = "transaction"

let kInAppPurchaseContentPremium = "premium"

class InAppPurchaseManager : NSObject {

    var premiumUpgradeProduct : SKProduct?
    var productsRequest : SKProductsRequest?
    
    class var sharedInstance: InAppPurchaseManager {
        struct Singleton {
            static let instance = InAppPurchaseManager()
        }
        return Singleton.instance
    }
    
    // call this method once on startup
    func loadStore() {
        // restarts any purchases if they were interrupted last time the app was open
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        self.requestPremiumUpgradeProductData()
    }
    
    func hasReceipt() -> Bool {
        var receiptData : NSData?
        if let receiptURLpath = NSBundle.mainBundle().appStoreReceiptURL?.path {
            if NSFileManager.defaultManager().fileExistsAtPath(receiptURLpath) {
                receiptData = NSData(contentsOfURL: NSBundle.mainBundle().appStoreReceiptURL!)
            }
        }
        
        return receiptData == nil;
    }
    
    func canMakePurchases() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    func purchasePremiumUpgrade() {
        if let premiumProduct = self.premiumUpgradeProduct {
            if let payment = SKPayment.paymentWithProduct(premiumProduct) as? SKPayment {
                SKPaymentQueue.defaultQueue().addPayment(payment)
            }
        }
    }
    
    func isPremium() -> Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey("kInAppPurchaseContentPremium");
    }

    private func requestPremiumUpgradeProductData() {
        var productID : NSSet = NSSet(object:kInAppPurchaseContentPremium);
        self.productsRequest = SKProductsRequest(productIdentifiers: productID as Set<NSObject>)
        self.productsRequest?.delegate = self
        self.productsRequest?.start()
    }
    
    
     // saves a record of the transaction by storing the receipt to disk
    private func recordTransaction(transaction : SKPaymentTransaction) {
        if transaction.payment.productIdentifier == kInAppPurchaseContentPremium {
            //???? https://developer.apple.com/library/prerelease/ios/releasenotes/General/ValidateAppStoreReceipt/Chapters/ValidateLocally.html#//apple_ref/doc/uid/TP40010573-CH1-SW2
        }
    }
    
    private func provideContent(productId : String) {
        if productId == kInAppPurchaseContentPremium {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "kInAppPurchaseContentPremium")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    private func finishTransaction(transaction : SKPaymentTransaction, wasSuccessful : Bool) {
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
        
        var userInfo = [kInAppPurchaseManagerTransactionKey : transaction]
        
        if wasSuccessful {
            NSNotificationCenter.defaultCenter().postNotificationName(kInAppPurchaseManagerTransactionSucceededNotification, object: self, userInfo: userInfo)
        } else {
            NSNotificationCenter.defaultCenter().postNotificationName(kInAppPurchaseManagerTransactionFailedNotification, object: self, userInfo: userInfo)
        }
    }
    
    private func finishTransaction(transaction : SKPaymentTransaction) {
        self.recordTransaction(transaction)
        self.provideContent(transaction.payment.productIdentifier)
        self.finishTransaction(transaction, wasSuccessful: true)
    }
    
    private func failedTransaction(transaction : SKPaymentTransaction) {
        if transaction.error.code != SKErrorPaymentCancelled {
            self.finishTransaction(transaction, wasSuccessful: false)
        } else {
            SKPaymentQueue.defaultQueue().finishTransaction(transaction)
        }
    }

    private func restoreTransaction(transaction : SKPaymentTransaction) {
        self.recordTransaction(transaction)
        self.provideContent(transaction.originalTransaction.payment.productIdentifier)
        self.finishTransaction(transaction, wasSuccessful: true)
    }
}

// MARK: - SKProductsRequestDelegate

extension InAppPurchaseManager : SKProductsRequestDelegate {
    
    func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
        let products = response.products
        let invalidproducts = response.invalidProductIdentifiers
        
        for product in products {
            if let skProduct = product as? SKProduct {
                if skProduct.productIdentifier == kInAppPurchaseContentPremium {
                    self.premiumUpgradeProduct = skProduct
                    println("In app Phurchase: " + skProduct.localizedTitle)
                    println(skProduct.localizedDescription)
                    println("Price \(skProduct.price)")
                }
            }
        }
        
        for invalidProductId in invalidproducts {
            println("Invalid: \(invalidProductId)")
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(kInAppPurchaseManagerProductsFetchedNotification, object: self)
    }
}

// MARK: - SKPaymentTransactionObserver

extension InAppPurchaseManager : SKPaymentTransactionObserver {
 
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!)    {
        println("Received Payment Transaction Response from Apple");
        
        for transaction:AnyObject in transactions {
            if let trans:SKPaymentTransaction = transaction as? SKPaymentTransaction{
                switch trans.transactionState {
                case SKPaymentTransactionStatePurchased:
                    println("SKPaymentTransactionStatePurchased");
                    self.finishTransaction(transaction as! SKPaymentTransaction)
                    break;
                case SKPaymentTransactionStateFailed:
                    println("SKPaymentTransactionStateFailed");
                    self.failedTransaction(transaction as! SKPaymentTransaction)
                    break;
                case SKPaymentTransactionStateRestored:
                    println("SKPaymentTransactionStateRestored");
                    self.restoreTransaction(transaction as! SKPaymentTransaction)
                    break;
                default:
                    break;
                }
            }
        }
    }
}

// MARK: - LocalizedPrice

extension SKProduct {
    
    var localizedPrice : String {
        get {
            var numberFormatter = NSNumberFormatter()
            numberFormatter.formatterBehavior = .Behavior10_4
            numberFormatter.numberStyle = .CurrencyStyle
            numberFormatter.locale = self.priceLocale
            
            var formattedString = numberFormatter.stringFromNumber(self.price)
            
            return formattedString ?? ""
        }
    }
}