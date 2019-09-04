//
//  NetworkModel.swift
//  topfan-3-ios
//
//  Created by Ayush Awasthi on 28/11/18.
//  Copyright © 2018 KiwiTech. All rights reserved.
//

import UIKit
import Alamofire

public enum RequestType: String {
    case POST,
    GET,
    DELETE,
    PUT,
    HEAD,
    PATCH
    
    public var httpMethod: HTTPMethod {
        switch self {
        case .POST:
            return HTTPMethod.post
        case .GET:
            return HTTPMethod.get
        case .DELETE:
            return HTTPMethod.delete
        case .PUT:
            return HTTPMethod.put
        case .HEAD:
            return .head
        case .PATCH:
            return .patch
        }
    }
}

//using our own URLRequestConvertible so that networking library can be updated easily
public protocol URLRequestConvertible {
    func asURLRequest() throws -> URLRequest
}

public protocol APIConfigurable: URLRequestConvertible {
    var type: RequestType { get }
    var path: String { get }
    var parameters: [String: Any] { get }
    var headers: [String: String]? { get }
}

public extension APIConfigurable {
    func asURLRequest() throws -> URLRequest {
        let url = URL(string: path)
        do {
            var urlRequest = try URLRequest(url: url!, method: type.httpMethod)
            let encoding = URLEncoding()
            urlRequest = try encoding.encode(urlRequest, with: parameters)
            var apiHeaders = self.headers
            //check if `Content-Type` is provided
            // if `Content-Type` are not provided then add `application/json` as default
//            if let headers = apiHeaders {
//                if headers["Content-Type"] == nil {
//                    apiHeaders?["Content-Type"] = "application/json"
//                }
//            } else {
//                apiHeaders = [:]
//                apiHeaders?["Content-Type"] = "application/json"
//            }
            urlRequest.allHTTPHeaderFields = apiHeaders
            return urlRequest
        } catch {
            throw error
        }
    }
}
public protocol ParameterConvertible: Codable {
    static func objectFrom(json: Any, decoder: JSONDecoder)throws -> Self?
    func toParams()throws -> [String: Any]?
}
public extension ParameterConvertible {
    static public func objectFrom(json: Any, decoder: JSONDecoder = JSONDecoder()) throws -> Self? {
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let jsonModel = try decoder.decode(self, from: data)
            return jsonModel
        } catch let error {
            throw error
        }
    }
    public func toParams()throws -> [String: Any]? {
        do {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            let data = try encoder.encode(self)
            let dict = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any]
            return dict
        } catch let error {
            throw error
        }
    }
}
public typealias APIError<Type: ParameterConvertible> = Response<Type>.ResponseError
public enum Response<ResponseType> where ResponseType: ParameterConvertible {
    public struct ResponseError {
        public let error: Error?
        public let statusCode: Int?
        public let errorValue: [String: Any]?
        public init(error: Error?, statusCode: Int? = nil, errorValue: [String: Any]? = nil) {
            self.error = error
            self.statusCode = statusCode
            self.errorValue = errorValue
        }
        public func errorMessage() -> String?
        {
            if let dict = errorValue
            {
                if let error = dict["error"] as? String {
                    return error
                }
                if let errors = dict["errors"] as? [String: Any], let error = errors["error"] as? String, error.count > 0
                {
                    return error
                }
                if let error = dict["status"] as? String, error.count > 0
                {
                    return error
                }
            }
            return nil
        }
    }
    public struct ResponseValue {
        public let value: ResponseType
        public let statusCode: Int?
        public init(value: ResponseType, statusCode: Int?) {
            self.value = value
            self.statusCode = statusCode
        }
    }
    case success(ResponseValue),
    failed(ResponseError)
    
    public var responseError: ResponseError? {
        switch self {
        case .success:
            return nil
        case .failed(let value):
            return value
        }
    }
    
    public var value: ResponseType? {
        switch self {
        case .success(let value):
            return value.value
        case .failed:
            return nil
        }
    }
    public var error: Error? {
        switch self {
        case .failed(let error):
            return error.error
        case .success:
            return nil
        }
    }
    public var statusCode: Int? {
        switch self {
        case .success(let response):
            return response.statusCode
        case .failed(let response):
            return response.statusCode
        }
    }
    public var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failed:
            return false
        }
    }
}
public enum APIErrors: Error {
    case noDataRecieved,
    parserError,
    oauthTokenError,
    invalidRequest(String),
    cancelled
}
