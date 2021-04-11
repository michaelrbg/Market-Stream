//
//  URLSessionClient.swift
//  Market Stream
//
//  Created by Michael Grimmer on 10/4/21.
//

import Foundation

final class URLSessionClient: URLSessionClientType {
    // MARK: Initialisation
    
    init(_ baseUrl: String, session: URLSessionProtocol = URLSession.shared) {
        self.baseUrl = baseUrl
        self.session = session
    }
    
    // MARK: URLSessionClientType Conformance
    
    func httpDataRequest(_ httpRequest: HTTPRequestType, response: @escaping (Result<HTTPResponse, HTTPError>) -> Void) {
        let updatedHTTPRequest = updateHTTPRequestModel(httpRequest)
        guard let urlRequest = self.urlRequest(httpRequest: updatedHTTPRequest) else {
            response(.failure(.invalidRequest))
            return
        }
        
        session.dataTaskRequest(with: urlRequest) { data, urlResponse, error in
            #if DEBUG
            self.printURLResponse(urlResponse?.description)
            #endif
            
            DispatchQueue.main.async {
                response(self.processResult(data: data, urlResponse: urlResponse, error: error))
            }
        }
    }
    
    // MARK: - Private
    
    // MARK: Properties
    
    private let baseUrl: String
    private let session: URLSessionProtocol
    
    // MARK: Functions
    
    private func updateHTTPRequestModel(_ request: HTTPRequestType) -> HTTPRequestType {
        var httpHeaders = request.httpHeaders
        if let correlationIdValue = request.correlationId {
            httpHeaders[Constants.correlationIdKey] = correlationIdValue
        }
        
        return HTTPRequest(urlPath: request.urlPath,
                           httpMethod: request.httpMethod,
                           httpHeaders: httpHeaders,
                           parameters: request.parameters,
                           body: request.body,
                           forceLoadIgnoringCache: request.forceLoadIgnoringCache,
                           retryAttempts: request.retryAttempts,
                           shouldRetry: request.shouldRetry,
                           correlationId: request.correlationId)
    }
    
    private func urlRequest(httpRequest: HTTPRequestType) -> URLRequest? {
        guard let url = self.buildURL(httpRequest: httpRequest) else { return nil }
        let cachePolicy: NSURLRequest.CachePolicy = httpRequest.forceLoadIgnoringCache ? .reloadIgnoringLocalCacheData : .useProtocolCachePolicy
        var urlRequest = URLRequest(url: url, cachePolicy: cachePolicy)
        
        urlRequest.httpMethod = httpRequest.httpMethod.rawValue
        urlRequest.allHTTPHeaderFields = httpRequest.httpHeaders
        
        switch httpRequest.body {
        case let .data(data):
            urlRequest.httpBody = data
        default:
            break
        }
        
        #if DEBUG
        printURLRequest(urlRequest)
        #endif
        
        return urlRequest
    }
    
    private func buildURL(httpRequest: HTTPRequestType) -> URL? {
        guard let url = URL(string: "\(baseUrl)\(httpRequest.urlPath)") else { return nil }
        
        if let parameters = httpRequest.parameters, var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            urlComponents.percentEncodedQuery = parameters
                .map { (parameter: String, value: String) -> String in
                    parameter + "=" + (value.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? .empty)
                }
                .joined(separator: "&")
            return urlComponents.url
        }
        return url
    }
    
    private func processResult(data: Data?, urlResponse: URLResponse?, error: Error?) -> (Result<HTTPResponse, HTTPError>) {
        if error != nil {
            return processError(error)
        } else if let httpResponse = urlResponse as? HTTPURLResponse {
            return processResponse(httpResponse, data: data)
        } else {
            return .failure(.unknown)
        }
    }
    
    private func processError(_ error: Error?) -> Result<HTTPResponse, HTTPError> {
        guard let error = error as? URLError else {
            return .failure(.invalidRequest)
        }
        
        switch error.code {
        case .notConnectedToInternet:
            return .failure(.noNetwork)
        case .cancelled:
            return .failure(.cancelled)
        case .timedOut:
            return .failure(.timeout)
        default:
            return .failure(.unknown)
        }
    }
    
    private func processResponse(_ httpResponse: HTTPURLResponse, data: Data?) -> (Result<HTTPResponse, HTTPError>) {
        switch httpResponse.statusCode {
        case 200 ... 399:
            return processSuccess(data: data, httpResponse: httpResponse)
        case 400 ... 499:
            return .failure(.client(statusCode: httpResponse.statusCode, apiErrorMessage: apiErrorMessage(data: data)))
        case 500 ... 599:
            return .failure(.server(statusCode: httpResponse.statusCode, apiErrorMessage: apiErrorMessage(data: data)))
        default:
            return .failure(.other(statusCode: httpResponse.statusCode, data: nil))
        }
    }
    
    private func processSuccess(data: Data?, httpResponse: HTTPURLResponse) -> (Result<HTTPResponse, HTTPError>) {
        guard let data = data else {
            return .failure(.missingResponseBody)
        }
        return .success(HTTPResponse(header: httpResponse.allHeaderFields, body: data))
    }
    
    private func apiErrorMessage(data: Data?) -> APIErrorMessage? {
        guard let data = data else { return nil }
        
        let attributedStringOptions: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html
        ]
        guard let apiErrorMessage = try? NSAttributedString(data: data, options: attributedStringOptions, documentAttributes: nil) else {
            return nil
        }
        return apiErrorMessage.string
    }
    
    private func printURLRequest(_ urlRequest: URLRequest) {
        print("\n\n██████████████ HTTP Request ███████████████\n")
        print("URL: \(urlRequest.description)")
        if let httpMethod = urlRequest.httpMethod {
            print("HTTP method: \(httpMethod)")
        }
        if let httpHeaderFields = urlRequest.allHTTPHeaderFields{
            print("HTTP header fields: \(httpHeaderFields)")
        }
        print("HTTP body data length: \(urlRequest.httpBody?.count ?? 0)")
        if let body = urlRequest.httpBody, let bodyText = String(data: body, encoding: .utf8) {
            print("HTTP body text: \(bodyText)")
        }
        print("\n███████████████████████████████████████████\n\n")
    }
    
    private func printURLResponse(_ response: String?) {
        print("\n\n██████████████ HTTP Response ██████████████\n")
        print(response ?? .empty)
        print("\n███████████████████████████████████████████\n\n")
    }
}

private enum Constants {
    static let correlationIdKey = "correlation-id"
}
