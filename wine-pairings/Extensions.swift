//
//  Extensions.swift
//  wine-pairings
//
//  Created by Jeffrey Blagdon on 7/11/15.
//  Copyright (c) 2015 Jeffrey Blagdon. All rights reserved.
//

import UIKit

extension UIButton {
    enum ButtonImage: String {
        case BlueBackgroundImage = "button-blue-bg"
        case GreenBackgroundImage = "button-green-bg"
    }
    
    class func wineQuestionButton(unansweredTitle:String, answeredTitle: String) -> UIButton {
        let newButton: UIButton = UIButton.buttonWithType(.Custom) as! UIButton
        if let blueImg = UIImage(named: ButtonImage.BlueBackgroundImage.rawValue), greenImg = UIImage(named: ButtonImage.GreenBackgroundImage.rawValue) {
            newButton.setBackgroundImage(blueImg, forState: .Normal)
            newButton.setBackgroundImage(greenImg, forState: .Selected)
        }
        newButton.setTitle(unansweredTitle, forState: .Normal)
        newButton.setTitle(answeredTitle, forState: .Selected)
        return newButton
    }
}

