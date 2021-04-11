//
//  MarketsAPIClient.swift
//  Market Stream
//
//  Created by Michael Grimmer on 11/4/21.
//

import Foundation

final class MarketsAPIClient: MarketsAPIClientType {
    // MARK: - Initializer
    
    init(networkGateway: NetworkGatewayType, jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.networkGateway = networkGateway
        self.jsonDecoder = jsonDecoder
    }
    
    // MARK: - MarketsAPIClientType Conformance
    
    func httpGet(completion: @escaping (Result<MarketsAPIModel, HTTPError>) -> Void) {
        let requestModel = httpRequestModel()
        
        networkGateway.httpDataRequest(requestModel) { result in
            self.decodeResult(result, jsonDecoder: self.jsonDecoder, completion: completion)
        }
    }
    
    // MARK: - Private
    
    // MARK: Properties
    
    private let networkGateway: NetworkGatewayType
    private let jsonDecoder: JSONDecoder
    
    // MARK: Functions
    
    private func httpRequestModel() -> HTTPRequestType {
        HTTPRequest(urlPath: Constants.urlPath,
                    httpMethod: .get,
                    httpHeaders: [:],
                    parameters: nil,
                    body: .empty,
                    forceLoadIgnoringCache: true,
                    retryAttempts: 0,
                    shouldRetry: false,
                    correlationId: nil)
    }
    
    private func decodeResult(_ result: Result<HTTPResponseBody, HTTPError>,
                              jsonDecoder: JSONDecoder,
                              completion: (Result<MarketsAPIModel, HTTPError>) -> Void) {
        switch result {
        case let .success(responseBodyData):
            do {
                let responseModel = try jsonDecoder.decode(MarketsAPIModel.self, from: responseBodyData)
                completion(.success(responseModel))
            } catch {
                completion(.failure(.invalidResponseBody(error)))
            }
            
        case let .failure(httpError):
            completion(.failure(httpError))
        }
    }
}

private enum Constants {
    static let urlPath = "/markets"
}
