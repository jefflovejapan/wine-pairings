//
//  ViewController.swift
//  wine-pairings
//
//  Created by Jeffrey Blagdon on 7/11/15.
//  Copyright (c) 2015 Jeffrey Blagdon. All rights reserved.
//

import UIKit
import CoreData

class LandingViewController: UIViewController {
    
    let foodTypeButton = { UIButton.wineQuestionButton("What kind of food are you eating?", answeredTitle:"Food type selected") }()
    let foodTypeLabel = { UILabel.wineAnswerLabel() }()
    
    let spicinessButton = { UIButton.wineQuestionButton("Is it spicy?", answeredTitle:"Spiciness selected") }()
    let spicinessLabel = { UILabel.wineAnswerLabel() }()
    
    let seasoningButton = { UIButton.wineQuestionButton("How is the food seasoned?", answeredTitle:"Seasoning selected") }()
    let seasoningLabel = { UILabel.wineAnswerLabel() }()
    
    let buttonBox = { UIView() }()
    
    var maybeButtons: [UIButton]?
    var maybeLabels: [UILabel]?
    var maybeSpacers: [UIView]?
    var maybeContext: NSManagedObjectContext?
    var maybeVarietals: [Varietal]?
    
    //    MARK: View Controller life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let theButtons = [foodTypeButton, spicinessButton, seasoningButton]
        theButtons.map{ $0.addTarget(self, action:"wineButtonTapped:", forControlEvents: .TouchUpInside ) }
        let theSpacers = Array(0..<theButtons.count + 1).map{ Void in self.newSpacerView() }
        let theLabels = [foodTypeLabel, spicinessLabel, seasoningLabel]
        buttonBox.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(buttonBox)
        
