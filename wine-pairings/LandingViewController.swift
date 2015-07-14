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
    
    let foodTypeButton = UIButton.wineQuestionButton("What kind of food are you eating?", answeredTitle:"Food type selected")
    let foodTypeLabel = UILabel.wineAnswerLabel()
    
    let spicinessButton = UIButton.wineQuestionButton("Is it spicy?", answeredTitle:"Spiciness selected")
    let spicinessLabel = UILabel.wineAnswerLabel()
    
    let seasoningButton = UIButton.wineQuestionButton("How is the food seasoned?", answeredTitle:"Seasoning selected")
    let seasoningLabel = UILabel.wineAnswerLabel()
    
    let clearAllButton = { _ -> UIButton in
        let button = UIButton()
        button.setTranslatesAutoresizingMaskIntoConstraints(false)
        button.setTitle("Clear All", forState: .Normal)
        button.setTitleColor(UIColor.grayColor(), forState: .Normal)
        return button
        }()
    
    let buttonBox = UIView()
    
    lazy var otherBox = { _ -> UIView in
        let box = UIView()
        box.setTranslatesAutoresizingMaskIntoConstraints(false)
        return box
        }()
    
    lazy var filteredVarietalsLabel = { _ -> UILabel in
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(16.0)
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
        label.textColor = UIColor.grayColor()
        label.numberOfLines = 0
        return label
        }()
    
    var questionButtons: [UIButton]?
    var answerLabels: [UILabel]?
    var spacers: [UIView]?
    var managedObjectContext: NSManagedObjectContext?
    var allVarietals: [Varietal]?
    var filteredVarietals: [Varietal]?
    
    var foodTypeFilter: FilterClosure?
    var spicinessFilter: FilterClosure?
    var seasoningFilter: FilterClosure?
    
    
    //    MARK: View Controller life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let theButtons = [foodTypeButton, spicinessButton, seasoningButton]
        theButtons.map{ $0.addTarget(self, action:"wineButtonTapped:", forControlEvents: .TouchUpInside ) }
        let theSpacers = Array(0..<theButtons.count + 1).map{ Void in self.newSpacerView() }
        let theLabels = [foodTypeLabel, spicinessLabel, seasoningLabel]
        [buttonBox, otherBox].map{ aView -> Void in
            aView.setTranslatesAutoresizingMaskIntoConstraints(false)
            self.view.addSubview(aView)
        }
        otherBox.addSubview(filteredVarietalsLabel)
        
        [theButtons, theSpacers, theLabels].flatMap{ $0 }.map{ self.buttonBox.addSubview($0) }
        questionButtons = theButtons
        answerLabels = theLabels
        spacers = theSpacers
        view.addSubview(clearAllButton)
        clearAllButton.addTarget(self, action: "clearButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)

        view.setNeedsUpdateConstraints()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if(self.allVarietals == nil) {
            if let context = self.managedObjectContext {
                self.allVarietals = allVarietalsFromContext(context)
            }
        }
        updateButtonsAndLabels()
    }
    
    override func updateViewConstraints() {
        
        let nestedWidthConstraints = [buttonBox, otherBox].map{ (aBox: UIView) -> [NSLayoutConstraint] in
            NSLayoutConstraint.constraintsWithVisualFormat("|[box]|", options: .allZeros, metrics: nil, views: ["box": aBox]) as! [NSLayoutConstraint]
        }
        let boxWidthConstraints = nestedWidthConstraints.flatMap{ $0 }
        var boxHeightConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[tlg][box][otherBox(==box)]|", options: .allZeros, metrics: nil, views: ["tlg":topLayoutGuide, "box": buttonBox, "otherBox": otherBox]) as! [NSLayoutConstraint]
        view.addConstraints(boxWidthConstraints + boxHeightConstraints)
        if let spacers = spacers, buttons = questionButtons, labels = answerLabels {
            let equalHeightConstraints: [NSLayoutConstraint] = equalHeightConstraintsForButtons(buttons, spacers:spacers, labels: labels)
            let distributedPosConstraints: [NSLayoutConstraint] = distributedPosConstraintsForButtons(buttons, spacers:spacers)
            let labelConstraints: [NSLayoutConstraint] = posConstraintsForButtons(buttons, labels: labels)
            let centered = NSLayoutConstraint(item: spacers[0], attribute: .CenterX, relatedBy: .Equal, toItem: self.view, attribute: .CenterX, multiplier: 1.0, constant: 0.0)
            var allConstraints = equalHeightConstraints + distributedPosConstraints + labelConstraints
            allConstraints.append(centered)
            view.addConstraints(allConstraints)
        }
        
        let varietalLabelHeightConstraints  = NSLayoutConstraint.constraintsWithVisualFormat("V:|-(in)-[label]-(in)-|", options: .allZeros, metrics: ["in": 12], views: ["label": filteredVarietalsLabel]) as! [NSLayoutConstraint]
        let varietalLabelWidthConstraints = NSLayoutConstraint.constraintsWithVisualFormat("|-(in)-[label]-(in)-|", options: .allZeros, metrics: ["in": 12], views: ["label": filteredVarietalsLabel]) as! [NSLayoutConstraint]
        view.addConstraints(varietalLabelWidthConstraints + varietalLabelHeightConstraints)
        
        let clearButtonXConstraints = NSLayoutConstraint.constraintsWithVisualFormat("[btn]-(in)-|", options: .allZeros, metrics: ["in": 20], views: ["btn": clearAllButton])
        let clearButtonYConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[btn]-(in)-|", options: .allZeros, metrics: ["in": 20], views: ["btn": clearAllButton])
        view.addConstraints(clearButtonXConstraints + clearButtonYConstraints)
        
        super.updateViewConstraints()
    }
    
    
