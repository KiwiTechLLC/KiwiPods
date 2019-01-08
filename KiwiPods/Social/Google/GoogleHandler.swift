//
//  GoogleHandler.swift
//  
//
//  Created by KiwiTech on 07/01/19.
//  Copyright © 2019 KiwiTech. All rights reserved.
//

import UIKit
import GoogleSignIn
open class GoogleHandler: NSObject {
    static public let `shared` = GoogleHandler()
    override private init() {
        super.init()
        GIDSignIn.sharedInstance()?.delegate = self
    }
    fileprivate var loginCompletion: ((String?, Error?) -> Void)?
    fileprivate var loginHandlerController: UIViewController?
    public func getUser(from controller: UIViewController, completion: @escaping (_ token: String?, _ error: Error?) -> Void) {
        if let user = GIDSignIn.sharedInstance()?.currentUser {
            loginCompletion = nil
            completion(user.authentication.idToken, nil)
        } else {
            loginCompletion = completion
            loginHandlerController = controller
            GIDSignIn.sharedInstance()?.uiDelegate = self
            GIDSignIn.sharedInstance()?.signIn()
        }
    }
}
extension GoogleHandler: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else {
            loginCompletion?(nil, error)
            return
        }
        loginCompletion?(user.authentication.idToken, nil)
    }
}
extension GoogleHandler: GIDSignInUIDelegate {
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        guard let controller = loginHandlerController else {
            return
        }
        controller.present(viewController, animated: true, completion: nil)
    }
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        viewController.dismiss(animated: true, completion: nil)
    }
}
