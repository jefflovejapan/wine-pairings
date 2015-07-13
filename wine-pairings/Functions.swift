//
//  Functions.swift
//  wine-pairings
//
//  Created by Jeffrey Blagdon on 7/12/15.
//  Copyright (c) 2015 Jeffrey Blagdon. All rights reserved.
//

import Foundation
import CoreData

func allVarietalsFromContext(context:NSManagedObjectContext) -> [Varietal] {
    let varietalNames: [VarietalName] = [.PinotGrigio, .SauvignonBlanc, .Chardonnay, .Riesling, .Viognier, .CabarnetSauvignon, .Merlot, .PinotNoir, .Malbec, .Zinfandel, .Sparkling]
    let maybeEntities = Array(0..<varietalNames.count).map { _ -> NSEntityDescription? in
        NSEntityDescription.entityForName(EntityType.Varietal.rawValue, inManagedObjectContext: context)
    }
    
    //            TODO: Create an entity generator
    
    
    let entities = maybeEntities.filter{ $0 != nil }.map{ $0! }
    assert(entities.count == varietalNames.count, "Need enough varietal entities for varietal names!")
    
    let pinotGrigio = Varietal(entity:entities[0], insertIntoManagedObjectContext:context)
    pinotGrigio.configWithCategory(.White, name: .PinotGrigio, foodTypes: [.Pasta], goodForSpicy: false, goodForBland: true, seasoningTypes: [.Cream])
    
    let sauvignonBlanc = Varietal(entity: entities[1], insertIntoManagedObjectContext: context)
    sauvignonBlanc.configWithCategory(.White, name: .SauvignonBlanc, foodTypes: [.Fish, .Pasta, .Salad], goodForSpicy: false, goodForBland:true,  seasoningTypes: [.Citrus, .Cream, .Herbs])
    
    let chardonnay = Varietal(entity: entities[2], insertIntoManagedObjectContext:context)
    chardonnay.configWithCategory(.White, name: .Chardonnay, foodTypes: [.WhiteMeat, .Fish], goodForSpicy: false, goodForBland: true, seasoningTypes: [.Herbs, .Butter])
    
    let riesling = Varietal(entity: entities[3], insertIntoManagedObjectContext: context)
    riesling.configWithCategory(.White, name: .Riesling, foodTypes: [.WhiteMeat, .Fish], goodForSpicy: true, goodForBland: false, seasoningTypes: [.Herbs])
    
    let viognier = Varietal(entity: entities[4], insertIntoManagedObjectContext: context)
    viognier.configWithCategory(.White, name: .Viognier, foodTypes: [.RedMeat, .WhiteMeat], goodForSpicy: true, goodForBland: false, seasoningTypes: [])
    
    let cabarnetSauvignon = Varietal(entity: entities[5], insertIntoManagedObjectContext: context)
    cabarnetSauvignon.configWithCategory(.Red, name: .CabarnetSauvignon, foodTypes: [.RedMeat, .WhiteMeat], goodForSpicy: false, goodForBland: true, seasoningTypes: [.Smokey, .Herbs])
    
    let merlot = Varietal(entity: entities[6], insertIntoManagedObjectContext: context)
    merlot.configWithCategory(.Red, name: .Merlot, foodTypes: [.RedMeat, .Pasta], goodForSpicy: true, goodForBland: false, seasoningTypes: [.Cream])
    
    let pinotNoir = Varietal(entity: entities[7], insertIntoManagedObjectContext: context)
    pinotNoir.configWithCategory(.Red, name: .PinotNoir, foodTypes: [.RedMeat, .WhiteMeat, .Salad], goodForSpicy: true, goodForBland: true, seasoningTypes: [.Smokey, .Cream, .Herbs])
    
    let malbec = Varietal(entity: entities[8], insertIntoManagedObjectContext: context)
    malbec.configWithCategory(.Red, name: .Malbec, foodTypes: [.WhiteMeat, .RedMeat], goodForSpicy: false, goodForBland: true, seasoningTypes: [.Cream])
    
    let zinfandel = Varietal(entity: entities[9], insertIntoManagedObjectContext: context)
    zinfandel.configWithCategory(.Red, name: .Zinfandel, foodTypes: [.RedMeat, .WhiteMeat], goodForSpicy: false, goodForBland: true, seasoningTypes: [.Cream])
    
    let sparkling = Varietal(entity: entities[10], insertIntoManagedObjectContext: context)
    sparkling.configWithCategory(.Sparkling, name: .Sparkling, foodTypes: [.RedMeat, .WhiteMeat, .Fish, .Salad], goodForSpicy: true, goodForBland: true, seasoningTypes: [.Smokey])
    
    let allVarietals = [pinotGrigio, sauvignonBlanc, chardonnay, riesling, viognier, cabarnetSauvignon, merlot, pinotNoir, malbec, zinfandel, sparkling]
    
    return allVarietals
}
