//
//  WorkExperience.swift
//  CareerViewer
//
//  Created by Saeedeh on 25/03/2018.
//  Copyright © 2018 tiseno. All rights reserved.
//

import Foundation

class WorkExperience : Codable{
    
    let role:String
    let company:String
    let duration:String
    let descryption:String
    
    
    init(role:String,company:String,duration:String,descryption:String) {
        self.role=role
        self.company=company
        self.duration=duration
        self.descryption=descryption
    }
    
    
}
