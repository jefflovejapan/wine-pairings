//
//  ViewController.swift
//  wine-pairings
//
//  Created by Jeffrey Blagdon on 7/11/15.
//  Copyright (c) 2015 Jeffrey Blagdon. All rights reserved.
//

import UIKit

class LandingViewController: UIViewController {
    
    let wineColorButton = { UIButton.wineQuestionButton("Choose a color", answeredTitle:"Color chosen") }()
    
    let foodTypeButton = { UIButton.wineQuestionButton("Choose a food type", answeredTitle:"Food type chosen") }()
    
    let spicinessButton = { UIButton.wineQuestionButton("Is the food spicy?", answeredTitle:"Spiciness chosen") }()
    
    let seasoningButton = { UIButton.wineQuestionButton("Choose a seasoning", answeredTitle:"Seasoning chosen") }()
    
    var maybeButtons: [UIButton]?
    var maybeSpacers: [UIView]?
    
    //    MARK: View Controller life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let theButtons = [wineColorButton, foodTypeButton, spicinessButton, seasoningButton]
        let theSpacers = Array(0..<theButtons.count + 1).map{ Void in self.newSpacerView() }
        
        let prepAndAddToView = { (aView: UIView) -> Void in
            aView.setTranslatesAutoresizingMaskIntoConstraints(false)
            self.view.addSubview(aView)
        }
        
        [theButtons, theSpacers].map{ $0.map(prepAndAddToView) }
        self.maybeButtons = theButtons
        self.maybeSpacers = theSpacers
        view.setNeedsUpdateConstraints()
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
        if let spacers = self.maybeSpacers, buttons = self.maybeButtons {
            let equalHeightConstraints: [NSLayoutConstraint] = equalHeightConstraintsForButtons(buttons, spacers:spacers)
            let distributedPosConstraints: [NSLayoutConstraint] = distributedPosConstraintsForButtons(buttons, spacers:spacers)
            let centered = NSLayoutConstraint(item: spacers[0], attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
            var allConstraints = equalHeightConstraints + distributedPosConstraints
            allConstraints.append(centered)
            view.addConstraints(allConstraints)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //    MARK: Helper functions
    
    func distributedPosConstraintsForButtons(buttons: [UIButton], spacers:[UIView]) -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        if spacers.count <= 1 {
            return constraints
        }
        let spacerIndices = Array(0..<spacers.count)
        
        typealias optionalAnyObjToConstraints = [AnyObject]! -> [NSLayoutConstraint]
        
        let returnIfConstraints: optionalAnyObjToConstraints = { maybeConstraints -> [NSLayoutConstraint] in
            if let const = maybeConstraints as? [NSLayoutConstraint] {
                return const
            }
            return [NSLayoutConstraint]()
        }
        
        let nestedConstraintsArrays = spacerIndices.map{ index -> [NSLayoutConstraint] in
            if(index == 0) {
                let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[spcr][btn]", options: .AlignAllCenterX, metrics: nil, views: ["spcr": spacers[index], "btn": buttons[index]])
                return returnIfConstraints(vConstraints)
            } else if(index <= buttons.count - 1) {
                let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[lastBtn][spcr][btn]", options: .AlignAllCenterX, metrics: nil, views: ["spcr": spacers[index], "btn": buttons[index], "lastBtn": buttons[index - 1]])
                return returnIfConstraints(vConstraints)
            } else if(index == spacers.count - 1) {
                let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[lastBtn][spcr]|", options: .AlignAllCenterX, metrics: nil, views: ["lastBtn": buttons[index - 1], "spcr": spacers[index]])
                return returnIfConstraints(vConstraints)
            }
            return [NSLayoutConstraint]()
        }
        
        constraints += nestedConstraintsArrays.flatMap{ $0 }
        
        return constraints
    }
    
    func equalHeightConstraintsForButtons(buttons: [UIButton], spacers: [UIView]) -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        if spacers.count <= 1 {
            return constraints
        }
        
        let firstSpacers = spacers[0..<spacers.count - 1]
        let lastSpacers = spacers[1..<spacers.count]
        let zippedSpacers = Array(zip(firstSpacers, lastSpacers))
        
        let firstButtons = buttons[0..<buttons.count - 1]
        let lastButtons = buttons[1..<buttons.count]
        let zippedButtons = Array(zip(firstButtons, lastButtons))
        
        let setEqualHeightAndAlignX = { (view0: UIView, view1: UIView) -> [NSLayoutConstraint] in
            let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[view0(==view1)]", options: .AlignAllCenterX, metrics: nil, views: ["view0": view0, "view1": view1])
            if let constraints = vConstraints as? [NSLayoutConstraint] {
                return constraints
            }
            return [NSLayoutConstraint]()
        }
        
        constraints += zippedSpacers.map{ setEqualHeightAndAlignX($0.0, $0.1) }.flatMap{ $0 }
        constraints += zippedButtons.map{ setEqualHeightAndAlignX($0.0, $0.1) }.flatMap{ $0 }
        
        return constraints
    }
    
    func newSpacerView() -> UIView {
        let aView = UIView()
        aView.setTranslatesAutoresizingMaskIntoConstraints(false)
        return aView
    }
    
    
    
}

