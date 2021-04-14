//
//  MarketsDataClient.swift
//  Market Stream
//
//  Created by Michael Grimmer on 14/4/21.
//

final class MarketsDataClient: MarketsDataClientType {
    // MARK: Initialisation
    
    init(_ marketsAPIClient: MarketsAPIClientType) {
        self.marketsAPIClient = marketsAPIClient
    }
    
    // MARK: MarketsDataClientType Conformance
    
    func listedMarkets(_ completion: @escaping (Result<ListedMarkets, ListedMarketsError>) -> Void) {
        marketsAPIClient.httpGet { result in
            switch result {
            case .success(let apiModel):
                completion(self.processAPIModel(apiModel))
                
            case .failure(let httpError):
                completion(.failure(ListedMarketsError(httpError)))
            }
        }
    }
    
    // MARK: - Private
    
    // MARK: Properties
    
    private let marketsAPIClient: MarketsAPIClientType
    
    // MARK: Functions
    
    private func processAPIModel(_ apiModel: MarketsAPIModel) -> (Result<ListedMarkets, ListedMarketsError>) {
        let listedMarkets = self.transformAPIModel(apiModel)
        
        #if DEBUG
        if !listedMarkets.unknownMarkets.isEmpty {
            self.printCountForUnknownMarkets(listedMarkets.unknownMarkets.count,
                                             listedMarkets.spotMarkets.count,
                                             listedMarkets.futuresMarkets.count)
        } else if listedMarkets.spotMarkets.isEmpty, listedMarkets.futuresMarkets.isEmpty {
            self.printNoMarketsRetrieved()
        }
        #endif
        
        if listedMarkets.spotMarkets.isEmpty, listedMarkets.futuresMarkets.isEmpty, listedMarkets.unknownMarkets.isEmpty {
            return .failure(.noMarketsRetrieved)
        } else {
            return .success(listedMarkets)
        }
    }
    
    private func transformAPIModel(_ apiModel: MarketsAPIModel) -> ListedMarkets {
        var spotMarkets: [SpotMarket] = []
        var futuresMarkets: [FuturesMarket] = []
        var unknownMarkets: [UnknownMarket] = []
        
        apiModel.result.forEach() {
            switch transformMarketType($0.type) {
            case .spot:
                spotMarkets.append(SpotMarket(name: $0.name,
                                              baseCurrency: $0.baseCurrency ?? .empty,
                                              quoteCurrency: $0.quoteCurrency ?? .empty,
                                              enabled: $0.enabled,
                                              lastTradedPrice: $0.last,
                                              restricted: $0.restricted))
                
            case .futures:
                futuresMarkets.append(FuturesMarket(name: $0.name,
                                                    underlying: $0.underlying ?? .empty,
                                                    enabled: $0.enabled,
                                                    lastTradedPrice: $0.last,
                                                    restricted: $0.restricted))
                
            case .unknown:
                unknownMarkets.append(UnknownMarket(name: $0.name,
                                                    baseCurrency: $0.baseCurrency,
                                                    quoteCurrency: $0.quoteCurrency,
                                                    type: $0.type,
                                                    underlying: $0.underlying,
                                                    enabled: $0.enabled,
                                                    lastTradedPrice: $0.last,
                                                    restricted: $0.restricted))
            }
        }
        return (spotMarkets, futuresMarkets, unknownMarkets)
    }
    
    private func transformMarketType(_ type: String) -> MarketType {
        switch type {
        case Constants.spotType:
            return .spot
        case Constants.futuresType:
            return .futures
        default:
            return .unknown
        }
    }
    
    private func printCountForUnknownMarkets(_ unknownMarketsCount: Int, _ spotMarketsCount: Int, _ futuresMarketsCount: Int) {
        print("\n\n██████████████ Unknown Type ███████████████\n")
        print("Unknown markets count: \(unknownMarketsCount)\nSpot markets count: \(spotMarketsCount)\nFutures markets count: \(futuresMarketsCount)")
        print("\n███████████████████████████████████████████\n\n")
    }
    
    private func printNoMarketsRetrieved() {
        print("\n\n██████████████ No Markets █████████████████\n")
        print("No markets have been retrieved successfully")
        print("\n███████████████████████████████████████████\n\n")
    }
}

private enum Constants {
    static let spotType = "spot"
    static let futuresType = "future"
}

private extension ListedMarketsError {
    init(_ httpError: HTTPError) {
        switch httpError {
        case .noNetwork: self = .noNetwork
        case .timeout: self = .timeout
        default: self = .unspecified
        }
    }
}
