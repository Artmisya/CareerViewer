//
//  Resume.swift
//  CareerViewer
//
//  Created by Saeedeh on 25/03/2018.
//  Copyright © 2018 tiseno. All rights reserved.
//


import Foundation
import RxSwift
import Alamofire


class Resume{
    
    var overview:Overview?
    var workExperienceList:[WorkExperience]?
    var skillList:[Skill]?
    var educationList:[Education]?
    var contactList:[Contact]?
    
    /*** this methode try to load the overview from cordata first.
     in case core data is empty or it is outdated it will try to load the information from online api.
     In case online load is fail and coredata is empty this method provides user with an error message.
     In case online load is fail and coredata is not empty but it is out dated this method still returns out dated data to the viewcontroller.
     the return parameter is a Boolean whitch indicate the overview has been loaded from an outdated coredata or not.
     ***/
    
    
    func fetchOverview() -> Observable<Bool> {return Observable.create
        { observer -> Disposable in
            
            // first try offline load
            let offlineOverview=CoreDataHandler.fetchOverviewFromCoreData()
            
            //offline load was successful, coredata is not empty and it is not expired also
            if offlineOverview.isOutDated()==false {
                
                
                self.overview=offlineOverview.data
                let isOutDated=false
                observer.onNext(isOutDated)
                observer.onCompleted()
                
            }
            else{
                
                //offline is not avaliable ,either coredata is empty or it is expired, go for online load
                
                let api_url=ApiUrl.getOverview.rawValue
                
                Alamofire.request(api_url, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
                    
                    switch(response.result) {
                        
                    case .success(let info):
                        
                        // online load was successfull
                        let data=info as? [String: Any]
                        let overviewData=data?["data"] as? [String: String]
                        
                        let descryption=(overviewData?["descryption"])! as String
                        let imageUrl=(overviewData?["profile_image"])! as String
                        let name=(overviewData?["name"])! as String
                        
                        // update core data with latest data from api
                        self.overview=CoreDataHandler.createOverview(name:name,descryption:descryption,imageProfile:imageUrl ) as! Overview?
                        
                        //return result to viewcontroller
                        let isOutDated=false
                        observer.onNext(isOutDated)
                        observer.onCompleted()
                        
                        
                    case .failure(let error):
                        
                        print (error.localizedDescription)
                        
                        // online load was faild, try to load an expired overview if there is any
                        if offlineOverview.isEmpty()==false{
                            
                            // there is an expired overview load it with a warning ( return isOutDated true)
                            self.overview=offlineOverview.data
                            
                            //return result to viewcontroller
                            let isOutDated=true
                            observer.onNext(isOutDated)
                            observer.onCompleted()
                            
                        }
                        else{
                            // unable to load offline core data is empty , inform user
                            let userError=ErrorType.generalError(message: error.localizedDescription)
                            observer.onError(userError)
                        }
                        
                        
                    }
                }
                
            }
            
            return Disposables.create()
        }
    }
    
    
        
}
