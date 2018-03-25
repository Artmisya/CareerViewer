//
//  CareerViewerTests.swift
//  CareerViewerTests
//
//  Created by Saeedeh on 25/03/2018.
//  Copyright © 2018 tiseno. All rights reserved.
//

import XCTest
@testable import CareerViewer

class CareerViewerTests: XCTestCase {
    
     var resumeUnderTest: Resume!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
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
        
        let overviewObj=CoreDataHandler.createOverview(name: "Artmis", descryption: "testing fetching core data", imageProfile: "https://media.glassdoor.com/userprofileuser/upul/2364548/2364548-userprofileuser-1508486141841.jpg")
        
        
        let offlineObj=CoreDataHandler.fetchOverviewFromCoreData()
        
        XCTAssertNotNil(offlineObj, "fetchOverviewFromCoreData returns nil")
        
        let offlineOverview=offlineObj.data
        XCTAssertNotNil(offlineOverview, "fetchOverviewFromCoreData returns a NOT null value that cannot be converted to Overview object")
        
        XCTAssertEqual(offlineOverview?.name, "Artmis")
        XCTAssertEqual(offlineOverview?.descryption, "testing fetching core data")
        XCTAssertNotNil(offlineOverview?.image, "fetchOverviewFromCoreData cannot fetch the image")
         XCTAssertNotNil(offlineOverview?.expiryTime, "fetchOverviewFromCoreData cannot fetch the expiry time")
        
        
        
    }
    
    
}
