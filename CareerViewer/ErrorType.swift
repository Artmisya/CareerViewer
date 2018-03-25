//
//  ErrorType.swift
//  CareerViewer
//
//  Created by Saeedeh on 25/03/2018.
//  Copyright © 2018 tiseno. All rights reserved.
//

import Foundation

enum ErrorType: Error {
    
    case noInternetConnection
    case generalError(message: String)
}
