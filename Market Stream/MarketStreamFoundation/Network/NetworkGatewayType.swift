//
//  NetworkGatewayType.swift
//  Market Stream
//
//  Created by Michael Grimmer on 11/4/21.
//

protocol NetworkGatewayType {
    func httpDataRequest(_ httpRequest: HTTPRequestType, response: @escaping (Result<HTTPResponseBody, HTTPError>) -> Void)
}
