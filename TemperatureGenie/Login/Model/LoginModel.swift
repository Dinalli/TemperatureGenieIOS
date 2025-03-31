//
//  LoginModel.swift
//  TemperatureGenie
//
//  Created by Andrew Donnelly on 27/03/2025.
//

import Foundation

public struct LoginToken: Codable {
    public let token: String
    public let expiration: String
    public let alertOnlyMode: Bool
    public let error: String?

    private enum CodingKeys: String, CodingKey {
        case token
        case expiration
        case alertOnlyMode
        case error
    }
}

public struct LoginErrorResponseObject: Codable {
    public let type: String?
    public let title: String?
    public let status: Int?
    public let traceId: String?
    public let errors: listOfErrors

    private enum CodingKeys: String, CodingKey {
        case type
        case title
        case status
        case traceId
        case errors
    }
}

public struct listOfErrors: Codable {
    public let arrayStrings: [String]

    private enum CodingKeys: String, CodingKey {
        case arrayStrings
    }
}

