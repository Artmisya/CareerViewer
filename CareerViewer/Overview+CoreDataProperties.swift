//
//  Overview+CoreDataProperties.swift
//  CareerViewer
//
//  Created by Saeedeh on 25/03/2018.
//  Copyright © 2018 tiseno. All rights reserved.
//

import Foundation
import CoreData


extension Overview {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Overview> {
        return NSFetchRequest<Overview>(entityName: "Overview");
    }

    @NSManaged public var descryption: String?
    @NSManaged public var expiryTime: NSDate?
    @NSManaged public var image: NSObject?
    @NSManaged public var name: String?

}
