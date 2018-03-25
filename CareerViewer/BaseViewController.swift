//
//  BaseViewController.swift
//  CareerViewer
//
//  Created by Saeedeh on 25/03/2018.
//  Copyright © 2018 tiseno. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // this function helps to show error messages to user
    func handleError(error: ErrorType) {
        
        switch error {
            
        case .noInternetConnection:
            let alert = UIAlertController(title: "Career Viewer", message: ErrorMessage.noInternet.rawValue, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        case .generalError(var reason):
            if(reason==""){
                
                reason = ErrorMessage.unknownError.rawValue
                
            }
            let alert = UIAlertController(title: "Career Viewer", message: reason, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    
}
