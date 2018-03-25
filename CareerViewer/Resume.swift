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
                        
                        
                        let data=info as? [String: Any]
                        
                        // online load was successfull
                        if let overviewData=data?["data"] as? [String: String]{
                        
                            let descryption=self.checkForNullKey(param:overviewData["descryption"] as Any)
                            let imageUrl=self.checkForNullKey(param:overviewData["profile_image"] as Any)
                            let name=self.checkForNullKey(param:overviewData["name"] as Any)

                            // update core data with latest data from api
                            self.overview=CoreDataHandler.createOverview(name:name,descryption:descryption,imageProfile:imageUrl ) as! Overview?
                            
                            //return result to viewcontroller
                            let isOutDated=false
                            observer.onNext(isOutDated)
                            observer.onCompleted()
                        
                        }
                        else{
                            
                            // api does not return a response in a proper format
                            
                            // try to load an expired overview if there is any
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
                                let userError=ErrorType.generalError(message: ErrorMessage.apiFail.rawValue)
                                observer.onError(userError)

                            }
                            
                        }
                        
                        
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
            if let jsonData=result.data{
                
                self.educationList=[Education]()
                let educationDic=jsonData["data"] as! NSArray
                
                for type in (educationDic as? [[String:Any]])!{
                    
                    let degree=self.checkForNullKey(param:type["degree"] as Any)
                    let avg=self.checkForNullKey(param:type["avg"] as Any)
                    let university=self.checkForNullKey(param:type["university"] as Any)
                    let duration=self.checkForNullKey(param:type["duration"] as Any)

                    let education=Education(degree: degree, avg: avg, university: university, duration: duration)
                    
                    
                    self.educationList?.append(education)
                    
                }
                
                observer.onNext()
                observer.onCompleted()
                
            }
            else{
                
                observer.onError(result.error!)
            }
            return Disposables.create()
        }
        
        
    }
    
    //this method fetch work experience from json file and initialize the work experience list
    
    func  fetchWorkExperience()-> Observable<Void> {return Observable.create
        { observer -> Disposable in
            
            
            let result = JsonHandler.readJsonFile(fileName: "workExperience")
            if let jsonData=result.data{
                
                self.workExperienceList=[WorkExperience]()
                let workExperienceDic=jsonData["data"] as! NSArray
                
                for type in (workExperienceDic as? [[String:Any]])!{
                    
                    print (type)
                    
                    let role=self.checkForNullKey(param:type["role"] as Any)
                    let company=self.checkForNullKey(param:type["company"] as Any)
                    let duration=self.checkForNullKey(param:type["duration"] as Any)
                    let descryption=self.checkForNullKey(param:type["descryption"] as Any)

                    let workExperience=WorkExperience(role: role,company: company, duration: duration,descryption:descryption)
                    
                    self.workExperienceList?.append(workExperience)
                    
                }
                
                observer.onNext()
                observer.onCompleted()
                
            }
            else{
                
                observer.onError(result.error!)
            }
            return Disposables.create()
        }
        
        
    }
    
    
    //this method fetch work skills from json file and initialize the skill list
    
    func  fetchSkills()-> Observable<Void> {return Observable.create
        { observer -> Disposable in
            
            
            let result = JsonHandler.readJsonFile(fileName: "skill")
            if let jsonData=result.data{
                
                self.skillList=[Skill]()
                let skillDic=jsonData["data"] as! NSArray
                
                for type in (skillDic as? [[String:Any]])!{
                    
                    
                    let title=self.checkForNullKey(param:type["title"] as Any)
                    let rate=self.checkForNullKey(param:type["rate"] as Any)
                    
                    let skill=Skill(title:title,rate:rate)
                    
                    self.skillList?.append(skill)
                    
                }
                
                observer.onNext()
                observer.onCompleted()
                
            }
            else{
                
                observer.onError(result.error!)
            }
            return Disposables.create()
        }
        
        
    }

    //this method fetch contacts from json file and initialize the contact list
    
    func  fetchContacts()-> Observable<Void> {return Observable.create
        { observer -> Disposable in
            
            let result = JsonHandler.readJsonFile(fileName: "contact")
            if let jsonData=result.data{
                
                self.contactList=[Contact]()
                let contactDic=jsonData["data"] as! NSArray
                
                for dic in (contactDic as? [[String:Any]])!{
                    
                    
                    let stringType=self.checkForNullKey(param:dic["type"] as Any)

                    
                    if let type = ContactType(rawValue: stringType){
                        
                        let value=self.checkForNullKey(param:dic["value"] as Any)
                        let contact=Contact(type: type, value: value)
                        
                        self.contactList?.append(contact)
                    }
                    
                }
                
                observer.onNext()
                observer.onCompleted()
            }
            else{
                
                observer.onError(result.error!)
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
