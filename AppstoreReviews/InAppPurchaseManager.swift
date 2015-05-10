//
//  InAppPurchaseManager.swift
//  AppstoreReviews
//
//  Created by Knut Inge Grosland on 2015-05-03.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import AppKit
import StoreKit
import Alamofire
import SwiftyJSON

let kInAppPurchaseManagerErrorDomain = "kInAppPurchaseManagerErrorDomain"

enum InAppPurchaseManagerErrorCode : Int {
    case ReceiptDontExist = 0
}

#if DEBUG
    let verifyReceiptUrl = "https://sandbox.itunes.apple.com/verifyReceipt"
#else
    let verifyReceiptUrl = "https://buy.itunes.apple.com/verifyReceipt"
#endif

let kInAppPurchaseManagerProductsFetchedNotification      = "kInAppPurchaseManagerProductsFetchedNotification"
let kInAppPurchaseManagerTransactionFailedNotification    = "kInAppPurchaseManagerTransactionFailedNotification"
let kInAppPurchaseManagerTransactionSucceededNotification = "kInAppPurchaseManagerTransactionSucceededNotification"

let kInAppPurchaseManagerTransactionKey = "transaction"

class InAppPurchaseManager : NSObject {

    var premiumUpgradeProduct : SKProduct?
    var receipt : InAppPurchaseReceipt?

    private var productsRequest : SKProductsRequest?

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

        // Load products from itunes
        self.requestPremiumUpgradeProductData()
        
        // Check receipts from previous purchases and if receipt dont exist or is not valid remove premiumstatus
        self.updateUserWithItunesReceipt();
    }
    
    func updateUserWithItunesReceipt() {
        self.fetchItunesReceipt { (receipt, error) -> Void in

            self.receipt = receipt
            
            if let receipt = receipt {
                if let status = receipt.status {
                    switch status {
                    case .Valid:
                        for purchase in receipt.inAppPurchaseItems {
                            if purchase.productId == kInAppPurchaseContentPremium {
                                self.setPremiumUser(true)
                            }
                        }
                        break;
                    case .ServerNotAvailable:
                        break;
                    default :
                        self.setPremiumUser(false)
                        break;
                    }
                }
                
            } else {
                if let error = error {
                    if error.code == InAppPurchaseManagerErrorCode.ReceiptDontExist.rawValue {
                        self.setPremiumUser(false)
                    }
                    
                }
            }
        }
    }
 
    func fetchItunesReceipt(completion: (receipt: InAppPurchaseReceipt?, error : NSError?) -> Void) {
        var receiptData : NSData?
        var error : NSError?

        if let receiptURLpath = NSBundle.mainBundle().appStoreReceiptURL?.path {
            if NSFileManager.defaultManager().fileExistsAtPath(receiptURLpath) {
                if let receiptDataString = NSData(contentsOfURL: NSBundle.mainBundle().appStoreReceiptURL!)?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(0)) {
                    
                    let requestContents = ["receipt-data" : receiptDataString]
                    
                    receiptData = NSJSONSerialization.dataWithJSONObject(requestContents, options: NSJSONWritingOptions(0), error: nil)
                        
                    if (receiptData != nil) {
                        Alamofire.upload(.POST, verifyReceiptUrl, receiptData!).responseJSON { [weak self] (request, response, json, error) in
                            if error != nil {
                                completion(receipt: nil, error: error)
                            } else {
                                completion(receipt: InAppPurchaseReceipt(json: JSON(json!)), error: error)
                            }
                        }
                    }
                }
            }
        }
        
        if receiptData == nil {
            if error == nil {
                error = NSError(domain:kInAppPurchaseManagerErrorDomain, code: InAppPurchaseManagerErrorCode.ReceiptDontExist.rawValue, userInfo: [NSLocalizedDescriptionKey : NSLocalizedString("Appstore receipt not found on device.", comment: "error.inapppurchase.receiptdontexist")])
            }
            completion(receipt: nil, error: error)
        }
    }
    
    func canMakePurchases() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    private func provideContent(productId : String) {
        if productId == kInAppPurchaseContentPremium {
            self.setPremiumUser(true)
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
    
    private func successfullTransaction(transaction : SKPaymentTransaction) {
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
                    self.successfullTransaction(transaction as! SKPaymentTransaction)
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

// MARK: - Premium

let kInAppPurchaseContentPremium = "premium"

extension InAppPurchaseManager {
    
    var premiumItem : InAppPurchaseItem? {
        if let receipt = self.receipt {
            for item in receipt.inAppPurchaseItems {
                if item.productId == kInAppPurchaseContentPremium {
                    return item
                }
            }
        }
        return nil
    }

    func purchasePremiumUpgrade() {
        if let premiumProduct = self.premiumUpgradeProduct {
            if let payment = SKPayment.paymentWithProduct(premiumProduct) as? SKPayment {
                SKPaymentQueue.defaultQueue().addPayment(payment)
            }
        }
    }
    
    func isPremiumUser() -> Bool {
        return NSUserDefaults.isPremiumUser();
    }
    
    func setPremiumUser(premium : Bool) {
        if (premium != self.isPremiumUser()) {
            NSUserDefaults.setPremiumUser(premium)
        }
    }
    
    private func requestPremiumUpgradeProductData() {
        var productID : NSSet = NSSet(object:kInAppPurchaseContentPremium);
        self.productsRequest = SKProductsRequest(productIdentifiers: productID as Set<NSObject>)
        self.productsRequest?.delegate = self
        self.productsRequest?.start()
    }

}