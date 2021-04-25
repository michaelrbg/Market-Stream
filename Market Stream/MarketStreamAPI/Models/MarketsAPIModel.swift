//
//  MarketsAPIModel.swift
//  Market Stream
//
//  Created by Michael Grimmer on 11/4/21.
//

struct MarketsAPIModel: Codable {
    let success: Bool
    let result: [MarketAPIModel]
}

struct MarketAPIModel: Codable {
    let name: String
    let baseCurrency: String?
    let quoteCurrency: String?
    let type: String
    let underlying: String?
    let enabled: Bool
    let ask: Double
    let bid: Double
    let last: Double?
    let postOnly: Bool
    let priceIncrement: Double
    let sizeIncrement: Double
    let restricted: Bool
}
