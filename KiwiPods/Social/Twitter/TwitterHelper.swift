//
//  TwitterHelper.swift
//  Integrations
//
//  Created by KiwiTech on 18/12/18.
//  Copyright © 2018 KiwiTech. All rights reserved.
//

import UIKit
import TwitterKit

struct TwitterPost: Codable {
    var id: Int
    var extended_entities: TwitterPostEntity?
    func allMediaUrls() -> [URL]? {
        let urls = extended_entities?.media?.compactMap({$0.media_url_https})
        return urls
    }
}
struct TwitterPostEntity: Codable {
    var media: [TwitterMedia]?
}
struct TwitterMedia: Codable {
    var media_url_https: URL?
}
class TwitterHelper: NSObject {
    fileprivate func checkLogin(completion: @escaping (Bool)-> Void)
    {
        if TWTRTwitter.sharedInstance().sessionStore.hasLoggedInUsers() {
            completion(true)
        } else {
            TWTRTwitter.sharedInstance().logIn { (session, error) in
                completion(error == nil ? true : false)
            }
        }
    }
    fileprivate var userId: String? {
         return TWTRTwitter.sharedInstance().sessionStore.session()?.userID
    }
    func getTwitterPhotos(page: Int, completion: @escaping ([TwitterPost]?, Error?) -> Void) {
        checkLogin { (success) in
            guard success == true else {
                completion(nil, TwitterResponseError.loginFailed)
                return
            }
            let client = TWTRAPIClient(userID: self.userId)
            let params = ["has": "images", "page": String(page)]
            let request = client.urlRequest(withMethod: "GET", urlString: "https://api.twitter.com/1.1/statuses/user_timeline.json", parameters: params, error: nil)
            client.sendTwitterRequest(request) { (response, data, error) in
                guard let httpResponse = response as? HTTPURLResponse,
                    (200...299).contains(httpResponse.statusCode) else {
                        completion(nil, TwitterResponseError.unacceptableStatusCode)
                        return
                }
                if let data = data
                {
//                    let str = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                    //print(str)
                    do {
                        let json = try JSONDecoder().decode([TwitterPost].self, from: data)
                        print(json)
                        completion(json, nil)
                    } catch(let error) {
                        print(error)
                        completion(nil, error)
                    }
                } else {
                    completion(nil, TwitterResponseError.noDataFound)
                }
            }
        }
        
    }
}
enum TwitterResponseError: Error {
    case unacceptableStatusCode,
    noDataFound,
    loginFailed
}