//    MARK: Update UI
    
    func updateButtonsAndLabels() {
        if let varietals = allVarietals {
            let filters = [foodTypeFilter, spicinessFilter, seasoningFilter].filter{ $0 != nil}.map{ $0! }
            if filters.count > 0 {
                let filtered = applyFilters(filters, toVarietals:varietals)
                filteredVarietalsLabel.text = labelTextForVarietals(filtered)
                filteredVarietals = filtered
            } else {
                filteredVarietalsLabel.text = nil
            }
        }
        if let buttons = questionButtons {
            if (buttons.filter{ $0.state == .Selected }.count > 0) {
                clearAllButton.hidden = false
            } else {
                clearAllButton.hidden = true
            }
        }
    }
    
    func clearFilters() {
        seasoningFilter = nil
        spicinessFilter = nil
        foodTypeFilter = nil
    }
    
    func deselectButtons() {
        questionButtons?.map{ $0.selected = false }
    }
    
    func clearAnswerLabels() {
        answerLabels?.map{ $0.text = nil }
    }
    
    //    MARK: Helper functions
    
    func labelTextForVarietals(varietals: [Varietal]) -> String {
        if varietals.count > 1 {
            let stub = "Consider these varietals:\n"
            let names = varietals.map{ "\n" + $0.varietalName.rawValue.capitalizedString }
            return reduce(names, stub, +)
        } else if varietals.count == 1 {
            return "Consider \(varietals[0].varietalName.rawValue)"
        }
        return "No varietals match your query. Maybe stick with water."
    }
    
    func applyFilters(filters:[FilterClosure], toVarietals varietalsToFilter:[Varietal]) -> [Varietal] {
        var remainingVarietals = varietalsToFilter
        for filter in filters {
            remainingVarietals = remainingVarietals.filter(filter)
        }
        return remainingVarietals
    }
    
    func posConstraintsForButtons(buttons: [UIButton], labels: [UILabel]) -> [NSLayoutConstraint] {
        let zipped = Array(zip(buttons, labels))
        let nestedConstraints = zipped.map{
            NSLayoutConstraint.constraintsWithVisualFormat("V:[btn]-(sp)-[label]", options: .AlignAllCenterX, metrics: ["sp": 8], views: ["btn": $0.0, "label": $0.1])
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
        unowned let welf = self
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
                welf.foodTypeLabel.text = completionStr.capitalizedString
                welf.foodTypeButton.selected = true
                welf.foodTypeFilter = filterGen(completionStr)
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
                welf.spicinessLabel.text = completionStr.capitalizedString
                welf.spicinessButton.selected = true
                welf.spicinessFilter = filterGen(completionStr)
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
                welf.seasoningLabel.text = completionStr.capitalizedString
                welf.seasoningButton.selected = true
                welf.seasoningFilter = filterGen(completionStr)
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func clearButtonTapped() {
        clearFilters()
        deselectButtons()
        clearAnswerLabels()
        updateButtonsAndLabels()
    }
    
}

