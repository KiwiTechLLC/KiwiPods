//
//  ImagePickerCell.swift
//  Integrations
//
//  Created by KiwiTech on 14/12/18.
//  Copyright © 2018 KiwiTech. All rights reserved.
//

import UIKit

class ImagePickerCell: UICollectionViewCell {

    @IBOutlet var imageView: UIImageView!
    @IBOutlet var checkMarkImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    open override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.imageView.transform = self.isSelected ? CGAffineTransform(scaleX: 0.9, y: 0.9) : CGAffineTransform.identity
                self.checkMarkImage.isHidden = !self.isSelected
            }
        }
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.sd_cancelCurrentImageLoad()
        self.imageView.image = nil
    }
}