        [theButtons, theSpacers, theLabels].flatMap{ $0 }.map{ self.buttonBox.addSubview($0) }
        maybeButtons = theButtons
        maybeSpacers = theSpacers
        maybeLabels = theLabels
        view.setNeedsUpdateConstraints()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if(self.maybeVarietals == nil) {
            if let context = self.maybeContext {
                self.maybeVarietals = allVarietalsFromContext(context)
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        println(self.maybeVarietals)
    }
    
    override func updateViewConstraints() {
        var boxConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[tlg][box]|", options: .allZeros, metrics: nil, views: ["tlg": topLayoutGuide, "box": buttonBox])
        boxConstraints += NSLayoutConstraint.constraintsWithVisualFormat("|[box]|", options: .allZeros, metrics: nil, views: ["box": buttonBox])
        view.addConstraints(boxConstraints)
        if let spacers = self.maybeSpacers, buttons = self.maybeButtons, labels = self.maybeLabels {
            let equalHeightConstraints: [NSLayoutConstraint] = equalHeightConstraintsForButtons(buttons, spacers:spacers, labels: labels)
            let distributedPosConstraints: [NSLayoutConstraint] = distributedPosConstraintsForButtons(buttons, spacers:spacers)
            let labelConstrainsts: [NSLayoutConstraint] = posConstraintsForButtons(buttons, labels: labels)
            let centered = NSLayoutConstraint(item: spacers[0], attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
            var allConstraints = equalHeightConstraints + distributedPosConstraints
            allConstraints.append(centered)
            view.addConstraints(allConstraints)
        }
        super.updateViewConstraints()
    }
    
    
    //    MARK: Helper functions
    
    
    func posConstraintsForButtons(buttons: [UIButton], labels: [UILabel]) -> [NSLayoutConstraint] {
        let zipped = Array(zip(buttons, labels))
        let nestedConstraints = zipped.map{
            NSLayoutConstraint.constraintsWithVisualFormat("V:[btn]-(sp)-[label]", options: .AlignAllCenterX, metrics: ["sp": 15], views: ["btn": $0.0, "label": $0.1])
        }
        let constraints = nestedConstraints.flatMap{ $0 }
        if let const = constraints as? [NSLayoutConstraint] {
            return const
        } else {
            return [NSLayoutConstraint]()
        }
    }
    
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
    
    func equalHeightConstraintsForButtons(buttons: [UIButton], spacers: [UIView], labels: [UILabel]) -> [NSLayoutConstraint] {
        var constraints = [NSLayoutConstraint]()
        if spacers.count <= 1 {
            return constraints
        }
        
        func zippedFirstLast(objects: [UIView]) -> [(UIView, UIView)] {
            let first = objects[0..<objects.count - 1]
            let last = objects[1..<objects.count]
            return Array(zip(first, last))
        }
        
        let zippedSpacers = zippedFirstLast(spacers)
        let zippedButtons = zippedFirstLast(buttons)
        let zippedLabels = zippedFirstLast(labels)
        
        let setEqualHeightAndAlignX = { (view0: UIView, view1: UIView) -> [NSLayoutConstraint] in
            let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[view0(==view1)]", options: .AlignAllCenterX, metrics: nil, views: ["view0": view0, "view1": view1])
            if let constraints = vConstraints as? [NSLayoutConstraint] {
                return constraints
            }
            return [NSLayoutConstraint]()
        }
        
        constraints += zippedSpacers.map{ setEqualHeightAndAlignX($0.0, $0.1) }.flatMap{ $0 }
        constraints += zippedButtons.map{ setEqualHeightAndAlignX($0.0, $0.1) }.flatMap{ $0 }
        constraints += zippedLabels.map{ setEqualHeightAndAlignX($0.0, $0.1) }.flatMap{ $0 }
        
        return constraints
    }
    
    func newSpacerView() -> UIView {
        let aView = UIView()
        aView.setTranslatesAutoresizingMaskIntoConstraints(false)
        return aView
    }
    
    // MARK: Actions
    
    func wineButtonTapped(sender: UIButton) {
        let vc = SelectionViewController()
        
        if sender == foodTypeButton {
            let filterGen: FilterClosureGenerator = { foodTypeString in
                let foodType = FoodType(rawValue:foodTypeString)
                if let food = foodType {
                    return { varietal -> Bool in
                        return varietal.foodPairings.contains(food)
                    }
                } else {
                    return { _ in
                        false
                    }
                }
            }
            vc.maybeChoices = FoodType.allValues().map{ $0.rawValue }
            vc.completionFunc = { completionStr in
                self.foodTypeLabel.text = completionStr
                if let varietals = self.maybeVarietals {
                    println("Varietals before filter: \(varietals)")
                    let filterFunc = filterGen(completionStr)
                    println("FilterFunc: \(filterFunc)")
                    let filtered = varietals.filter(filterFunc)
                    println("Filtered: \(filtered)")
                    self.maybeVarietals = filtered
                }
            }
        } else if sender == spicinessButton {
            let filterGen: FilterClosureGenerator = { spicinessString in
                let spicinessType = SpicinessType(rawValue: spicinessString)
                if let spiciness = spicinessType {
                    return { varietal -> Bool in
                        switch spiciness{
                        case .Spicy:
                            return varietal.worksWithSpice
                        case .NotSpicy:
                            return varietal.worksWithBland
                        }
                    }
                } else {
                    return { _ in
                        false
                    }
                }
            }
            vc.maybeChoices = SpicinessType.allValues().map{ $0.rawValue }
            vc.completionFunc = { completionStr in
                self.spicinessLabel.text = completionStr
                if let varietals = self.maybeVarietals {
                    self.maybeVarietals = varietals.filter(filterGen(completionStr))
                }
            }
        } else if sender == seasoningButton {
            let filterGen: FilterClosureGenerator = { seasoningString -> (Varietal -> Bool) in
                let seasoningType = SeasoningType(rawValue: seasoningString)
                if let seasoning = seasoningType {
                    return {varietal -> Bool in
                        return varietal.seasoningPairings.contains(seasoning)
                    }
                } else {
                    return { _ in
                        false
                    }
                }
            }
            vc.maybeChoices = SeasoningType.allValues().map{ $0.rawValue }
            vc.completionFunc = { completionStr in
                self.seasoningLabel.text = completionStr
                if let varietals = self.maybeVarietals {
                    self.maybeVarietals = varietals.filter(filterGen(completionStr))
                }
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

