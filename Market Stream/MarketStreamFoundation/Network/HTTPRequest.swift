//
//  HTTPRequest.swift
//  Market Stream
//
//  Created by Michael Grimmer on 10/4/21.
//

struct HTTPRequest: HTTPRequestType {
    // MARK: HTTPRequestType Conformance
    
    var urlPath: String
    var httpMethod: HTTPMethod
    var httpHeaders: HTTPHeaders
    var parameters: HTTPParameters?
    var body: HTTPRequestBody
    var forceLoadIgnoringCache: Bool
    var retryAttempts: Int
    var shouldRetry: Bool
    var correlationId: String?
}
