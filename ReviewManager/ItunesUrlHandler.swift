//
//  ItunesUrlHandler.swift
//  App Reviews
//
//  Created by Knut Inge Grosland on 2015-05-10.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import Foundation
import SwiftyJSON

class ItunesPage {
    
    var page: Int
    var url: String
    var nextUrl: String?
    
    init(url: String, page: Int) {
        self.url = url;
        self.page = page;
    }
    
    convenience init(url: String, page: Int, json: [JSON]) {
        self.init(url: url, page: page)
        for jsonLink in json {
            let attributes = jsonLink["attributes"]
            
            if attributes["rel"].stringValue == "next" {
                nextUrl = attributes["href"].string?.stringByRemovingItunesFormatting()
            }
            
            // We dont get a valid next url , try to create one from the previous
            if nextUrl == nil && url.containPage() {
                if let nextUrl = ItunesPage.urlByIncreasingPage(url, page: page) {
                    self.nextUrl = nextUrl.url
                }
            }
        }
    }

    func isEqualPage(page: ItunesPage) -> Bool {
        return self.page == page.page
    }
    
    class func urlByIncreasingPage(urlString: String?, page: Int?) -> (url: String, page: Int)?  {
        if let urlstring = urlString, let page = page {
            if let _ = NSURL(string: urlstring) {
                let old = String(format: "page=%i", page)
                let next = String(format: "page=%i", page + 1)
                return (urlstring.stringByReplacingOccurrencesOfString(old, withString: next), page + 1)
            }
        }
        
        return nil
    }
}

class ItunesUrlHandler {

    private var storeId: String?
    private var apId: String

    var nextUrl: String? {
        return pages.last?.nextUrl
    }
    
    var initialUrl: String {
        let storePath = storeId != nil ? ("/" + self.storeId!): ""
        return "https://itunes.apple.com" +  storePath + "/rss/customerreviews/id=" + self.apId + "/json"
    }
    
    var pages = [ItunesPage]()
    
    init(apId: String, storeId: String?) {
        self.apId = apId
        self.storeId = storeId
        pages.append(ItunesPage(url: initialUrl, page: 0))
    }
    
    func updateWithJSON(json: [JSON]) {
        if let previousPage = pages.last {
            let newPage = ItunesPage(url: previousPage.url, page: previousPage.page + 1, json: json)
            if isNewPage(newPage) {
                pages.append(newPage)
            }
        }
    }
    
    func isNewPage(newPage: ItunesPage) -> Bool {
        for page in pages {
            if page.isEqualPage(newPage) {
                return false;
            }
        }
        return true
    }
}

// MARK: ItunesUrlHandler

extension String {
    func stringByRemovingDoubleSlashes() -> String {
        return stringByReplacingOccurrencesOfString("\\/", withString: "/")
    }
    
    func stringByRemovingItunesFormatting() -> String {
        let temp =  stringByRemovingDoubleSlashes()
        if let url = NSURL(string: temp) {
            if let pathComponents = url.pathComponents {
                var newUrlString = ""
                var newPathSet = Set<String>()
                
                for path in pathComponents {
                    let isXML = path == "xml?urlDesc="
                    
                    if !newPathSet.contains(path) && !isXML {
                        if newPathSet.isEmpty {
                            newUrlString = newUrlString.stringByAppendingString(path)
                        } else if newPathSet.count == 1 {
                            newUrlString = newUrlString.stringByAppendingFormat("//%@", path)
                        } else {
                            newUrlString = newUrlString.stringByAppendingFormat("/%@", path)
                        }
                        newPathSet.insert(path)
                    }
                }
                return newUrlString
            }
        }
        return temp
    }

    func containPage() -> Bool {
        return page() != nil;
    }
    
    func page() -> Int? {
        if let url = NSURL(string: self) {
            if let pathComponents = url.pathComponents {
                for path in pathComponents {
                    if path.rangeOfString("page=") != nil {
                        let page = path.stringByReplacingOccurrencesOfString("page=", withString: "")
                        return Int(page)
                    }
                }
            }
        }
        return nil
    }
    
}
