//
//  CareerViewerTests.swift
//  CareerViewerTests
//
//  Created by Saeedeh on 25/03/2018.
//  Copyright © 2018 tiseno. All rights reserved.
//

import XCTest
import RxSwift

@testable import CareerViewer

class CareerViewerTests: XCTestCase {
    
    var resumeUnderTest: Resume!
    var coreDataHandlerUnderTest:CoreDataHandler!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        resumeUnderTest=Resume()
        coreDataHandlerUnderTest=CoreDataHandler()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        resumeUnderTest = nil
        coreDataHandlerUnderTest=nil
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func  testCreateOverview(){
        
        
        let managedObject=coreDataHandlerUnderTest.createOverview(name: "Artmis", descryption: "testing create core data", imageProfile: "https://media.glassdoor.com/userprofileuser/upul/2364548/2364548-userprofileuser-1508486141841.jpg")
        
        let startDate=Date()
        let calendar = Calendar.current
        let fromNow11Mins = calendar.date(byAdding: .minute, value: 11, to: startDate)
        
        XCTAssertNotNil(managedObject, "createOverview returns nil")
        
        let overviewObj=managedObject as! Overview?
        XCTAssertNotNil(overviewObj, "createOverview returns a NOT null value that cannot be converted to Overview object")
        
        XCTAssertEqual(overviewObj?.name, "Artmis")
        XCTAssertEqual(overviewObj?.descryption, "testing create core data")
        XCTAssertNotNil(overviewObj?.image, "createOverview cannot fetch the image")
        XCTAssertNotNil(overviewObj?.expiryTime, "expiryTime is null")
        
        // make sure expiry time time is within 10 mins
        XCTAssertTrue((overviewObj?.expiryTime! as! Date) > Date())
        XCTAssertTrue((overviewObj?.expiryTime! as! Date) < fromNow11Mins!)
        
        
        
    }
    
    func testFetchOverviewFromCoreData(){
        
        _=coreDataHandlerUnderTest.createOverview(name: "Artmis", descryption: "testing fetching core data", imageProfile: "https://media.glassdoor.com/userprofileuser/upul/2364548/2364548-userprofileuser-1508486141841.jpg")
        
        
        let offlineObj=coreDataHandlerUnderTest.fetchOverviewFromCoreData()
        
        XCTAssertNotNil(offlineObj, "fetchOverviewFromCoreData returns nil")
        
        let offlineOverview=offlineObj.data
        XCTAssertNotNil(offlineOverview, "fetchOverviewFromCoreData returns a NOT null value that cannot be converted to Overview object")
        
        XCTAssertEqual(offlineOverview?.name, "Artmis")
        XCTAssertEqual(offlineOverview?.descryption, "testing fetching core data")
        XCTAssertNotNil(offlineOverview?.image, "fetchOverviewFromCoreData cannot fetch the image")
        XCTAssertNotNil(offlineOverview?.expiryTime, "fetchOverviewFromCoreData cannot fetch the expiry time")
        
    }
    
    /******Note to test: this test is for when coredata is EMPTY and  online mode get success
     TURN ON your internet connection to do this test*****/
    func testFetchOverviewOnline(){
        
        // first delete core data make it empty
        
        coreDataHandlerUnderTest.deleteOverviewFromCoreData()
        
        // now go for  test
        let disposeBag = DisposeBag()
        
        let e = expectation(description: "observer handler invoked")
        
        resumeUnderTest.fetchOverview().subscribe(
            
            onNext: { isOutDated in
                
                //successfully get data from API
                XCTAssertNotNil(self.resumeUnderTest.overview, "Whoops! Api was succes but overview has not been initialized!")
                XCTAssertFalse(isOutDated, "Whoops! isOutDated is true even when it load online")
                
                
        },
            onError: { error in
                
                
                XCTAssertNotNil(error, "Whoops,  Api was fail but no error has been returned")
                e.fulfill()
                XCTAssertNil(self.resumeUnderTest.overview, "Whoops! Api was fail to retun a response but overview has been initialized!")
                
                
        },
            onCompleted: {
                
                XCTAssertNotNil(self.resumeUnderTest.overview, "Whoops! onCompleted was called but overview has not been initialized!")
                
                e.fulfill()
                
        }, onDisposed: nil)
            .disposed(by: disposeBag)
        
        
        waitForExpectations(timeout: 15.0, handler: nil)
        
    }
    
    
    /**Note to test:this test is for when coredata is EMPTY and  online fetch also get fail.
     TURN OFF your internet connection to do this test***/
    func testFetchOfflineOverviewNotExist(){
        
        // first delete core data make it empty
        
        coreDataHandlerUnderTest.deleteOverviewFromCoreData()
        
        let disposeBag = DisposeBag()
        
        let e = expectation(description: "observer handler invoked")
        
        resumeUnderTest.fetchOverview().subscribe(
            
            onNext: {isOutDated in
                
                XCTAssertTrue(1==1," it is fail but calling onNext!")
                
                
        },
            onError: { error in
                
                XCTAssertNil(self.resumeUnderTest.overview, "Whoops! Api was fail to retun a response but overview has been initialized!")
                XCTAssertNotNil(error, "Whoops,  Api was fail but no error has been returned")
                e.fulfill()
                
        },
            onCompleted: {
                
                XCTAssertNotNil(self.resumeUnderTest.overview, "Whoops! onCompleted was called but overview has not been initialized!")
                e.fulfill()
                
        }, onDisposed: nil)
            .disposed(by: disposeBag)
        
        
        waitForExpectations(timeout: 3000.0, handler: nil)
        
    }
    
