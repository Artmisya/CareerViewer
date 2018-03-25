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
    
    
    /* this methode creates/updates an instance of Overview and save it to coredata for future offline use*/
    
    class func createOverview(name:String,descryption:String,imageProfile:String)->NSManagedObject?{
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return nil
        }
        
        var overview :Overview?
        if let managedContext=appDelegate.persistentContainer.viewContext as NSManagedObjectContext?{
            
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
            let expiryTime = calendar.date(byAdding: .minute, value: appDelegate.coreDataExpirtTime, to: startDate)
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
    
    class func fetchOverviewFromCoreData()->OfflineOverview{
        
        
        print("fetchOverviewFromCoreData")
        var offlineOverview=OfflineOverview(data: nil,outDated: true)
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return offlineOverview
        }
        
        if let managedContext=appDelegate.persistentContainer.viewContext as NSManagedObjectContext?{
            
            let fetchRequest =
                NSFetchRequest<Overview>(entityName: "Overview")
            
            
            do {
                let fetchRequest = try managedContext.fetch(fetchRequest)
                
                
                if(fetchRequest.count>0){
                    
                    let overview=fetchRequest.first
                    // check if it is expired or not
                    let isOutDated=(overview?.expiryTime as! Date) < Date()
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
    
    
   // This method clear coredata, this method has been called only use in unit test
    class func deleteOverviewFromCoreData(){
        
        print("deleteOverviewFromCoreData")
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        if let managedContext=appDelegate.persistentContainer.viewContext as NSManagedObjectContext?{
            
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
}
