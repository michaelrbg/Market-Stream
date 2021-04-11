//
//  NetworkGateway.swift
//  Market Stream
//
//  Created by Michael Grimmer on 11/4/21.
//

final class NetworkGateway: NetworkGatewayType {
    // MARK: - Initialization
    
    init(_ urlSessionClient: URLSessionClientType) {
        self.urlSessionClient = urlSessionClient
    }
    
    // MARK: - NetworkGatewayType Conformance
    
    func httpDataRequest(_ httpRequest: HTTPRequestType, response: @escaping (Result<HTTPResponseBody, HTTPError>) -> Void) {
        sendHTTPRequest(httpRequest: httpRequest, response: response)
    }
    
    // MARK: - Private
    
    // MARK: Properties
    
    private let urlSessionClient: URLSessionClientType
    
    // MARK: - Functions
    
    private func sendHTTPRequest(httpRequest: HTTPRequestType, response: @escaping (Result<HTTPResponseBody, HTTPError>) -> Void) {
        urlSessionClient.httpDataRequest(httpRequest, response: { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .failure(error):
                self.handleHTTPRequestFailure(error: error,
                                              result: .failure(error),
                                              httpRequest: httpRequest,
                                              response: response)
            case let .success(httpResponse):
                response(.success(httpResponse.body))
            }
        })
    }
    
    private func handleHTTPRequestFailure(error: HTTPError,
                                          result: Result<HTTPResponseBody, HTTPError>,
                                          httpRequest: HTTPRequestType,
                                          response: @escaping (Result<HTTPResponseBody, HTTPError>) -> Void) {
        switch error {
        case let .client(statusCode, apiErrorMessage):
            #if DEBUG
            printErrorDetails(error, statusCode, apiErrorMessage)
            #endif
            
            response(result)
            
        case let .server(statusCode, apiErrorMessage):
            #if DEBUG
            printErrorDetails(error, statusCode, apiErrorMessage)
            #endif
            
            if statusCode == Constants.gatewayTimeoutCode,
               httpRequest.retryAttempts < Constants.maxRetryAttempts,
               httpRequest.shouldRetry {
                let updatedRequest = HTTPRequest(urlPath: httpRequest.urlPath,
                                                 httpMethod: httpRequest.httpMethod,
                                                 httpHeaders: httpRequest.httpHeaders,
                                                 parameters: httpRequest.parameters,
                                                 body: httpRequest.body,
                                                 forceLoadIgnoringCache: httpRequest.forceLoadIgnoringCache,
                                                 retryAttempts: httpRequest.retryAttempts + Constants.attemptsIncrement,
                                                 shouldRetry: httpRequest.shouldRetry,
                                                 correlationId: httpRequest.correlationId)
                
                sendHTTPRequest(httpRequest: updatedRequest, response: response)
            } else {
                response(result)
            }
            
        default:
            #if DEBUG
            printErrorDetails(error, nil, nil)
            #endif
            
            response(result)
        }
    }
    
    private func printErrorDetails(_ httpError: HTTPError,_ statusCode: Int?, _ apiErrorMessage: String?) {
        print("\n\n██████████████ HTTP Error █████████████████\n")
        if statusCode == nil, apiErrorMessage == nil {
            print("HTTP error: \(httpError)")
        }
        if let code = statusCode {
            print("Status code: \(code)")
        }
        if let errorMessage = apiErrorMessage {
            print("Error message:\n\(errorMessage)")
        }
        print("\n███████████████████████████████████████████\n\n")
    }
}

private enum Constants {
    static let gatewayTimeoutCode = 504
    static let maxRetryAttempts = 3
    static let attemptsIncrement = 1
}
