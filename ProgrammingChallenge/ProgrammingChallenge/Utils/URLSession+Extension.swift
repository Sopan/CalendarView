//
//  URLSession+Extension.swift
//  ProgrammingChallenge
//
//  Created by Sopan Sharma on 2/18/17.
//  Copyright © 2017 Sopan Sharma. All rights reserved.
//

import Foundation

extension URLSession {
    
    func fetch<T>(
        url: URL,
        request: URLSessionDataTaskResponse<T>,
        completion: @escaping (URLSessionResult<T>) -> Void
        ) -> URLSessionDataTask {
        print("Fetching parsable URL: \(url.absoluteString)")
        
        let task = dataTask(with: url, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) in
            let result = request.handle(data: data, error: error)
            DispatchQueue.main.async {
                completion(result)
            }
        })
        task.resume()
        
        return task
    }
    
}
