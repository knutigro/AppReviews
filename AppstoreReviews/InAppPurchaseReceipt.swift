//
//  InAppPhurchaseItem.swift
//  App Reviews
//
//  Created by Knut Inge Grosland on 2015-05-09.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import Foundation
import SwiftyJSON

enum AppStoreReceiptStatusCode : Int {
    case Valid = 0                      //  "The receipt is Valid"
    case JSONInvalid = 21000            //  "The App Store could not read the JSON object you provided."
    case DataMalformed = 21002          //  "The data in the receipt-data property was malformed or missing."
    case AuthenticationFailure = 21003  //  "The receipt could not be authenticated."
    case ServerNotAvailable = 21005     //  "The receipt server is not currently available."
    case TestEnvironment = 21007        //  "This receipt is from the test environment, but it was sent to the production environment for verification. Send it to the test environment instead."
    case ProductionEnvironment = 21008  //  "This receipt is from the production environment, but it was sent to the test environment for verification. Send it to the production environment instead."
}

class InAppPurchaseItem {
    
    var productId : String?
    var transactionId : String?
    var purchaseDateMs : String?
    var originalPurchaseDateMs : String?
    var originalTransactionId : String?
    
    init(json : JSON) {
        self.productId = json.inAppPurchaseProductId
        self.transactionId = json.inAppPurchaseOriginalTransactionId
        self.purchaseDateMs = json.inAppPurchasePurchaseDateMs
        self.originalPurchaseDateMs = json.inAppPurchasePurchaseDateMs
        self.originalTransactionId = json.inAppPurchaseTransactionId
    }
}

class InAppPurchaseReceipt {
    
    var status : AppStoreReceiptStatusCode?
    var bundleId : String?
    var inAppPurchaseItems = [InAppPurchaseItem]()

    init(json : JSON) {
        if let status = json.purchaseStatus {
            self.status = AppStoreReceiptStatusCode(rawValue: status)
        }
        self.bundleId = json.purchaseBundleId
        
        for purchasedItemJSON in json.inAppPurchaseItems {
            let item = InAppPurchaseItem(json: purchasedItemJSON)
            inAppPurchaseItems.append(item)
        }
    }
}


// MARK: - JSON extension of InAppPurchaseItem

extension JSON {
    var purchaseStatus : Int? { get { return self["status"].int  } }
    var purchaseBundleId : String? { get { return self["receipt"]["bundle_id"].string  } }
    var inAppPurchaseItems : [JSON] { get { return self["receipt"]["in_app"].arrayValue  } }

}

extension JSON {
    var inAppPurchaseProductId : String? { get { return self["product_id"].string  } }
    var inAppPurchaseTransactionId : String? { get { return self["transaction_id"].string  } }
    var inAppPurchasePurchaseDateMs : String? { get { return self["purchase_date_ms"].string  } }
    var inAppPurchaseOriginalPurchaseDateMS : String? { get { return self["original_purchase_date_ms"].string  } }
    var inAppPurchaseOriginalTransactionId : String? { get { return self["original_transaction_id"].string  } }
}

