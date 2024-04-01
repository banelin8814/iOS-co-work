//
//  APIManager.swift
//  STYLiSH
//
//  Created by NY on 2024/3/30.
//  Copyright © 2024 AppWorks School. All rights reserved.
//

import Foundation

class APIManager {
    
    static let shared = APIManager()
    
    enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
    }

    func sendRequest(urlString: String,
                     method: HTTPMethod,
                     parameters: [String: Any]?,
                     completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if let params = parameters {
            switch method {
            case .get:
                var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
                urlComponents.queryItems = params.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
                request.url = urlComponents.url
            case .post:
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: params, options: [])
                } catch {
                    print("Error encoding parameters: \(error.localizedDescription)")
                    return
                }
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            completion(data, response, error)
        }
        task.resume()
    }

}

//MARK: - Usage Example:

// MARK: Example usage for GET request
//sendRequest(urlString: "https://example.com/api/data",
//            method: .get,
//            parameters: ["key": "value"]) { data, response, error in
//    // Check for errors
//    if let error = error {
//        print("Error: \(error.localizedDescription)")
//        return
//    }
//    
//    // Check for successful response
//    guard let httpResponse = response as? HTTPURLResponse,
//          (200...299).contains(httpResponse.statusCode) else {
//        print("Error: Invalid response")
//        return
//    }
//    
//    // Check if data is available
//    guard let responseData = data else {
//        print("Error: No data received")
//        return
//    }
//    
//    // Parse the data if needed
//    do {
//        // Further processing of the JSON data
//    } catch {
//        print("Error parsing JSON: \(error.localizedDescription)")
//    }
//}
//
//
// MARK: Example usage for POST request

//sendRequest(urlString: "https://example.com/api/post",
//            method: .post,
//            parameters: ["key": "value"]) { data, response, error in
//    // Check for errors
//    if let error = error {
//        print("Error: \(error.localizedDescription)")
//        return
//    }
//    
//    // Check for successful response
//    guard let httpResponse = response as? HTTPURLResponse,
//          (200...299).contains(httpResponse.statusCode) else {
//        print("Error: Invalid response")
//        return
//    }
//    
//    // Check if data is available
//    guard let responseData = data else {
//        print("Error: No data received")
//        return
//    }
//    
//    // Parse the data if needed
//    do {
//        // Further processing of the JSON data
//    } catch {
//        print("Error parsing JSON: \(error.localizedDescription)")
//    }
//}
//

// TODO: 待確認 API 是否有作用？
extension APIManager {
    func fetchComments(forProductId productId: String, completion: @escaping ([CommentForm]?, Error?) -> Void) {
        let urlString = "https://chouyu.site/api/1.0/comments?id=\(productId)"
        sendRequest(urlString: urlString, method: .get, parameters: nil) { data, response, error in
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            guard let data = data, let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                print("Error: Invalid response or no data")
                completion(nil, error)
                return
            }
            
            do {
                // 使用 CommentsResponse 來解析 JSON 數據
                let commentsResponse = try JSONDecoder().decode(CommentsResponse.self, from: data)
                completion(commentsResponse.data, nil)  // 現在使用 commentsResponse.data 來獲取評論數據
            } catch {
                print("Error parsing JSON: \(error.localizedDescription)")
                completion(nil, error)
            }
        }
    }
}


// MARK: - 上傳 App 使用者留言
extension APIManager {
    func postComment(userId: Int, productId: Int, rate: Int, comment: String, completion: @escaping (Bool, Error?) -> Void) {
        let urlString = "https://chouyu.site/api/1.0/comment/create"
        let parameters = [
            "userId": userId,
            "productId": productId,
            "rate": rate,
            "comment": comment
        ] as [String : Any]
        
        sendRequest(urlString: urlString, method: .post, parameters: parameters) { data, response, error in
            guard error == nil else {
                completion(false, error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Error: Invalid response")
                completion(false, nil)
                return
            }
            
            completion(true, nil)
        }
    }
}
