//
//  ImagePickerController.swift
//  Integrations
//
//  Created by KiwiTech on 14/12/18.
//  Copyright © 2018 KiwiTech. All rights reserved.
//

import UIKit
import SDWebImage
import MBProgressHUD
enum ImagePickerValidationError {
    /// When user tap on done without selecting `minAllowedImages`
    case minItemNotSelected
    /// When user tap on item that is exceeds the `maxAllowedImages`
    case maxItemSelectionLimitExceeded
}
protocol ImagePickerControllerDelegate {
    func imagePickerDidCancel(picker: ImagePickerController)
    func imagePicker(picker: ImagePickerController, finishedPickingImages images: [UIImage])
    func imagePicker(picker: ImagePickerController, failedWithError: ImagePickerValidationError)
}
class ImagePickerController: UIViewController {

    @IBOutlet fileprivate var collectionView: UICollectionView!
    var maxAllowedImages: Int = 10
    var minAllowedImages: Int = 1
    var type: PickerType = .device
    var delegate: ImagePickerControllerDelegate?
    fileprivate var fetchingPhotos: Bool {
        return fetchingFacebookPhotos || isFetchingTwitterPosts
    }
    fileprivate var imageAryCount: Int {
        return devicePhotos?.count ?? facebookImages?.count ?? twitterPosts?.count ?? 0
    }
    var configurations: ImagePickerConfiguration!
    init(type: PickerType, delegate: ImagePickerControllerDelegate?, maxAllowedImages: Int? = nil, minAllowedImages: Int? = nil, config: ImagePickerConfiguration) {
        self.type = type
        self.delegate = delegate
        self.configurations = config
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(UINib(nibName: "ImagePickerCell", bundle: nil), forCellWithReuseIdentifier: "ImagePickerCell")
        collectionView.register(UINib(nibName: "LoadingCell", bundle: nil), forCellWithReuseIdentifier: "LoadingCell")
        collectionView.allowsMultipleSelection = true
        showNavBarButtons()
        switch type {
        case .facebook:
            getFacebookPhotos()
        case .twitter:
            getTwitterPhotos()
            break
        case .device:
            getDeviceImages()
        }
        
    }
    fileprivate var doneBtn: UIBarButtonItem!
    fileprivate var cancelBtn: UIBarButtonItem!
    
