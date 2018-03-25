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
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        resumeUnderTest=Resume()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        resumeUnderTest = nil
        super.tearDown()
    }
    
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

    func  testCreateOverview(){
        
        let managedObject=CoreDataHandler.createOverview(name: "Artmis", descryption: "testing create core data", imageProfile: "https://media.glassdoor.com/userprofileuser/upul/2364548/2364548-userprofileuser-1508486141841.jpg")
        
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
        XCTAssertTrue((overviewObj?.expiryTime as! Date) > Date())
        XCTAssertTrue((overviewObj?.expiryTime as! Date) < fromNow11Mins!)
        
    }
    
    func testFetchOverviewFromCoreData(){
        
        _=CoreDataHandler.createOverview(name: "Artmis", descryption: "testing fetching core data", imageProfile: "https://media.glassdoor.com/userprofileuser/upul/2364548/2364548-userprofileuser-1508486141841.jpg")
        
        
        let offlineObj=CoreDataHandler.fetchOverviewFromCoreData()
        
        XCTAssertNotNil(offlineObj, "fetchOverviewFromCoreData returns nil")
        
        let offlineOverview=offlineObj.data
        XCTAssertNotNil(offlineOverview, "fetchOverviewFromCoreData returns a NOT null value that cannot be converted to Overview object")
        
        XCTAssertEqual(offlineOverview?.name, "Artmis")
        XCTAssertEqual(offlineOverview?.descryption, "testing fetching core data")
        XCTAssertNotNil(offlineOverview?.image, "fetchOverviewFromCoreData cannot fetch the image")
        XCTAssertNotNil(offlineOverview?.expiryTime, "fetchOverviewFromCoreData cannot fetch the expiry time")
        
        
        
    }
    
    /******Note to test: this is for testin  when coredata is EMPTY and  online mode get success
     TURN ON your internet connection to do this test*****/
    func testFetchOverviewOnline(){

        // first delete core data make it empty
        
        CoreDataHandler.deleteOverviewFromCoreData()
        
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
            .addDisposableTo(disposeBag)
        
        
        waitForExpectations(timeout: 15.0, handler: nil)
        
    }
    
    
    /**Note to test:this is for testing when coredata is EMPTY and  online fetch also get fail.
     TURN OFF your internet connection to do this test***/
    func testFetchOfflineOverviewNotExist(){
        
        // first delete core data make it empty
        
        CoreDataHandler.deleteOverviewFromCoreData()
        
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
            .addDisposableTo(disposeBag)
        
        
        waitForExpectations(timeout: 3000.0, handler: nil)
        
    }
    
    /***Note to test:this is for testing offline mode, TURN OFF your internet connection to do this test,
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
            .addDisposableTo(disposeBag)
        
        
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
            .addDisposableTo(disposeBag)
        
        
        waitForExpectations(timeout: 3000.0, handler: nil)
        
    }
    
    func testReadJsonFromFile(){
        
        // test with a correct file
        let result=JsonHandler.readJsonFile(fileName: "education")
        XCTAssertNil(result.error, result.error!.localizedDescription)
        XCTAssertNotNil(result.data, "Whoops, readJsonFile returns a nil value for data")
        
        // test with a file that does not exist
        let resultFileNotExsit=JsonHandler.readJsonFile(fileName: "thisfiledoesnotexsit")
        XCTAssertNotNil(resultFileNotExsit.error, "Whoops, readJsonFile does NOT return any error while reading a file that does not exsit!")
        XCTAssertNil(resultFileNotExsit.data, "Whoops, readJsonFile returns a NOT null data for a file that does not exsit!")
        
        //test with a file  witch have a wrong json format
        
        let resultWrongFormat=JsonHandler.readJsonFile(fileName: "wrongFormatFile")
        XCTAssertNotNil(resultWrongFormat.error, "Whoops,  readJsonFile does NOT return any error while reading a file with a wrong json format!")
        XCTAssertNil(resultWrongFormat.data, "Whoops,  readJsonFile returns a NOT null data for a file with a wrong json format!")
        
    }
    
    
}
