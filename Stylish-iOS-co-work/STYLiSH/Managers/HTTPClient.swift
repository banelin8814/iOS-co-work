//
//  HTTPClient.swift
//  STYLiSH
//
//  Created by WU CHIH WEI on 2019/2/13.
//  Copyright © 2019 AppWorks School. All rights reserved.
//

import Foundation

enum STHTTPClientError: Error {
    case decodeDataFail
    case clientError(Data)
    case serverError
    case unexpectedError
    case urlSessionError(Error)
}

enum STHTTPMethod: String {
    case GET
    case POST
}

enum STHTTPHeaderField: String {
    case contentType = "Content-Type"
    case auth = "Authorization"
}

enum STHTTPHeaderValue: String {
    case json = "application/json"
}

protocol STRequest {
    var headers: [String: String] { get }
    var body: Data? { get }
    var method: String { get }
    var endPoint: String { get }
}

extension STRequest {
    
    func makeRequest() -> URLRequest {
        let urlString = Bundle.STValueForString(key: STConstant.urlKey) + endPoint
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        request.httpBody = body
        request.httpMethod = method
        return request
    }
}

protocol HTTPClientProtocol {
    func request(_ stRequest: STRequest, completion: @escaping (Result<Data, STHTTPClientError>) -> Void)
}

class HTTPClient: HTTPClientProtocol {

    func request(
        _ stRequest: STRequest,
        completion: @escaping (Result<Data, STHTTPClientError>) -> Void
    ) {
        URLSession.shared.dataTask(
            with: stRequest.makeRequest(),
            completionHandler: { (data, response, error) in
                if let error = error {
                    completion(.failure(.urlSessionError(error)))
                    return
                }
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(.unexpectedError))
                    return
                }
                
                let statusCode = httpResponse.statusCode
                switch statusCode {
                case 200..<300:
                    completion(.success(data!))
                case 400..<500:
                    completion(.failure(.clientError(data!)))
                case 500..<600:
                    completion(.failure(.serverError))
                default:
                    completion(.failure(.unexpectedError))
                }
            }).resume()
    }
}
