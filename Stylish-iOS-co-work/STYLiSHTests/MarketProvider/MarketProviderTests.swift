//
//  MarketProviderTests.swift
//  STYLiSHTests
//
//  Created by 陸瑋恩 on 2023/7/20.
//  Copyright © 2023 AppWorks School. All rights reserved.
//

import XCTest
@testable import STYLiSH

class MarketProviderTests: XCTestCase {
    
    var sut: MarketProvider!
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testFetchHotsSuccess() {
        let httpClient = MockHTTPClient(testCase: .success)
        sut = MarketProvider(httpClient: httpClient)
        
        let expectation = expectation(description: "Hots data request")
        sut.fetchHots { result in
            let isSuccess: Bool
            let hotsCount: Int?
            
            switch result {
            case let .success(hots):
                isSuccess = true
                hotsCount = hots.count
            case .failure:
                isSuccess = false
                hotsCount = nil
            }
            XCTAssertEqual(isSuccess, true)
            XCTAssertEqual(hotsCount, 2)
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3)
    }
    
    func testFetchHotsSuccessWithWrongFormat() {
        let httpClient = MockHTTPClient(testCase: .successWithWrongFormat)
        sut = MarketProvider(httpClient: httpClient)
        
        let expectation = expectation(description: "Hots data request")
        sut.fetchHots { result in
            let isSuccess: Bool
            let hotsCount: Int?
            
            switch result {
            case let .success(hots):
                isSuccess = true
                hotsCount = hots.count
            case .failure:
                isSuccess = false
                hotsCount = nil
            }
            XCTAssertEqual(isSuccess, true)
            XCTAssertEqual(hotsCount, 1)
            
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3)
    }
}
