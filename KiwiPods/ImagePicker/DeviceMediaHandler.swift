//
//  DeviceMediaHandler.swift
//  Integrations
//
//  Created by KiwiTech on 19/12/18.
//  Copyright © 2018 KiwiTech. All rights reserved.
//

import UIKit
import Photos
public enum DeviceImageSize {
    case thumb(CGSize?),
    original
    var size: CGSize {
        switch self {
        case .thumb(let size):
            return size ?? CGSize(width: 100, height: 100)
        case .original:
            return PHImageManagerMaximumSize
        }
    }
}
open class DeviceMediaHandler: NSObject {
    public func getImages(with size: DeviceImageSize = .thumb(nil), completion: @escaping (PHFetchResult<PHAsset>?, [UIImage]?, Error?) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                let fetchOptions = PHFetchOptions()
                let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                print("Found \(allPhotos.count) assets")
                self.getImage(from: allPhotos, for: size.size, completion: { (images) in
                    completion(allPhotos, images, nil)
                })
            case .denied, .restricted:
                print("Not allowed")
                completion(nil, nil, ImageGetchError.accessNotAvailable)
            case .notDetermined:
                // Should not see this when requesting
                print("Not determined yet")
                completion(nil, nil, ImageGetchError.accessNotDetermined)
            }
        }
    }
    public func getImage(from photos: PHFetchResult<PHAsset>,for  size: CGSize, completion: @escaping ([UIImage]) -> Void) {
        let queue = DispatchQueue(label: "imageThumbGeneration")
        queue.async {
            var thumbImages = [UIImage]()
            let manager = PHImageManager()
            photos.enumerateObjects { (asset, index, stop) in
                manager.requestImage(for: asset, targetSize: size, contentMode: PHImageContentMode.default, options: nil, resultHandler: { (image, options) in
                    if let image = image {
                        thumbImages.append(image)
                    }
                })
            }
            DispatchQueue.main.async {
                completion(thumbImages)
            }
        }
    }
}
public enum ImageGetchError: Error {
    case accessNotAvailable,
    accessNotDetermined
}
