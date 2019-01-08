//
//  ValidationsUtils.swift
//  Treble
//
//  Created by kiwitech on 03/02/17.
//  Copyright © 2016 KiwiTech. All rights reserved.
//

import UIKit

class ValidationsUtils: NSObject {
    //-----------------------------------------------
    // Mark  Email validation
    //-----------------------------------------------
    class func validateEmail(emailID: String) -> Bool {
       let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        // NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        let emailTest: NSPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with:
            emailID)
    }
    //-----------------------------------------------
    // Alpha - Numeric validation
    //-----------------------------------------------
    class func alphanumericValidation(validation: String) -> Bool {
        let alphanumericRegEx = "^[a-zA-Z0-9]+$"
        let alphanumericTest: NSPredicate = NSPredicate(format: "SELF MATCHES %@", alphanumericRegEx)
        return alphanumericTest.evaluate(with: validation)
    }
    //-----------------------------------------------
    // Mark  number validation
    //-----------------------------------------------
    class func onlyNumberValidation(number: String) -> Bool {
        let nameRegex: String = "^[0-9]+$"
        let nameTest: NSPredicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        return nameTest.evaluate(with: number)
    }
    //-----------------------------------------------
    // Mark  number validation
    //-----------------------------------------------
    class func onlyNumberValidationWithDash(number: String) -> Bool {
        let nameRegex: String = "^[0-9 '-]+$"
        let nameTest: NSPredicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        return nameTest.evaluate(with: number)
    }
    //-----------------------------------------------
    // Mark  enter only alphabets
    //-----------------------------------------------
    class func onlyAlphabetsValidation(alphabet: String) -> Bool {
        let nameRegex: String = "^[a-zA-Z '-]+$"
        ///^[a-zA-Z ]*$/
        let nameTest: NSPredicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        return nameTest.evaluate(with: alphabet)
       // return true
    }
    class func onlyAlphabetsWithSpaceValidation(alphabet: String) -> Bool {
        let nameRegex: String = "^[a-zA-Z ]+$"
        let nameTest: NSPredicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        return nameTest.evaluate(with: alphabet)
    }
    class func onlyAlphaNumericWithSpaceValidation(alphabet: String) -> Bool {
        let nameRegex: String = "^[a-zA-Z0-9 ]+$"
        let nameTest: NSPredicate = NSPredicate(format: "SELF MATCHES %@", nameRegex)
        return nameTest.evaluate(with: alphabet)
    }
    //-----------------------------------------------
    // Mark  mathch password 
    //-----------------------------------------------
    class func confirmationPasswordValidation(password: String, confirmationPassword: String) -> Bool {
        if password == confirmationPassword {
            return true
        } else {
            return false
        }
    }
    var tableSourceList: [[String]] = [[Int](0..<20).map({ "section 0, cell \($0)" })]
    class func contentView(text: String) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 375, height: 64))
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let label = UILabel(frame: view.bounds)
        label.frame.origin.x = 10
        label.frame.origin.y = 10
        label.frame.size.width -= label.frame.origin.x
        label.frame.size.height -= label.frame.origin.y
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.text = text
        label.numberOfLines = 2
        label.textColor = UIColor.white
        view.addSubview(label)
        return view
    }
    class func isEmpty(text: String) -> Bool {
        if text.trimmingCharacters(in: CharacterSet.whitespaces).isEmpty {
            return true
        }
        return false
    }
    class func trimeedCount(text: String) -> Int {
        
        return text.trimmingCharacters(in: CharacterSet.whitespaces).count
    }
    class func isValidCountPassword(passwordString: String) -> Bool {
        if passwordString.count >= 4 {
            return true
        }
        return false
    }
    class func isValidPassword(passwordString: String) -> Bool {
        if passwordString.count < 4 || passwordString.count > 24 {
            return false
        }
        return true
    }
    class func isValidUsername(usernameString: String) -> Bool {
        let stricterFilterString = "^([\\w&-]+)$"
        let usernameTest = NSPredicate(format: "SELF MATCHES %@", stricterFilterString)
        return usernameTest.evaluate(with: usernameString)
    }
    class func hasCharacterInString(string: String) -> Bool {
        let stricterFilterString = ".*[a-zA-Z]+.*"
        let stringTest = NSPredicate(format: "SELF MATCHES %@", stricterFilterString)
        return stringTest.evaluate(with: string)
    }
    class func isValidCountCharacterLimit(textString: String) -> Bool {
        if textString.count > 0 && textString.count <= 30 {
            return true
        }
        return false
    }

    class func isValidCountOfMobile(textString: String) -> Bool {
        if textString.count != 10 {
            return false
        }
        return true
    }
    class func isValidZipCode(textString: String) -> Bool {
        if textString.count != 5 {
            return false
        }
        return true
    }
    class func formatPhoneNumber(contactStr: String) -> String {
        let range = contactStr.range(of: contactStr)
        let strippedValue = contactStr.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression, range: range)
        var formattedString = ""
        if strippedValue.count == 0 {
            formattedString = ""
        } else if strippedValue.count < 3 {
            formattedString = strippedValue
        } else if strippedValue.count == 3 {
            formattedString = strippedValue
        } else if strippedValue.count < 6 {
            let startIndex = strippedValue.index(strippedValue.startIndex, offsetBy: 3)
            formattedString = "(" + String(strippedValue[...startIndex]) + ") " + String(strippedValue[startIndex...])
        } else if strippedValue.count == 6 {
            let startIndex = strippedValue.index(strippedValue.startIndex, offsetBy: 3)
            formattedString = "(" + String(strippedValue[...startIndex]) + ")  " + String(strippedValue[startIndex...]) + " - "
        } else if strippedValue.count <= 10 {
            //let startIndex = strippedValue.index(strippedValue.startIndex, offsetBy: 3)
//            formattedString = "(" + String(strippedValue[...startIndex]) + ") " + strippedValue.substring(with: NSMakeRange(0, contactStr.count)) + " - " + String(strippedValue[startIndex...])
        } else if strippedValue.count >= 11 {
        }
        return formattedString
    }
 }
