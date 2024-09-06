//
//  HomeService.swift
//  Veganning
//
//  Created by 김민솔 on 8/21/24.
//

import SwiftUI
import Moya

class HomeService {
    static let shared = HomeService()
    static let provider = MoyaProvider<HomeAPI>()
    private init() {}
    
    // MARK: - Network Error
    enum NetworkError: Error {
        case badRequest
        case forbidden
        case unhandledStatusCode(Int)
        case decodingError(Error)
        case customError(String)
        case unknownError(String)
        
        var localizedDescription: String {
            switch self {
            case .badRequest:
                return "Bad Request"
            case .forbidden:
                return "Forbidden"
            case .unhandledStatusCode(let statusCode):
                return "Unhandled status code: \(statusCode)"
            case .decodingError(let error):
                return "Decoding error: \(error.localizedDescription)"
            case .customError(let message):
                return message
            case .unknownError(let message):
                return message
            }
        }
    }
    
    // MARK: - Network Request Handler
    private func handleResponse<T: Codable>(response: Response, completion: @escaping (Result<T, NetworkError>) -> Void) {
        switch response.statusCode {
        case 200:
            do {
                let baseResponse = try JSONDecoder().decode(BaseResponse<T>.self, from: response.data)
                if baseResponse.isSuccess {
                    if let result = baseResponse.data {
                        completion(.success(result))
                    } else {
                        completion(.failure(.customError(baseResponse.message)))
                    }
                } else {
                    completion(.failure(.customError(baseResponse.message)))
                }
            } catch {
                completion(.failure(.decodingError(error)))
            }
        case 400:
            completion(.failure(.badRequest))
        case 403:
            completion(.failure(.forbidden))
        default:
            completion(.failure(.unhandledStatusCode(response.statusCode)))
        }
    }
    
    func getWeeklyStore(completion: @escaping (Result<[WeeklyStoreResponse], NetworkError>) -> Void) {
        HomeService.provider.request(.weeklyStore) { result in
            switch result {
            case .success(let response):
                self.handleResponse(response: response, completion: completion)
            case .failure(let error):
                completion(.failure(.customError(error.localizedDescription)))
            }
        }
    }
}
