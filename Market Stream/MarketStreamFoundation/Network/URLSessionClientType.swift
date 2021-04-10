//
//  URLSessionClientType.swift
//  Market Stream
//
//  Created by Michael Grimmer on 10/4/21.
//

import Foundation

protocol URLSessionClientType {
    func httpDataRequest(_ httpRequest: HTTPRequestType, response: @escaping (Result<HTTPResponse, HTTPError>) -> Void)
}

struct HTTPResponse {
    let header: [AnyHashable: Any]
    let body: HTTPResponseBody
}

enum HTTPError: Error {
    case client(statusCode: Int, apiErrorMessage: APIErrorMessage?)
    case server(statusCode: Int, apiErrorMessage: APIErrorMessage?)
    case other(statusCode: Int, data: Data?)
    case invalidRequestBody(Error)
    case invalidRequest
    case invalidResponseBody(Error)
    case missingResponseBody
    case noNetwork
    case cancelled
    case timeout
    case unknown
}

typealias HTTPResponseBody = Data
typealias APIErrorMessage = String
