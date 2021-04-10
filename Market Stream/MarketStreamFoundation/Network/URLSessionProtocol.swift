//
//  URLSessionProtocol.swift
//  Market Stream
//
//  Created by Michael Grimmer on 10/4/21.
//

import Foundation

protocol URLSessionProtocol {
    func dataTaskRequest(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void)
}

extension URLSession: URLSessionProtocol {
    // MARK: URLSessionProtocol Conformance
    
    func dataTaskRequest(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        let urlSessionDataTask = dataTask(with: request, completionHandler: completionHandler)
        urlSessionDataTask.resume()
    }
}
