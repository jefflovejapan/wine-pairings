//
//  Enums.swift
//  wine-pairings
//
//  Created by Jeffrey Blagdon on 7/12/15.
//  Copyright (c) 2015 Jeffrey Blagdon. All rights reserved.
//

import Foundation

enum VarietalName: String {
    case PinotGrigio = "pinot grigio"
    case SauvignonBlanc = "sauvignon blanc"
    case Chardonnay = "chardonnay"
    case Riesling = "riesling"
    case Viognier = "viognier"
    case CabarnetSauvignon = "cabarnet sauvignon"
    case Merlot = "merlot"
    case PinotNoir = "pinot noir"
    case Malbec = "malbec"
    case Zinfandel = "zinfandel"
    case Sparkling = "sparkling"
}

enum EntityType: String {
    case Varietal = "Varietal"
    case Seasoning = "Seasoning"
    case Food = "Food"
}

enum WineCategory: String {
    case Red = "red"
    case White = "white"
    case Sparkling = "sparkling"
}

enum FoodType: String {
    case RedMeat = "red meat"
    case WhiteMeat = "white meat"
    case Fish = "fish"
    case Pasta = "pasta"
    case Salad = "salad"
}

enum SeasoningType: String {
    case Smokey = "smokey"
    case Citrus = "citrus"
    case Cream = "cream"
    case Herbs = "herbs"
    case Butter = "butter"
}