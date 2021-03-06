//
//  NSImageView+Networking.swift
//  App Reviews
//
//  Created by Knut Inge Grosland on 2015-04-13.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import AppKit

protocol AFImageCacheProtocol:class{
    func cachedImageForRequest(request:NSURLRequest) -> NSImage?
    func cacheImage(image:NSImage, forRequest request:NSURLRequest);
}

extension NSImageView {
    private struct AssociatedKeys {
        static var SharedImageCache = "SharedImageCache"
        static var RequestImageOperation = "RequestImageOperation"
        static var URLRequestImage = "UrlRequestImage"
    }
    
    class func setSharedImageCache(cache:AFImageCacheProtocol?) {
        objc_setAssociatedObject(self, &AssociatedKeys.SharedImageCache, cache, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
    }
    
    class func sharedImageCache() -> AFImageCacheProtocol {
        struct Static {
            static var token: dispatch_once_t = 0
            static var defaultImageCache:AFImageCache?
        }
        dispatch_once(&Static.token, { () -> Void in
            Static.defaultImageCache = AFImageCache()
        })
        return objc_getAssociatedObject(self, &AssociatedKeys.SharedImageCache) as? AFImageCache ?? Static.defaultImageCache!
    }
    
    class func af_sharedImageRequestOperationQueue() -> NSOperationQueue {
        struct Static {
            static var token:dispatch_once_t = 0
            static var queue:NSOperationQueue?
        }
        
        dispatch_once(&Static.token, { () -> Void in
            Static.queue = NSOperationQueue()
            Static.queue!.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount
        })
        return Static.queue!
    }
    
    private var af_requestImageOperation:(operation:NSOperation?, request: NSURLRequest?) {
        get {
            let operation:NSOperation? = objc_getAssociatedObject(self, &AssociatedKeys.RequestImageOperation) as? NSOperation
            let request:NSURLRequest? = objc_getAssociatedObject(self, &AssociatedKeys.URLRequestImage) as? NSURLRequest
            return (operation, request)
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.RequestImageOperation, newValue.operation, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            objc_setAssociatedObject(self, &AssociatedKeys.URLRequestImage, newValue.request, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func setImageWithUrl(url:NSURL, placeHolderImage:NSImage? = nil) {
        let request:NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.addValue("image/*", forHTTPHeaderField: "Accept")
        setImageWithUrlRequest(request, placeHolderImage: placeHolderImage, success: nil, failure: nil)
    }
    
    func setImageWithUrlRequest(request:NSURLRequest, placeHolderImage:NSImage? = nil,
        success:((request:NSURLRequest?, response:NSURLResponse?, image:NSImage) -> Void)?,
        failure:((request:NSURLRequest?, response:NSURLResponse?, error:NSError) -> Void)?)
    {
        cancelImageRequestOperation()
        
        if let cachedImage = NSImageView.sharedImageCache().cachedImageForRequest(request) {
            if success != nil {
                success!(request: nil, response:nil, image: cachedImage)
            }
            else {
                image = cachedImage
            }
            
            return
        }
        
        if placeHolderImage != nil {
            image = placeHolderImage
        }
        
        af_requestImageOperation = (NSBlockOperation(block: { () -> Void in
            var response:NSURLResponse?
            var error:NSError?
            let data: NSData?
            do {
                data = try NSURLConnection.sendSynchronousRequest(request, returningResponse: &response)
            } catch let error1 as NSError {
                error = error1
                data = nil
            } catch {
                fatalError()
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if request.URL!.isEqual(self.af_requestImageOperation.request?.URL) {
                    let image:NSImage? = (data != nil ? NSImage(data: data!): nil)
                    if image != nil {
                        if success != nil {
                            success!(request: request, response: response, image: image!)
                        }
                        else {
                            self.image = image!
                        }
                    }
                    else {
                        if failure != nil {
                            failure!(request: request, response:response, error: error!)
                        }
                    }
                    
                    self.af_requestImageOperation = (nil, nil)
                }
            })
        }), request)
        
        NSImageView.af_sharedImageRequestOperationQueue().addOperation(af_requestImageOperation.operation!)
    }
    
    private func cancelImageRequestOperation() {
        af_requestImageOperation.operation?.cancel()
        af_requestImageOperation = (nil, nil)
    }
}

func AFImageCacheKeyFromURLRequest(request:NSURLRequest) -> String {
    return request.URL!.absoluteString
}

class AFImageCache: NSCache, AFImageCacheProtocol {
    func cachedImageForRequest(request: NSURLRequest) -> NSImage? {
        switch request.cachePolicy {
        case NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
        NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData:
            return nil
        default:
            break
        }
        
        return objectForKey(AFImageCacheKeyFromURLRequest(request)) as? NSImage
    }
    
    func cacheImage(image: NSImage, forRequest request: NSURLRequest) {
        setObject(image, forKey: AFImageCacheKeyFromURLRequest(request))
    }
}