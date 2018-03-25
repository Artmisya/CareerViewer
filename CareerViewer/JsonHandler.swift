//
//  JsonHandler.swift
//  CareerViewer
//
//  Created by Saeedeh on 25/03/2018.
//  Copyright © 2018 tiseno. All rights reserved.
//

import Foundation



struct JsonResult {
    
    let data: [String:Any]?  // data will be nil in case an error happen during reading the file
    let error: ErrorType?  // error will be nil in case the json file cen be read successfully
    
}

class JsonHandler{
    
    //this method read a json file and returns the file content in a JsonResult format
    
    class func readJsonFile(fileName:String)->JsonResult{
        
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as! [String:Any]
                
                let result=JsonResult(data: jsonResult, error: nil)
                return result
                
            } catch let error as NSError {
                // handle error
                print (error.localizedDescription)
                
                let error = ErrorType.generalError(message: error.localizedDescription)
                let result=JsonResult(data: nil, error: error)
                return result
            }
        }
        else{
            
            let error = ErrorType.generalError(message: ErrorMessage.failToOpenFile.rawValue)
            let result=JsonResult(data: nil, error: error)
            return result
            
        }
        
    }
    
    
}
