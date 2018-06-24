//
//  JsonHandler.swift
//  CareerViewer
//
//  Created by Saeedeh on 25/03/2018.
//  Copyright © 2018 tiseno. All rights reserved.
//

import Foundation



class JsonHandler{
    
    //this method read a json file and returns the file content in a JsonResult format
    
    class func readJsonFile(fileName:String)->Result<Any>{
        
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let result=Result.success(data as Any)
                return result
                
            } catch let error as NSError {
                // handle error
                print (error.localizedDescription)
                
                let error = ErrorType.generalError(message: error.localizedDescription)
                let result=Result<Any>.failure(error)
                return result
            }
        }
        else{
            
            let error = ErrorType.generalError(message: ErrorMessage.failToOpenFile.rawValue)
            let result=Result<Any>.failure(error)
            return result
            
        }
        
    }
    
    
}

