//
//  SensorAPI.swift
//  TemperatureGenie
//
//  Created by Andrew Donnelly on 10/04/2025.
//

import Foundation
import Combine

private let applicationType = "application/json"
private let contentType = "Content-type"

struct SensorAPI {
    private let jsonDecoder = JSONDecoder()
    private var subscriptions = Set<AnyCancellable>()
    
    func getSensorsForUser(token: String, session: URLSession) -> AnyPublisher<[UserSensorResponse], APIError> {
        let urlString = "\(apiPath)/api/Temperature/Get"
        guard let downloadURL: URL = URL.init(string: urlString) else {
            return Fail(error: .errorDescription("")).eraseToAnyPublisher()
        }
        var urlRequest: URLRequest = URLRequest.init(url: downloadURL)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue(applicationType, forHTTPHeaderField: contentType)
        urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return session
            .dataTaskPublisher(for: urlRequest)
            .subscribe(on: DispatchQueue.global(qos: .background))
            .receive(on: DispatchQueue.main)
            .mapError { error in
                return APIError.errorDescription(error.localizedDescription)
            }
            .flatMap { data, response -> AnyPublisher<[UserSensorResponse], APIError> in
                guard let response = response as? HTTPURLResponse else {
                    return Fail(error: .unknown)
                        .eraseToAnyPublisher()
                }
                print(String(data: data, encoding: .utf8))
                if (200...299).contains(response.statusCode) {
                    if let response = try? jsonDecoder.decode([UserSensorResponse].self, from: data) {
                        return Just(response).setFailureType(to: APIError.self)
                            .eraseToAnyPublisher()
                    }
                    do {
                        // if decoding fails, decode as an `ErrorResponse`
                        let error = try jsonDecoder.decode(LoginErrorResponseObject.self, from: data)
                        return Fail(error: APIError.errorDescription(error.errors.arrayStrings.first ?? "Sorry we could not get any sensors"))
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
                        return Fail(error: APIError.errorDescription(error.errors.arrayStrings.first ?? "Sorry we could not get any sensors."))                            .eraseToAnyPublisher()
                    } catch {
                        // if both fail, throw APIError.decoding
                        return Fail(error: APIError.unknown)
                            .eraseToAnyPublisher()
                    }
                }
                else {
                    return Fail(error: .errorDescription("Sorry we could not get any sensors"))
                        .eraseToAnyPublisher()
                }
            }.eraseToAnyPublisher()
    }
    
    
    func submitManualAlertReading(token: String, manualReading: ManualReadingSubmission, session: URLSession) -> AnyPublisher<BasicResponseObject, APIError> {
        let urlString = "\(apiPath)/api/Temperature/ManualSensorReading"
        guard let downloadURL: URL = URL.init(string: urlString) else {
            return Fail(error: .errorDescription("")).eraseToAnyPublisher()
        }
        var urlRequest: URLRequest = URLRequest.init(url: downloadURL)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue(applicationType, forHTTPHeaderField: contentType)
        urlRequest.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let encoder = JSONEncoder()
        guard let httpBody = try? encoder.encode(manualReading) else {
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
            .flatMap { data, response -> AnyPublisher<BasicResponseObject, APIError> in
                guard let response = response as? HTTPURLResponse else {
                    return Fail(error: .unknown)
                        .eraseToAnyPublisher()
                }
                print(String(data: data, encoding: .utf8))
                if (200...299).contains(response.statusCode) {
                    return Just(BasicResponseObject(success: true, errorMessage: "")).setFailureType(to: APIError.self)
                        .eraseToAnyPublisher()
                } else if response.statusCode == 401 {
                    do {
                        // if decoding fails, decode as an `ErrorResponse`
                        let error = try jsonDecoder.decode(ManualEntryErrorResponseObject.self, from: data)
                        return Fail(error: APIError.errorDescription(error.errors.arrayStrings.first ?? "Sorry manual submission failed. Please try again later"))                            .eraseToAnyPublisher()
                    } catch {
                        // if both fail, throw APIError.decoding
                        return Fail(error: APIError.unknown)
                            .eraseToAnyPublisher()
                    }
                }
                else {
                    return Fail(error: .errorDescription("Sorry manual submission failed. Please try again later"))
                        .eraseToAnyPublisher()
                }
            }.eraseToAnyPublisher()
    }
    
}
