//
//  MarketsDataClientType.swift
//  Market Stream
//
//  Created by Michael Grimmer on 14/4/21.
//

protocol MarketsDataClientType {
    func listedMarkets(_ completion: @escaping (Result<ListedMarkets, ListedMarketsError>) -> Void)
}

enum MarketType {
    case spot
    case futures
    case unknown
}

enum ListedMarketsError: Error {
    case noMarketsRetrieved
    case noNetwork
    case timeout
    case unspecified
}

typealias ListedMarkets = (spotMarkets: [SpotMarket], futuresMarkets: [FuturesMarket], unknownMarkets: [UnknownMarket])
