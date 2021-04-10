//
//  HTTPRequestType.swift
//  Market Stream
//
//  Created by Michael Grimmer on 10/4/21.
//

import Foundation

public protocol HTTPRequestType {
    var urlPath: String { get }
    var httpMethod: HTTPMethod { get }
    var httpHeaders: HTTPHeaders { get }
    var parameters: HTTPParameters? { get }
    var body: HTTPRequestBody { get }
    var forceLoadIgnoringCache: Bool { get }
    var retryAttempts: Int { get }
    var shouldRetry: Bool { get }
    var correlationId: String? { get }
}

public enum HTTPMethod: String {
    case delete = "DELETE"
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    
    var name: String {
        return rawValue
    }
}

public enum HTTPRequestBody {
    case data(Data)
    case empty
}

public typealias HTTPHeaders = [String: String]
public typealias HTTPParameters = [String: String]