    fileprivate func showNavBarButtons() {
        doneBtn = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(doneTapped))
        cancelBtn = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(cancelTapped))
        self.navigationItem.rightBarButtonItem = doneBtn
        self.navigationItem.leftBarButtonItem = cancelBtn
    }
    @objc fileprivate func doneTapped() {
        provideSelectedImages()
    }
    @objc fileprivate func cancelTapped() {
        delegate?.imagePickerDidCancel(picker: self)
    }
    fileprivate var facebookImages: [FacebookImageModel]?
    fileprivate var fetchingFacebookPhotos = false {
        didSet {
            collectionView.reloadData()
        }
    }
    fileprivate let facebookHelper = FacebookHandler()
    fileprivate func getFacebookPhotos() {
        guard fetchingFacebookPhotos == false else {
            return
        }
//        let loadindingHUD = MBProgressHUD(for: self.view)
//        loadindingHUD?.animationType = MBProgressHUDAnimation.zoomIn
//        loadindingHUD?.show(animated: true)
//        MBProgressHUD.showAdded(to: self.view, animated: true)
        fetchingFacebookPhotos = true
        facebookHelper.getFacebookPhotos(controller: self) { (response, error) in
//            loadindingHUD?.hide(animated: true)
//            MBProgressHUD.hide(for: self.view, animated: true)
            if error == nil {
                if let responseData = response?.data, responseData.count > 0 {
                    if var images = self.facebookImages, images.count > 0 {
                        images += responseData
                        self.facebookImages = images
                    } else {
                        self.facebookImages = response?.data
                    }
                }
                self.collectionView.reloadData()
            } else if let error = error {
                let alert = UIAlertController(title: "", message: error.localizedDescription, preferredStyle: .alert)
                let okBtn = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okBtn)
                self.present(alert, animated: true, completion: nil)
            }
            self.fetchingFacebookPhotos = false
        }
    }
    fileprivate var twitterPosts: [URL]?
    fileprivate var twitterHandler = TwitterHandler()
    fileprivate var isFetchingTwitterPosts = false {
        didSet {
            collectionView.reloadData()
        }
    }
    fileprivate func getTwitterPhotos() {
        guard isFetchingTwitterPosts == false else {
            return
        }
        isFetchingTwitterPosts = true
        twitterHandler.getPhotos { (posts, error) in
            if error == nil {
                if var images = self.twitterPosts, images.count > 0 {
                    images += posts ?? []
                    self.twitterPosts = images
                } else {
                    self.twitterPosts = posts
                }
                self.collectionView.reloadData()
            } else if let error = error {
                let alert = UIAlertController(title: "", message: error.localizedDescription, preferredStyle: .alert)
                let okBtn = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okBtn)
                self.present(alert, animated: true, completion: nil)
            }
            self.isFetchingTwitterPosts = false
        }
    }
    fileprivate var devicePhotos: [UIImage]?
    fileprivate func getDeviceImages() {
        DeviceMediaHandler().getImages { (assetCollection, images, error) in
            if let images = images {
                self.devicePhotos = images
                self.collectionView.reloadData()
            } else if let error = error {
                let alert = UIAlertController(title: "", message: error.localizedDescription, preferredStyle: .alert)
                let okBtn = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(okBtn)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    fileprivate func provideSelectedImages() {
        guard let selectedIndexes = collectionView.indexPathsForSelectedItems, selectedIndexes.count >= minAllowedImages else {
            delegate?.imagePicker(picker: self, failedWithError: .minItemNotSelected)
            return
        }
        switch type {
        case .facebook:
            facebookImages(at: selectedIndexes)
        case .device:
            deviceImages(at: selectedIndexes)
        case .twitter:
            twitterImages(at: selectedIndexes)
        default:
            break
        }
        
    }
    fileprivate func facebookImages(at indexes: [IndexPath]) {
        guard let facebookImages = facebookImages else {
            return
        }
        let loadindingHUD = MBProgressHUD(for: self.view)
        loadindingHUD?.animationType = MBProgressHUDAnimation.zoomIn
        loadindingHUD?.show(animated: true)
        var selectedModels = [FacebookImageModel]()
        for index in indexes {
            let model = facebookImages[index.row]
            selectedModels.append(model)
        }
        let group = DispatchGroup()
        let bgQueue = DispatchQueue(label: "facebookImageDownload")
        var imagesAry = [UIImage]()
        bgQueue.async {
            for model in selectedModels {
                group.enter()
                let helper = FacebookHandler()
                helper.imageUrlFrom(model: model, completion: { (url, error) in
                    guard let urlStr = url else {
                        group.leave()
                        return
                    }
                    if let image = SDImageCache.shared().imageFromCache(forKey: urlStr) {
                        imagesAry.append(image)
                    } else if let url = URL(string: urlStr) {
                        if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                            imagesAry.append(image)
                        }
                    }
                    group.leave()
                })
            }
        }
        group.notify(queue: DispatchQueue.main) {
            loadindingHUD?.hide(animated: true)
            self.delegate?.imagePicker(picker: self, finishedPickingImages: imagesAry)
        }
    }
    fileprivate func deviceImages(at indexPaths: [IndexPath]) {
        var imageAry = [UIImage]()
        for indexPath in indexPaths {
            if let image = devicePhotos?[indexPath.row] {
                imageAry.append(image)
            }
        }
        delegate?.imagePicker(picker: self, finishedPickingImages: imageAry)
    }
    fileprivate func twitterImages(at indexPaths: [IndexPath]) {
        guard let twitterImages = twitterPosts else {
            return
        }
        var images = [UIImage]()
        let group = DispatchGroup()
        let queue = DispatchQueue(label: "TwitterImageDownload")
        for indexPath in indexPaths {
            group.enter()
            let url = twitterImages[indexPath.row]
            if let image = SDImageCache.shared().imageFromCache(forKey: url.absoluteString) {
                images.append(image)
                group.leave()
            } else {
                queue.async {
                    if let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
                        images.append(image)
                        group.leave()
                    } else {
                        group.leave()
                    }
                }
            }
        }
        group.notify(queue: .main) {
            self.delegate?.imagePicker(picker: self, finishedPickingImages: images)
        }
    }
}
extension ImagePickerController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0
        switch type {
        case .facebook:
            count = facebookImages?.count ?? 0
        case .twitter:
            count = twitterPosts?.count ?? 0
        case .device:
            count = devicePhotos?.count ?? 0
        }
        if fetchingPhotos {
            count += 1
        }
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row < imageAryCount {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImagePickerCell", for: indexPath) as! ImagePickerCell
            switch type {
            case .facebook:
                showFacebookImage(on: cell, indexPath: indexPath)
            case .twitter:
                showTwitterImage(on: cell, indexPath: indexPath)
            case .device:
                showDeviceImage(on: cell, indexPath: indexPath)
            }
            cell.backgroundColor = configurations.selectedImageBackgroundColor
            cell.checkMarkImage.image = configurations.selectedImageCheckImage
            return cell
        } else {
            let loadingCell = collectionView.dequeueReusableCell(withReuseIdentifier: "LoadingCell", for: indexPath) as! LoadingCell
            !loadingCell.activityIndicator.isAnimating ?  loadingCell.activityIndicator.startAnimating() : ()
            loadingCell.activityIndicator.color = configurations.activityIndicatorColor
            return loadingCell
        }
    }
}
extension ImagePickerController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard indexPath.row < imageAryCount else {
            return false
        }
        if (collectionView.indexPathsForSelectedItems?.count ?? 0) < maxAllowedImages {
            return true
        }
        delegate?.imagePicker(picker: self, failedWithError: .maxItemSelectionLimitExceeded)
        return false
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
fileprivate extension ImagePickerController {
    func showFacebookImage(on cell: ImagePickerCell, indexPath: IndexPath) {
        if let model = facebookImages?[indexPath.row] {
            let helper = FacebookHandler()
            helper.imageUrlFrom(model: model, completion: { (url, error) in
                if let url = url {
                    cell.imageView!.sd_setImage(with: URL(string: url), completed: nil)
                }
            })
        }
    }
    func showTwitterImage(on cell: ImagePickerCell, indexPath: IndexPath) {
        if let url = twitterPosts?[indexPath.row] {
            cell.imageView!.sd_setImage(with: url, completed: nil)
        }
    }
    func showDeviceImage(on cell: ImagePickerCell, indexPath: IndexPath) {
        if let image = devicePhotos?[indexPath.row] {
            cell.imageView.image = image
        }
    }
}
extension ImagePickerController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row < imageAryCount {
            return CGSize(width: (UIScreen.main.bounds.width/3)-3, height: (UIScreen.main.bounds.width/3)-3)
        } else {
            return CGSize(width: UIScreen.main.bounds.width, height: 44)
        }
    }
}
extension ImagePickerController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let fiftyPercent = (scrollView.contentSize.height*50) / 100.0
        if scrollView.bounds.maxY > fiftyPercent {
            if type == .facebook {
                getFacebookPhotos()
            } else if type == .twitter {
                getTwitterPhotos()
            }
            
        }
    }
}
