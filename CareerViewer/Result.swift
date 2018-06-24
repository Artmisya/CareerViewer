//
//  Result.swift
//  CareerViewer
//
//  Created by Saeedeh on 24/06/2018.
//  Copyright © 2018 tiseno. All rights reserved.
//

import Foundation

enum Result <T>{
    case success(T)
    case failure(Error)
    
}
