//
//  Varietal.swift
//  wine-pairings
//
//  Created by Jeffrey Blagdon on 7/12/15.
//  Copyright (c) 2015 Jeffrey Blagdon. All rights reserved.
//

import Foundation
import CoreData

class Varietal: NSManagedObject {

    @NSManaged var wineCategoryString: String
    @NSManaged var worksWithSpice: Bool
    @NSManaged var varietalNameString: String
    @NSManaged var worksWithBland: Bool
    @NSManaged var suitableFoodPairings: NSSet
    @NSManaged var suitableSeasonings: NSSet

}
