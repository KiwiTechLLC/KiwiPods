//
//  HashTextView.swift
//  HashTextView
//
//  Created by Kiwitech on 03/02/18.
//  Copyright © 2018 Kiwitech. All rights reserved.
//

import UIKit

@objc public protocol HashTextViewDelegate {
    @objc optional func activeHashTag(textView : HashTextView!, hasTagString : String, hashRange : NSRange)
}

@IBDesignable public class HashTextView: UITextView {

    @IBInspectable public var hashBackgroundColor : UIColor = UIColor.blue {
        didSet {
            self.decorate(shouldCallDeleate: false)
        }
    }
    
    public var hashDelegate : HashTextViewDelegate? = nil
    
    override init(frame: CGRect, textContainer: NSTextContainer?)
    {
        super.init(frame: frame, textContainer: textContainer)
        self.setup()
    }
    
    convenience init(frame: CGRect)
    {
        self.init(frame: frame, textContainer: nil)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    override public func awakeFromNib()
    {
        super.awakeFromNib()
        self.setup()
    }
    
    func setup()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(self.textChanged), name: UITextView.textDidChangeNotification, object: nil)
    }
    
    @objc func textChanged()
    {
        print("Notification")
        
        self.decorate(shouldCallDeleate: true)
    }
    
    func decorate(shouldCallDeleate val : Bool)
    {
        let attrStrOptinal : NSAttributedString? = self.attributedText
        let attrStr = NSMutableAttributedString.init(attributedString: attrStrOptinal ?? NSAttributedString.init(string: self.text ?? ""))
        let searchPattern = "#\\w+"
        var ranges: [NSRange] = [NSRange]()
        
        let selectedRange = self.selectedRange
        var hashStr = ""
        var hashRange : NSRange? = nil
        
        let regex = try! NSRegularExpression(pattern: searchPattern, options: [])
        ranges = regex.matches(in: attrStr.string, options: [], range: NSMakeRange(0, attrStr.string.count)).map {$0.range}
        
        attrStr.addAttribute(NSAttributedString.Key.backgroundColor, value: self.backgroundColor ?? UIColor.clear, range: NSMakeRange(0, attrStr.string.count))
        
        //var found = false
        
        for range in ranges
        {
            attrStr.addAttribute(NSAttributedString.Key.backgroundColor, value: hashBackgroundColor, range: NSRange(location: range.location, length: range.length))
            
            if selectedRange.location > range.location && selectedRange.location <= (range.location + range.length)
            {
                //found = true
                hashRange = range
                hashStr = (attrStr.string as NSString).substring(with: range)
            }
        }
        
        if val
        {
            self.hashDelegate?.activeHashTag?(textView: self, hasTagString: hashStr, hashRange: hashRange ?? NSRange.init(location: -1, length: -1))
        }
        
        self.attributedText = attrStr
        self.selectedRange = selectedRange
    }
    
    deinit
    {
        NotificationCenter.default.removeObserver(self)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
