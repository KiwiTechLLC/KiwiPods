//
//  FacebookHandler.swift
//  
//
//  Created by KiwiTech on 12/12/18.
//  Copyright © 2018 KiwiTech. All rights reserved.
//

import UIKit

open class FacebookHandler: NSObject {
    fileprivate var facebookImageResponsePage: FacebookPageInfo?
    public func getFacebookPhotos(controller: UIViewController, completion: @escaping (_ result: FacebookUserImagesResponse?, _ error: Error?) -> Void) {
        if facebookImageResponsePage != nil, facebookImageResponsePage?.next == nil {
            completion(nil, nil)
            return
        }
        FacebookLoginHelper().fetchUserPhotos(after: facebookImageResponsePage?.cursors?.after ,completion: { (response, error) in
            self.facebookImageResponsePage = response?.paging
            completion(response, error)
        })
        
    }
    public func getFacebookUserToken(controller: UIViewController, completion: @escaping (String?, Error?) -> Void) {
        FacebookLoginHelper().checklogin { (success, error) in
            if success {
                let token = FacebookLoginHelper.getCurrentAccessToken()
                completion(token, nil)
            } else {
                completion(nil, error)
            }
        }
    }
    public func getFacebookUserInfo(controller: UIViewController, completion: @escaping (_ result: FaceBookLoginData?, _ error: Error?) -> Void) {
        FacebookLoginHelper().getUserInfo(requestData: ["email"]) { (result, error) in
            completion(result, error)
        }
    }
    fileprivate static var imageUrls = [String: String]()
    fileprivate static var queuedUrls = [String]()
    public func imageUrlFrom(model: FacebookImageModel, completion: @escaping (String?, Error?) -> Void)
    {
        //dont hit request for already requested id
        guard FacebookHandler.queuedUrls.contains(model.id) == false else{
            completion(nil, nil)
            return
        }
        //once url is found dont ask for url again
        if let url = FacebookHandler.imageUrls[model.id] {
            completion(url, nil)
        } else {

        FacebookLoginHelper().getFacebookImageDetails(imageId: model.id, completion: { (response, error) in
            FacebookHandler.queuedUrls.removeAll(where: {$0 == model.id})
                if error == nil, let response = response {
                    FacebookHandler.imageUrls[model.id] = response.maxSizeImage?.absoluteString
                    completion(response.maxSizeImage?.absoluteString, nil)
                } else {
                    completion(nil, error)
                }
            })
        }
    }
}
