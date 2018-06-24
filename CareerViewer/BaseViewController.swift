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
            else if (reason=="The Internet connection appears to be offline."){
                
                reason = ErrorMessage.noInternet.rawValue
            }
            let alert = UIAlertController(title: "Career Viewer", message: reason, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    // helps to create a frame
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    @objc func printClicked(sender: UIButton) {
        
        let printInfo = UIPrintInfo(dictionary:nil)
        printInfo.outputType = UIPrintInfoOutputType.general
        printInfo.jobName = "Creerer Viewer"
        
        // Set up print controller
        let printController = UIPrintInteractionController.shared
        printController.printInfo = printInfo
        
        // Assign a UIImage version of my UIView as a printing iten
        
        printController.printingItem = self.view.toImage()
        
        // send it to printer
        if(UIDevice.current.userInterfaceIdiom==UIUserInterfaceIdiom.pad){
            
            printController.present(from: self.view.frame, in: self.view, animated: true, completionHandler: nil)
            
        }
        else{
            printController.present(animated: true, completionHandler: nil)
        }
    }
    
    func printTableViewAsPDF(tableView: UITableView)  {
        
        // create pdf as nsdata
        let priorBounds = tableView.bounds
        let fittedSize = tableView.sizeThatFits(CGSize(width:priorBounds.size.width, height:tableView.contentSize.height))
        tableView.bounds = CGRect(x:0, y:0, width:fittedSize.width, height:fittedSize.height)
        
        let pdfPageBounds = CGRect(x:0, y:0, width:tableView.frame.width, height:self.view.frame.height)
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, pdfPageBounds,nil)
        var pageOriginY: CGFloat = 0
        
        while pageOriginY < fittedSize.height {
            UIGraphicsBeginPDFPageWithInfo(pdfPageBounds, nil)
            UIGraphicsGetCurrentContext()!.saveGState()
            UIGraphicsGetCurrentContext()!.translateBy(x: 0, y: -pageOriginY)
            tableView.layer.render(in: UIGraphicsGetCurrentContext()!)
            UIGraphicsGetCurrentContext()!.restoreGState()
            pageOriginY += pdfPageBounds.size.height
        }
        
        UIGraphicsEndPDFContext()
        tableView.bounds = priorBounds
        
        // calling UIprinter
        
        let printInfo = UIPrintInfo(dictionary:nil)
        printInfo.outputType = UIPrintInfoOutputType.general
        printInfo.jobName = "Career Viewer"
        
        // Set up print controller
        let printController = UIPrintInteractionController.shared
        printController.printingItem=pdfData
        // send it to printer
        if(UIDevice.current.userInterfaceIdiom==UIUserInterfaceIdiom.pad){
            
            printController.present(from: self.view.frame, in: self.view, animated: true, completionHandler: nil)
            
        }
        else{
            printController.present(animated: true, completionHandler: nil)
        }
        
    }
    
    
    
    func printViewControllerAsPDF()  {
        
        let priorBounds = view.bounds
        let fittedSize = view.sizeThatFits(CGSize(width:priorBounds.size.width, height:self.view.frame.height))
        view.bounds = CGRect(x:0, y:0, width:fittedSize.width, height:fittedSize.height)
        let pdfPageBounds = CGRect(x:0, y:0, width:view.frame.width, height:self.view.frame.height)
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, pdfPageBounds,nil)
        var pageOriginY: CGFloat = 0
        while pageOriginY < fittedSize.height {
            UIGraphicsBeginPDFPageWithInfo(pdfPageBounds, nil)
            UIGraphicsGetCurrentContext()!.saveGState()
            UIGraphicsGetCurrentContext()!.translateBy(x: 0, y: -pageOriginY)
            view.layer.render(in: UIGraphicsGetCurrentContext()!)
            UIGraphicsGetCurrentContext()!.restoreGState()
            pageOriginY += pdfPageBounds.size.height
        }
        UIGraphicsEndPDFContext()
        view.bounds = priorBounds
        
        
        // calling UIprinter
        
        let printInfo = UIPrintInfo(dictionary:nil)
        printInfo.outputType = UIPrintInfoOutputType.general
        printInfo.jobName = "Career Viewer"
        
        // Set up print controller
        let printController = UIPrintInteractionController.shared
        printController.printingItem=pdfData
        // send it to printer
        if(UIDevice.current.userInterfaceIdiom==UIUserInterfaceIdiom.pad){
            
            printController.present(from: self.view.frame, in: self.view, animated: true, completionHandler: nil)
            
        }
        else{
            printController.present(animated: true, completionHandler: nil)
        }
    }
}
