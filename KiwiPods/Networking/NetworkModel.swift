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
    PUT
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
        }
    }
}

//using our own URLRequestConvertible so that networking library can be updated easily
public protocol URLRequestConvertible {
    func asURLRequest() -> URLRequest?
}

public protocol APIConfigurable: URLRequestConvertible {
    var type: RequestType { get }
    var path: String { get }
    var parameters: [String: Any] { get }
    var headers: [String: String]? { get }
}

public extension APIConfigurable {
    public func asURLRequest() -> URLRequest? {
        var queryItems = ""
        if type == .GET, parameters.count > 0 {
            queryItems = parameters.reduce("?") { (value: String, arg1: (String, Any)) -> String in
                return value + "\(arg1.0)=\(arg1.1)&"
            }
            queryItems.removeLast()
        }
        let url = URL(string: (path + queryItems))
        do {
            var urlRequest = try URLRequest(url: url!, method: type.httpMethod)
            urlRequest.allHTTPHeaderFields = headers
            if type != .GET {
                urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions.prettyPrinted)
            }
            urlRequest.cachePolicy = .reloadIgnoringCacheData
            return urlRequest
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}
public protocol ParameterConvertible: Codable {
    static func objectFrom(json: Any, decoder: JSONDecoder)throws -> ParameterConvertible?
    func toParams()throws -> [String: Any]?
}
public extension ParameterConvertible {
    static public func objectFrom(json: Any, decoder: JSONDecoder) throws -> ParameterConvertible? {
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
            let jsonModel = try decoder.decode(self, from: data)
            return jsonModel
        } catch let error {
            throw error
        }
    }
    public func toParams()throws -> [String: Any]? {
        do {
            let data = try JSONEncoder().encode(self)
            if let dict = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String: Any] {
                return dict
            }
            return nil
        } catch let error {
            throw error
        }
    }
}
public enum Response<ResponseType> where ResponseType: ParameterConvertible {
    public struct ResponseError {
        public let error: Error?
        public let statusCode: Int?
        public let errorValue: [String: Any]?
        public init(error: Error?, statusCode: Int?, errorValue: [String: Any]? = nil) {
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
                
                if let usernameDict = dict["username"] as? [String: Any], let name = usernameDict["name"] as? String, name == "ValidatorError"
                {
                    return "Username is already in use"
                }
                
                if let emailDict = dict["email"] as? [String: Any], let name = emailDict["name"] as? String, name == "ValidatorError"
                {
                    return "Username is already in use"
                }
            }
            
            return nil
        }
    }
    public struct ResponseValue {
        public let value: ResponseType
        public let statusCode: Int?
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
