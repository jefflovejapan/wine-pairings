//
//  AppDelegate.swift
//  wine-pairings
//
//  Created by Jeffrey Blagdon on 7/11/15.
//  Copyright (c) 2015 Jeffrey Blagdon. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        let landingVC = LandingViewController()
        
        if let context = self.managedObjectContext {
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
            
            landingVC.maybeVarietals = allVarietals
            
            var err: NSError?
            if context.save(&err) {
                println("Successfully saved")
            } else {
                println("Something went wrong: \(err)")
            }
        }
        
        
        let aWindow = UIWindow(frame: UIScreen.mainScreen().bounds)
        aWindow.backgroundColor = UIColor.whiteColor()
        let navController = UINavigationController(rootViewController: landingVC)
        aWindow.rootViewController = navController
        self.window = aWindow
        aWindow.makeKeyAndVisible()
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.blagdon.wine_pairings" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as! NSURL
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("wine_pairings", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("wine_pairings.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
        }()
    
    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
        }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }
    
}

