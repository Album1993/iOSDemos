//
//  iOS_DemosTests.swift
//  iOS_DemosTests
//
//  Created by 张一鸣 on 12/01/2018.
//  Copyright © 2018 张一鸣. All rights reserved.
//

import XCTest
@testable import iOS_Demos

class iOS_DemosTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let d =  ViewController()
        d.testDD()
        let v = DispatchGroupViewController();
        v.groupSync2()

    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
