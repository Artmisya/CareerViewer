//
//  Contact.swift
//  CareerViewer
//
//  Created by Saeedeh on 25/03/2018.
//  Copyright © 2018 tiseno. All rights reserved.
//

import Foundation

class Contact{
    
    var type:ContactType
    var value:String
    
    init(type:ContactType,value:String) {
        self.value=value
        self.type=type
    }
}
