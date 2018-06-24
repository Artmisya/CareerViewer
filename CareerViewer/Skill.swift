//
//  Skill.swift
//  CareerViewer
//
//  Created by Saeedeh on 25/03/2018.
//  Copyright © 2018 tiseno. All rights reserved.
//

import Foundation
class Skill: Codable{
    
    let title:String
    let rate:String
    
    init(title:String,rate:String) {
        self.title=title
        self.rate=rate
    }
    
}
