//
//  NetworkManager.swift
//  topfan-3-ios
//
//  Created by KiwiTech on 12/07/18.
//  Copyright © 2018 KiwiTech. All rights reserved.
//

import UIKit
import Alamofire
public typealias Completion<Model: ParameterConvertible> = (Response<Model>) -> Void
open class NetworkManager: NSObject {
    static public let shared = NetworkManager()
    private override init() {
        super.init()
    }
    public func hitApi<ModelClass: ParameterConvertible>(urlRequest: URLRequest, decoder: JSONDecoder = JSONDecoder(), completion: @escaping Completion<ModelClass>) {
        Alamofire.request(urlRequest).validate().responseJSON { (response) in
            
            var errorValue: [String: Any]? = [:]
            if let data = response.data {
                let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                errorValue = json as? [String: Any]
            }
            
            switch response.result {
            case .success(let value):
                do {
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    if let obj = try ModelClass.objectFrom(json: value, decoder: decoder) {
                        let model = Response.ResponseValue(value: obj, statusCode: response.response?.statusCode)
                        completion(Response.success(model))
                    } else {
                        /*let className = String(describing: ModelClass.self)
                        fatalError("Can not parse response in provided model type: \(className)")*/
                        
                        completion(Response.failed(APIError(error: APIErrors.parserError, statusCode: response.response?.statusCode, errorValue: errorValue)))
                    }
                } catch let error {
                    completion(Response.failed(APIError(error: error, statusCode: response.response?.statusCode, errorValue: errorValue)))
                }
            case .failure(let error):
                completion(Response.failed(APIError(error: error, statusCode: response.response?.statusCode, errorValue: errorValue)))
            }
        }
    }
}
