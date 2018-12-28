//
//  ImagePicker.swift
//  Integrations
//
//  Created by KiwiTech on 12/12/18.
//  Copyright © 2018 KiwiTech. All rights reserved.
//

import UIKit

public enum PickerType: String {
    case device,
    facebook,
    //instagram,
    twitter
}
open class ImagePicker: NSObject {
    fileprivate var config: ImagePickerConfiguration!
    public init(configurations: ImagePickerConfiguration) {
        self.config = configurations
    }
    public func show(on viewController: UIViewController, delegate: ImagePickerControllerDelegate, maxAllowedImages: Int = 10, minAllowedImages: Int = 1) {
        let imagePicker = ImagePickerController(type: config.type, delegate: delegate, config: self.config)
        imagePicker.maxAllowedImages = maxAllowedImages
        imagePicker.minAllowedImages = minAllowedImages
        let navCtrl = UINavigationController(rootViewController: imagePicker)
        viewController.present(navCtrl, animated: true, completion: nil)
    }
}
public struct ImagePickerConfiguration {
    public var type: PickerType = .device
    public var activityIndicatorColor: UIColor = .blue
    public var selectedImageBackgroundColor: UIColor = UIColor(red: 159.0/255.0, green: 245.0/255.0, blue: 255.0/255.0, alpha: 1)
    public var selectedImageCheckImage: UIImage? = UIImage(named: "check")
    public init(type: PickerType = .device, activityIndicatorColor: UIColor = .blue, selectedImageBackgroundColor: UIColor = UIColor(red: 159.0/255.0, green: 245.0/255.0, blue: 255.0/255.0, alpha: 1), selectedImageCheckImage: UIImage? = UIImage(named: "check")) {
        self.type = type
        self.activityIndicatorColor = activityIndicatorColor
        self.selectedImageBackgroundColor = selectedImageBackgroundColor
        self.selectedImageCheckImage = selectedImageCheckImage
    }
}
