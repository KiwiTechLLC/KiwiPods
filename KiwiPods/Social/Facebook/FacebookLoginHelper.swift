//
//  FacebookLoginHelper.swift
//  
//
//  Created by KiwiTech on 17/07/2018.
//  Copyright © 2018 KiwiTech. All rights reserved.
//

import Foundation
import FBSDKLoginKit
import FBSDKCoreKit
public enum FacebookReadPermissions: String, CaseIterable {
    case userProfile = "public_profile"
    case email = "email"
    case birthday = "user_birthday"
    case gender = "user_gender",
    photos = "user_photos"
}
public enum FacebookPublishPermissions: String {
    case publishPages = "publish_pages"
}
public enum FacebookData: String, CaseIterable {
    case userId = "id"
    case userName =  "name"
    case userEmail = "email"
    case userProfilePic = "picture"
    case dateOfBirth = "birthday"
    case gender = "gender"
}

public enum FaceBookLoginResult {
    case success(loginResult: FaceBookLoginData)
    case error(message: String)
    case cancelled
}
public struct  FaceBookLoginData: Codable {
    var userId: String?
    var name: String?
    var email: String?
    var birthday: String?
    var gender: String?
    var picture: Picture?
    enum CodingKeys: String, Codable, CodingKey {
        case userId = "id"
        case name
        case email
        case birthday
        case gender
        case picture
    }
}
public struct FacebookUserImagesResponse: Codable {
    var data: [FacebookImageModel]?
    var paging: FacebookPageInfo?
    var hasNextPage: Bool {
        return paging?.next != nil
    }
}
public struct FacebookImageModel: Codable {
    var created_time: String
    var id: String
}
public struct FacebookImageResponse: Codable {
    var data: PictureData?
}
public struct  Picture: Codable {
    var data: PictureData?
    var paging: FacebookPageInfo?
}
public struct PictureData: Codable {
    var height: Int?
    var width: Int?
    var url: String?
    var picture: String?
    var images: [FacebookImageVariations]?
    var maxSizeImage: URL? {
        let sortedImagesBySize = images?.sorted(by: {($0.height*$0.width) > ($1.height*$1.width)})
        return sortedImagesBySize?.first?.source
    }
}
public struct FacebookImageVariations: Codable {
    var height: Int = 0
    var width: Int = 0
    var source: URL?
}
public struct FacebookPageInfo: Codable {
    var next: URL?
    var cursors: FacebookPageCursor?
}
public struct FacebookPageCursor: Codable {
    var before: String?
    var after: String?
}
final class FacebookLoginHelper {
    private var viewController: UIViewController?

    class func getCurrentAccessToken() -> String? {
        return FBSDKAccessToken.current()?.tokenString
    }
    public func checklogin(completion: ((Bool, Error?) -> Void)?) {
        if let _ = FBSDKAccessToken.current() {
            completion?(true, nil)
        } else {
            FBSDKLoginManager().logIn(withReadPermissions: FacebookReadPermissions.allCases.map{$0.rawValue}, from: viewController ?? UIViewController()) { (result, error) in
                if let error = error {
                    completion?(false, error)
                } else {
                    if let result = result, !result.isCancelled {
                        completion?(true, nil)
                    } else {
                        completion?(false, nil)
                    }
                }
            }
        }
    }
    public func getUserInfo(requestData: [String], completion: @escaping (_ result: FaceBookLoginData?, _ error: Error?) -> Void) {
        checklogin { (success, error) in
            if success {
                let graphRequest = FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": requestData.joined(separator: ",")])
                _ = graphRequest?.start(completionHandler: { (_, result, error) in
                    if let result = result, let deocdedData = try? JSONSerialization.data(withJSONObject: result, options: JSONSerialization.WritingOptions.prettyPrinted) {
                        do {
                            let fbloginData: FaceBookLoginData = try JSONDecoder().decode(FaceBookLoginData.self, from: deocdedData)
                            completion(fbloginData, error)
                        } catch {
                            completion(nil, error)
                        }
                    } else {
                        completion(nil, error)
                    }
                })
            } else {
                completion(nil, error)
            }
        }
    }
    public func fetchUserPhotos(after: String? = nil, completion: @escaping (_ result: FacebookUserImagesResponse?, _ error: Error?) -> Void) {
        checklogin { (success, error) in
            var params = ["type":"uploaded"]
            if let after = after {
                params["after"] = after
            }
            let graphRequest = FBSDKGraphRequest(graphPath: "me/photos", parameters: params)
            _ = graphRequest?.start(completionHandler: { (_, result, error) in
                if let result = result, let deocdedData = try? JSONSerialization.data(withJSONObject: result, options: JSONSerialization.WritingOptions.prettyPrinted) {
                    do {
                        let fbloginData: FacebookUserImagesResponse = try JSONDecoder().decode(FacebookUserImagesResponse.self, from: deocdedData)
                        completion(fbloginData, error)
                    } catch {
                        completion(nil, error)
                    }
                } else {
                    completion(nil, error)
                }
            })
        }
    }
    public func getFacebookImageDetails(imageId: String, completion: @escaping (PictureData?, Error?) -> Void) {
        checklogin { (success, error) in
            if success {
                //to be used -- 108566810189028?fields=height,width,images,picture
                //108566810189028/picture?type=normal
                let graphRequest = FBSDKGraphRequest(graphPath: "\(imageId)", parameters: ["fields":"height,width,images,picture"])
                _ = graphRequest?.start(completionHandler: { (_, result, error) in
                    if let result = result, let deocdedData = try? JSONSerialization.data(withJSONObject: result, options: JSONSerialization.WritingOptions.prettyPrinted) {
                        do {
                            let fbloginData: PictureData = try JSONDecoder().decode(PictureData.self, from: deocdedData)
                            completion(fbloginData, error)
                        } catch {
                            completion(nil, error)
                        }
                    } else {
                        completion(nil, error)
                    }
                })
            }
        }
    }
    deinit {
        print("Facebook Helper deinit called")
    }
}
