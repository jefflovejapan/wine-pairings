//
//  Seasoning.swift
//  wine-pairings
//
//  Created by Jeffrey Blagdon on 7/12/15.
//  Copyright (c) 2015 Jeffrey Blagdon. All rights reserved.
//

import Foundation
import CoreData

class Seasoning: NSManagedObject {

    @NSManaged var seasoningTypeString: String
    @NSManaged var goodVarietals: NSSet

}
