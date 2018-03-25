//
//  ErrorMessage.swift
//  CareerViewer
//
//  Created by Saeedeh on 25/03/2018.
//  Copyright © 2018 tiseno. All rights reserved.
//

import Foundation

enum ErrorMessage: String {
    
    case noInternet="The Internet connection appears to be offline. Please check your conectivity and try again."
    case failToOpenEmail="The operation couldn’t be completed. Failed to open the email."
    case failToOpenCall="The operation couldn’t be completed. Failed to initialize a call."
    case failToOpenBrowser="The operation couldn’t be completed. Failed to open the browser."
    case failToOpenFile="The operation couldn’t be completed. The file does not exist."
    case apiFail="The operation couldn’t be completed. The server was not able to produce a response. Please try later."
    case unknownError="Whoops, something went wrong!"
    
}
