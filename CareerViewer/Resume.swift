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
    
    weak var  overview:Overview?
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
        let coreDataHandler=CoreDataHandler()
        let offlineOverview=coreDataHandler.fetchOverviewFromCoreData()
        
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
                    
                    
                    let data=info as? [String: Any]
                    
                    // online load was successfull
                    if let overviewData=data?["data"] as? [String: String]{
                        
                        let descryption=self.checkForNullKey(param:overviewData["descryption"] as Any)
                        let imageUrl=self.checkForNullKey(param:overviewData["profile_image"] as Any)
                        let name=self.checkForNullKey(param:overviewData["name"] as Any)
                        
                        // update core data with latest data from api
                        self.overview=coreDataHandler.createOverview(name:name,descryption:descryption,imageProfile:imageUrl ) as! Overview?
                        
                    }
                    
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
    
    //this method fetch education from json file and initialize the education list
    
    func  fetchEducation()-> Observable<Void> {return Observable.create
    { observer -> Disposable in
        
        
        let result = JsonHandler.readJsonFile(fileName: "education")
        
        switch(result) {
            
        case .success(let data):
            
            self.educationList=[Education]()
            let jsonDecoder = JSONDecoder()
            
            do{
                
                self.educationList=try jsonDecoder.decode([Education].self, from: data as! Data)
            }
            catch let error{
                
                let generalError=ErrorType.generalError(message: error.localizedDescription)
                observer.onError(generalError)
            }
            
            observer.onNext(())
            observer.onCompleted()
            
            
        case .failure(let error):
            
            observer.onError(error)
        }
        return Disposables.create()
        }
        
        
    }
    
    //this method fetch work experience from json file and initialize the work experience list
    
    func  fetchWorkExperience()-> Observable<Void> {return Observable.create
    { observer -> Disposable in
        
        
        let result = JsonHandler.readJsonFile(fileName: "workExperience")
        
        switch(result) {
            
        case .success(let data):
            
            self.workExperienceList=[WorkExperience]()
            
            let jsonDecoder = JSONDecoder()
            
            do{
                
                self.workExperienceList=try jsonDecoder.decode([WorkExperience].self, from: data as! Data)
            }
            catch let error{
                
                let generalError=ErrorType.generalError(message: error.localizedDescription)
                observer.onError(generalError)
            }
            
            observer.onNext(())
            observer.onCompleted()
            
        case .failure(let error):
            
            observer.onError(error)
        }
        return Disposables.create()
        }
        
        
    }
    
    
    //this method fetch work skills from json file and initialize the skill list
    
    func  fetchSkills()-> Observable<Void> {return Observable.create
    { observer -> Disposable in
        
        
        let result = JsonHandler.readJsonFile(fileName: "skill") as Result<Any>
        
        switch(result) {
            
        case .success(let data):
            
            self.skillList=[Skill]()
            let jsonDecoder = JSONDecoder()
            
            do{
                
                self.skillList=try jsonDecoder.decode([Skill].self, from: data as! Data)
            }
            catch let error{
                
                let generalError=ErrorType.generalError(message: error.localizedDescription)
                observer.onError(generalError)
            }
            
            observer.onNext(())
            observer.onCompleted()
            
            
        case .failure(let error):
            
            observer.onError(error)
            
            
        }
        return Disposables.create()
        }
        
        
    }
    
    //this method fetch contacts from json file and initialize the contact list
    
    func  fetchContacts()-> Observable<Void> {return Observable.create
    { observer -> Disposable in
        
        let result = JsonHandler.readJsonFile(fileName: "contact")
        
        switch(result) {
            
        case .success(let data):
            
            self.contactList=[Contact]()
            let jsonDecoder = JSONDecoder()
            
            do{
                
                self.contactList=try jsonDecoder.decode([Contact].self, from: data as! Data)
            }
            catch let error{
                
                let generalError=ErrorType.generalError(message: error.localizedDescription)
                observer.onError(generalError)
            }
            
            observer.onNext(())
            observer.onCompleted()
            
        case .failure(let error):
            
            observer.onError(error)
            
        }
        return Disposables.create()
        }
        
        
    }
    
    /*This method check for null keys,in case a dictionry does not contain a certain key this method returns an emty string for value of that key, if the key exsit then it returns the actual value of that key */
    private func checkForNullKey(param:Any)->String{
        
        if case Optional<Any>.some(let val) = param{
            return (val as! String)
        }
        
        return ""
    }
}
