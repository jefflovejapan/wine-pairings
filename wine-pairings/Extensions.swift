//
//  Extensions.swift
//  wine-pairings
//
//  Created by Jeffrey Blagdon on 7/11/15.
//  Copyright (c) 2015 Jeffrey Blagdon. All rights reserved.
//

import UIKit
import CoreData

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
        newButton.contentEdgeInsets = UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        newButton.layer.cornerRadius = 8.0
        
        newButton.layer.masksToBounds = true
        newButton.setTitle(unansweredTitle, forState: .Normal)
        newButton.setTitle(answeredTitle, forState: .Selected)
        return newButton
    }
}

extension Seasoning {
    var seasoningType: SeasoningType {
        get {
            let maybeType = SeasoningType(rawValue: self.seasoningTypeString)
            if let type = maybeType {
                return type
            } else {
                fatalError("Invalid seasoning string in maybeType: \(maybeType)")
            }
        } set {
            self.seasoningTypeString = newValue.rawValue
        }
    }
}

extension Food {
    var foodType: FoodType {
        get {
            let maybeType = FoodType(rawValue: self.foodTypeString)
            if let type = maybeType {
                return type
            } else {
                fatalError("Invalid food type string in maybeType: \(maybeType)")
            }
        }
        set {
            self.foodTypeString = newValue.rawValue
        }
    }
}

extension Varietal {
    
    private func pairingsForFoodTypes(types: [FoodType]) -> NSSet {
        if let context = self.managedObjectContext {
            let maybeEntities = Array(0..<types.count).map{ _ -> NSEntityDescription? in
                NSEntityDescription.entityForName(EntityType.Food.rawValue, inManagedObjectContext: context)
            }
            let entities = maybeEntities.filter{ $0 != nil }.map { $0! }
            if entities.count == types.count {
                let indices = Array(0..<types.count)
                let foods: [Food] = indices.map{
                    let type = types[$0]
                    let entity = entities[$0]
                    let food = Food(entity: entity, insertIntoManagedObjectContext: context)
                    food.foodType = types[$0]
                    return food
                }
                return NSSet(array: foods)
            }
        }
        return NSSet()
    }
    
    private func seasoningsForSeasoningTypes(types: [SeasoningType]) -> NSSet {
        if let context = self.managedObjectContext {
            let maybeEntities = Array(0..<types.count).map{ _ -> NSEntityDescription? in
                NSEntityDescription.entityForName(EntityType.Seasoning.rawValue, inManagedObjectContext: context)
            }
            let entities = maybeEntities.filter{ $0 != nil }.map { $0! }
            if entities.count == types.count {
                let indices = Array(0..<types.count)
                let seasonings: [Seasoning] = indices.map{
                    let type = types[$0]
                    let entity = entities[$0]
                    let seasoning = Seasoning(entity: entity, insertIntoManagedObjectContext: context)
                    seasoning.seasoningType = types[$0]
                    return seasoning
                }
                return NSSet(array: seasonings)
            }
        }
        return NSSet()
    }
    
    func configWithCategory(category: WineCategory, name: VarietalName, foodTypes:[FoodType], goodForSpicy: Bool, goodForBland: Bool, seasoningTypes: [SeasoningType]) -> Void {
        self.wineCategory = category
        self.varietalName = name
        self.suitableFoodPairings = pairingsForFoodTypes(foodTypes)
        self.worksWithSpice = goodForSpicy
        self.worksWithBland = goodForBland
        self.suitableSeasonings = seasoningsForSeasoningTypes(seasoningTypes)
    }
    
    var varietalName: VarietalName {
        get{
            let maybeName = VarietalName(rawValue: self.varietalNameString)
            if let name = maybeName {
                return name
            } else {
                fatalError("Invalid varietal name: \(maybeName)")
            }
        }
        set{
            self.varietalNameString = newValue.rawValue
        }
    }
    
    var wineCategory: WineCategory {
        get {
            let maybeCategory = WineCategory(rawValue: self.wineCategoryString)
            if let category = maybeCategory {
                return category
            } else {
                fatalError("Invalid wine category string in maybeType: \(maybeCategory)")
            }
        }
        set {
            self.wineCategoryString = newValue.rawValue
        }
    }
    
    var foodPairings: Set<FoodType> {
        get {
            let pairingsArray = Array(self.suitableFoodPairings)
            let foodTypes = pairingsArray.map{ FoodType(rawValue: $0.foodTypeString) }.map{ $0! }
            return Set(foodTypes)
        }
    }
}


