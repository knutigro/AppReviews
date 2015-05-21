//
//  DonateButton.swift
//  App Reviews
//
//  Created by Knut Inge Grosland on 2015-05-20.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import AppKit
import WebKit

class DonateButton: WebView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        var error : NSError?
        
        if let path = NSBundle.mainBundle().pathForResource("DonateHTML", ofType: "") {
            if let string = NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: &error) as? String {
                self.mainFrame.loadHTMLString(string, baseURL: NSURL(string: "")!)
            }
        }
//        self.policyDelegate = self
    }
}

// MARK: WebPolicyDelegate

extension DonateButton {
    
    override func webView(webView: WebView!, decidePolicyForNavigationAction actionInformation: [NSObject : AnyObject]!, request: NSURLRequest!, frame: WebFrame!, decisionListener listener: WebPolicyDecisionListener!) {
        
        if actionInformation[WebActionElementKey] != nil {
            listener.ignore()
            if let url = request.URL {
                println(url.absoluteString)
                NSWorkspace.sharedWorkspace().openURL(url)
            }
        } else {
            listener.use()
        }
    }
}

