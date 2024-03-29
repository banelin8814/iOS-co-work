//
//  MockHTTPClient.swift
//  STYLiSHTests
//
//  Created by 陸瑋恩 on 2023/7/21.
//  Copyright © 2023 AppWorks School. All rights reserved.
//

@testable import STYLiSH

// swiftlint:disable force_try
class MockHTTPClient: HTTPClientProtocol {
    
    enum TestCase {
        case success
        case successWithWrongFormat
    }
    
    private let testCase: TestCase
    
    init(testCase: TestCase) {
        self.testCase = testCase
    }
    
    func request(_ stRequest: STRequest, completion: @escaping (Result<Data, STHTTPClientError>) -> Void) {
        switch testCase {
        case .success:
            completion(.success(successData))
        case .successWithWrongFormat:
            completion(.success(successDataWithWrongFormat))
        }
    }
}

extension MockHTTPClient {
    
    private var successData: Data {
        return jsonData(fromFile: "SuccessData")
    }
    
    private var successDataWithWrongFormat: Data {
        return jsonData(fromFile: "SuccessDataWithWrongFormat")
    }
    
    private func jsonData(fromFile file: String) -> Data {
        let url = Bundle(for: type(of: self)).url(forResource: file, withExtension: "json")!
        return try! Data(contentsOf: url)
    }
}
