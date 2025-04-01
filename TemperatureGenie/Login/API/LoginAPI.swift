//
//  LoginAPI.swift
//  TemperatureGenie
//
//  Created by Andrew Donnelly on 27/03/2025.
//

import Foundation
import Combine

private let applicationType = "application/json"
private let contentType = "Content-type"

struct LoginAPI {
    private let jsonDecoder = JSONDecoder()
    private var subscriptions = Set<AnyCancellable>()
    
    func loginUser(username: String, password: String, firebaseToken: String, session: URLSession) -> AnyPublisher<LoginToken, APIError> {
        let urlString = "\(apiPath)/api/Authentication/login"
        guard let downloadURL: URL = URL.init(string: urlString) else {
            return Fail(error: .errorDescription("")).eraseToAnyPublisher()
        }
        var urlRequest: URLRequest = URLRequest.init(url: downloadURL)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue(applicationType, forHTTPHeaderField: contentType)
        let parameterDictionary = ["username": username, "password": password, "FirebaseDeviceToken": "firebaseToken"]
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameterDictionary, options: []) else {
            return Fail(error: .errorDescription("")).eraseToAnyPublisher()
        }
        urlRequest.httpBody = httpBody

        return session
            .dataTaskPublisher(for: urlRequest)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .mapError { error in
                return APIError.errorDescription(error.localizedDescription)
            }
            .flatMap { data, response -> AnyPublisher<LoginToken, APIError> in
                guard let response = response as? HTTPURLResponse else {
                    return Fail(error: .unknown)
                        .eraseToAnyPublisher()
                }
                print(String(data: data, encoding: .utf8))
                if (200...299).contains(response.statusCode) {
                    if let response = try? jsonDecoder.decode(LoginToken.self, from: data) {
                        return Just(response).setFailureType(to: APIError.self)
                            .eraseToAnyPublisher()
                    }
                    do {
                        // if decoding fails, decode as an `ErrorResponse`
                        let error = try jsonDecoder.decode(LoginErrorResponseObject.self, from: data)
                        return Fail(error: APIError.errorDescription(error.errors.arrayStrings.first ?? "Sorry we could not log you in."))
                            .eraseToAnyPublisher()
                    } catch {
                        // if both fail, throw APIError.decoding
                        return Fail(error: APIError.unknown)
                            .eraseToAnyPublisher()
                    }
                } else if response.statusCode == 401 {
                    do {
                        // if decoding fails, decode as an `ErrorResponse`
                        let error = try jsonDecoder.decode(LoginErrorResponseObject.self, from: data)
                        return Fail(error: APIError.errorDescription(error.errors.arrayStrings.first ?? "Sorry we could not log you in."))                            .eraseToAnyPublisher()
                    } catch {
                        // if both fail, throw APIError.decoding
                        return Fail(error: APIError.unknown)
                            .eraseToAnyPublisher()
                    }
                }
                else {
                    return Fail(error: .errorDescription("Sorry we could not log you in."))
                        .eraseToAnyPublisher()
                }
            }.eraseToAnyPublisher()
    }
}
