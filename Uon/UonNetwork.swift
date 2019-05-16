//
//  UonNetwork.swift
//  Bon
//
//  Created by Chris on 2019/5/16.
//  Copyright © 2019 Chris. All rights reserved.
//

import Foundation
import Alamofire

class BonNetwork: NSObject {
    
    /// post function
    ///
    /// - parameter parameters: JSON
    /// - parameter success:    Request success callback function
    static func post(_ parameters: [String : String]?, success: @escaping (_ value: String) -> Void) {
        
        AF.request(UCAS.URL.LoginURL, method: .post, parameters: parameters)
            .responseString{ response in
                switch response.result {
                case .success(let value):
                    success(value)
                    
                case .failure(let error):
                    print(error)
                }
        }
        
    }
    
    /// post function
    ///
    /// - parameter parameters: JSON
    /// - parameter success:    Request success callback function
    /// - parameter fail:       Request failure callback function
    static func post(_ parameters: [String : String]?, success: @escaping (_ value: String) -> Void, fail: @escaping (_ error : Any) -> Void) {
        
        AF.request(UCAS.URL.LoginURL, method: .post, parameters: parameters)
            .responseString{ response in
                switch response.result {
                case .success(let value):
                    success(value)
                    
                case .failure(let error):
                    fail(error)
                }
        }
        
    }
    
    /// post function
    ///
    /// - parameter success:    Request success callback function
    static func get(URL: String, success: @escaping (_ value: String) -> Void) {
        
        AF.request(URL, method: .get)
            .responseString{ response in
                switch response.result {
                case .success(let value):
                    success(value)
                    
                case .failure(let error):
                    print(error)
                }
        }
        
    }
    
    /// get function
    ///
    /// - parameter success:    Request success callback function
    /// - parameter fail:       Request failure callback function
    static func get(URL: String, success: @escaping (_ value: String) -> Void, fail: @escaping (_ error : Any) -> Void) {
        
        AF.request(URL, method: .get)
            .responseString{ response in
                switch response.result {
                case .success(let value):
                    success(value)
                    
                case .failure(let error):
                    fail(error)
                }
        }
        
    }
    
    /// get query string function
    static func getQueryString() -> String {
        
        AF.request(UCAS.URL.RedirectorURL, method: .get)
            .response{ response in
                let responseURL = response.response!.url!
                let queryString = responseURL.absoluteString.replacingOccurrences(of: UCAS.URL.RemovedURL, with: "")
                BonUserDefaults.queryString = queryString
        }
        
        return BonUserDefaults.queryString
    }
    
    
    @objc static func logout() {
        
        BonNetwork.get(URL: UCAS.URL.LogoutURL, success: { (value) in
        })
        loginState = .offline
        
    }
    
}
