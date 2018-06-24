//
//  CoreDataHandler.swift
//  CareerViewer
//
//  Created by Saeedeh on 25/03/2018.
//  Copyright © 2018 tiseno. All rights reserved.
//

import Foundation
import CoreData
import UIKit


struct OfflineOverview {
    
    let data: Overview?  // data will be nil in case the coredata is empty
    let outDated: Bool
    
    func isEmpty()->Bool{
        
        if data==nil{
            
            return true
        }
        
        return false
    }
    
    func isOutDated()->Bool{
        
        
        return outDated
    }
    
}

class CoreDataHandler{
    
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "CareerViewer")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    /* this methode creates/updates an instance of Overview and save it to coredata for future offline use*/
    
    func createOverview(name:String,descryption:String,imageProfile:String)->NSManagedObject?{
        
        var overview :Overview?
        if let managedContext=persistentContainer.viewContext as NSManagedObjectContext?{
            
            let offlineOverview = fetchOverviewFromCoreData()
            
            if offlineOverview.isEmpty(){
                
                // overview does not exsit in coredata, go for add a new
                overview=Overview(context: managedContext)
            }
            else{
                
                // overview already exsit in coredata, go for update
                overview=offlineOverview.data
            }
            
            
            overview?.name=name
            overview?.descryption=descryption
            
            
            // setting image
            if let imageProfileUrl=URL(string: imageProfile){
                
                do {
                    overview?.image = try Data(contentsOf: imageProfileUrl) as NSData?
                } catch {
                    
                    print("Unable to load data: \(error)")
                    
                }
            }
            
            //setting expiry date within 10 mins
            
            let startDate=Date()
            let calendar = Calendar.current
            let expiryTime = calendar.date(byAdding: .minute, value: 10, to: startDate)
            overview?.expiryTime=expiryTime as NSDate?
            
            
            // save chnages to coredata
            do {
                
                try managedContext.save()
                
            } catch let error as NSError {
                
                print("Could not save. \(error), \(error.userInfo)")
            }
            
        }
        
        return overview
        
    }
    /* this methode try to load overview from coredata if any*/
    
    func fetchOverviewFromCoreData()->OfflineOverview{
        
        
        print("fetchOverviewFromCoreData")
        var offlineOverview=OfflineOverview(data: nil,outDated: true)
        
        if let managedContext=persistentContainer.viewContext as NSManagedObjectContext?{
            
            let fetchRequest =
                NSFetchRequest<Overview>(entityName: "Overview")
            
            
            do {
                let fetchRequest = try managedContext.fetch(fetchRequest)
                
                
                if(fetchRequest.count>0){
                    
                    let overview=fetchRequest.first
                    // check if it is expired or not
                    let isOutDated=(overview?.expiryTime as Date?)! < Date()
                    offlineOverview=OfflineOverview(data: overview, outDated: isOutDated)
                    
                    return offlineOverview
                }
                else{
                    
                    // this is first time load ,coredata is empty
                    return  offlineOverview
                }
            } catch let error as NSError {
                
                print("Could not fetch. \(error), \(error.userInfo)")
                return offlineOverview
                
            }
        }
        
        return offlineOverview
    }
    
    
    // This method clear coredata, this method has been called only in unit test
    func deleteOverviewFromCoreData(){
        
        print("deleteOverviewFromCoreData")
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        if let managedContext=persistentContainer.viewContext as NSManagedObjectContext?{
            
            let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Overview")
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
            
            do {
                try managedContext.execute(deleteRequest)
                try managedContext.save()
            } catch {
                print ("There was an error")
            }
        }
    }
    
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