    /***Note to test:this test is for offline mode, TURN OFF your internet connection to do this test,
     and make sure to call this test LESS than 10 mins AFTER calling testFetchOverviewOnline()*/
    func testFetchOfflineOverviewNotExpired(){
        
        let disposeBag = DisposeBag()
        
        let e = expectation(description: "observer handler invoked")
        
        resumeUnderTest.fetchOverview().subscribe(
            
            onNext: {isOutDated in
                
                //successfully get data from core data
                XCTAssertNotNil(self.resumeUnderTest.overview, "Whoops! Api was succes but overview has not been initialized!")
                XCTAssertFalse(isOutDated, "Whoops! isOutDated is  true")
                
        },
            onError: { error in
                
                XCTAssertNil(self.resumeUnderTest.overview, "Whoops! Api was fail to retun a response but overview has been initialized!")
                XCTAssertNotNil(error, "Whoops,  Api was fail but no error has been returned")
                e.fulfill()
                
        },
            onCompleted: {
                
                XCTAssertNotNil(self.resumeUnderTest.overview, "Whoops! onCompleted was called but overview has not been initialized!")
                e.fulfill()
                
        }, onDisposed: nil)
            .disposed(by: disposeBag)
        
        
        waitForExpectations(timeout: 3000.0, handler: nil)
        
    }
    
    /*******Note to test:this is for testing offline mode, TURN OFF your internet connection to do this test,
     make sure to call this test MORE than 10 mins AFTER calling testFetchOverviewOnline()*/
    func testFetchOfflineOverviewExpired(){
        
        let disposeBag = DisposeBag()
        
        let e = expectation(description: "observer handler invoked")
        
        resumeUnderTest.fetchOverview().subscribe(
            
            onNext: {isOutDated in
                
                //successfully get a outdated data from core data
                XCTAssertNotNil(self.resumeUnderTest.overview, "Whoops! Api was succes but overview has not been initialized!")
                XCTAssertTrue(isOutDated, "Whoops! isOutDated is not true")
                
        },
            onError: { error in
                
                XCTAssertNil(self.resumeUnderTest.overview, "Whoops! Api was fail to retun a response but overview has been initialized!")
                XCTAssertNotNil(error, "Whoops,  Api was fail but no error has been returned")
                e.fulfill()
                
        },
            onCompleted: {
                
                XCTAssertNotNil(self.resumeUnderTest.overview, "Whoops! onCompleted was called but overview has not been initialized!")
                e.fulfill()
                
        }, onDisposed: nil)
            .disposed(by: disposeBag)
        
        
        waitForExpectations(timeout: 3000.0, handler: nil)
        
    }
    
    func testReadJsonFromFile(){
        
        // test with a correct file
        let result=JsonHandler.readJsonFile(fileName: "education")
        
        XCTAssert(try result.assertIsSuccess())
        
        
        // test with a file that does not exist
        let resultFileNotExsit=JsonHandler.readJsonFile(fileName: "thisfiledoesnotexsit")
        XCTAssert(try resultFileNotExsit.assertIsFailure())
        
        
    }
    
}


// MARK: Helpers
private extension Result {
    
    func assertIsSuccess() throws -> Bool {
        switch self {
        case .success(_):
            return true
        case .failure(_):
            throw ErrorType.generalError(message: "Expected .success, got .\(self)")
        }
    }
    func assertIsFailure() throws -> Bool {
        switch self {
        case .success(_):
            throw ErrorType.generalError(message: "Expected .failure, got .\(self)")
        case .failure(_):
            return true
        }
    }
}
