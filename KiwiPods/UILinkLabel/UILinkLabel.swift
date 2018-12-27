//
//  UILinkLabel.swift
//  UILinkLabel
//
//  Created by Kiwitech on 02/05/18.
//  Copyright © 2018 Kiwi. All rights reserved.
//

import UIKit

@IBDesignable public class UILinkLabel: UILabel {
    
    var urlClickBlock : ((_ urlRange : NSRange, _ linkText : String) -> Void)? = nil
    
    var linkRanges = [NSRange]()
    
    @IBInspectable public var linkColor : UIColor = UIColor.blue {
        didSet {
            self.setColorOnText()
        }
    }
    
    override public var text: String? {
        didSet {
            self.setAttributedString(attributedString: NSAttributedString(string: text ?? ""))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
    }
    
    init() {
        super.init(frame: CGRect.zero)
        
        self.setup()
    }
    
    func setColorOnText()
    {
        if let attr = self.attributedText
        {
            self.setAttributedString(attributedString: attr)
        }
        else if let txt = self.text
        {
            self.setAttributedString(attributedString: NSAttributedString(string: txt))
        }
    }
    
    func setup()
    {
        self.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.tapLabel(gesture:))))
        
        self.setColorOnText()
    }
    
    func setAttributedString(attributedString attributedStringVal : NSAttributedString)
    {
        let attrStr = NSMutableAttributedString.init(attributedString: attributedStringVal)
        let searchPattern = "(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"
        var ranges: [NSRange] = [NSRange]()
        
        let regex = try! NSRegularExpression(pattern: searchPattern, options: [])
        ranges = regex.matches(in: attrStr.string, options: [], range: NSMakeRange(0, attrStr.string.count)).map {$0.range}
        
        attrStr.addAttribute(NSAttributedString.Key.backgroundColor, value: self.backgroundColor ?? UIColor.clear, range: NSMakeRange(0, attrStr.string.count))
        
        //Add other attributes as well
        
        for range in ranges
        {
            attrStr.addAttribute(NSAttributedString.Key.backgroundColor, value: self.backgroundColor ?? UIColor.clear, range: NSRange(location: range.location, length: range.length))
            attrStr.addAttribute(NSAttributedString.Key.foregroundColor, value: linkColor, range: NSRange(location: range.location, length: range.length))
        }
        
        linkRanges = ranges
        
        self.attributedText = attrStr
    }
    
    @objc func tapLabel(gesture: UITapGestureRecognizer) {
        
        var foundRange : NSRange? = nil
        
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: self.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = self.lineBreakMode
        textContainer.maximumNumberOfLines = self.numberOfLines
        let labelSize = self.bounds.size
        textContainer.size = labelSize
        
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = gesture.location(in: self)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        
        let textContainerOffset = CGPoint.init(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        
        let locationOfTouchInTextContainer = CGPoint.init(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        
        for range in linkRanges
        {
            if NSLocationInRange(indexOfCharacter, range)
            {
                foundRange = range
                break
            }
        }
        
        if foundRange != nil && urlClickBlock != nil
        {
            urlClickBlock!(foundRange!, (self.attributedText?.attributedSubstring(from: foundRange!).string)!)
        }
    }
}
