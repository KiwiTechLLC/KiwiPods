//
//  TwitterHandler.swift
//  Integrations
//
//  Created by KiwiTech on 18/12/18.
//  Copyright © 2018 KiwiTech. All rights reserved.
//

import UIKit

open class TwitterHandler: NSObject {
    fileprivate var currentPage: Int = 1
    fileprivate var mayHaveNextPage = true
    public func getPhotos(completion: @escaping ([URL]?, Error?) -> Void) {
        guard mayHaveNextPage else {
            completion(nil, nil)
            return
        }
        TwitterHelper().getTwitterPhotos(page: currentPage) { (posts, error) in
            if error == nil {
                self.currentPage += 1
                self.mayHaveNextPage = (posts?.count ?? 0 > 0)
                let allUrls = posts?.compactMap({$0.allMediaUrls()})
                let urls = allUrls?.reduce([], +)
                completion(urls, error)
            } else {
                completion(nil, error)
            }
        }
    }
}
