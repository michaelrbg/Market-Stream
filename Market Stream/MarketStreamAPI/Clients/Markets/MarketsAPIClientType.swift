//
//  MarketsAPIClientType.swift
//  Market Stream
//
//  Created by Michael Grimmer on 11/4/21.
//

protocol MarketsAPIClientType {
    func httpGet(completion: @escaping (Result<MarketsAPIModel, HTTPError>) -> Void)
}
