//
//  Education.swift
//  CareerViewer
//
//  Created by Saeedeh on 25/03/2018.
//  Copyright © 2018 tiseno. All rights reserved.
//

import Foundation


class Education: Codable {
    
    let degree:String
    let avg:String
    let university:String
    let duration:String
    
    init(degree:String,avg:String,university:String,duration:String) {
        self.degree=degree
        self.avg=avg
        self.university=university
        self.duration=duration
    }
}
