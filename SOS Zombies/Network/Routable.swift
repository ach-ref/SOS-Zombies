//
//  Routable.swift
//  SOS Zombies
//
//  Created by Achref Marzouki on 21/4/21.
//

import Alamofire

public typealias Json = [String : Any]

/// A type adopting the URLRequestConvertible protocol that can be used to construct an url request.
public protocol Routable: URLRequestConvertible {
    static var baseUrl: String { get }
    var method: HTTPMethod { get }
    var path: String { get }
    var params: Parameters? { get }
    var bodyParams: Any? { get }
    var headers: HTTPHeaders? { get }
    var timeOut: TimeInterval { get }
    var token: String? { get }
}

// MARK: - Url request convertible conformance

public extension Routable {
    
    var timeOut: TimeInterval {
        return 10.0
    }
    
    var params: Parameters? {
        return nil
    }
    
    var bodyParams: Any? {
        return nil
    }
    
    /// Returns a URL request or throws if an `Error` was encountered.
    ///
    /// - throws: An `Error` if the underlying `URLRequest` is `nil`.
    ///
    /// - returns: An URL request.
    func asURLRequest() throws -> URLRequest {
        // url
        var url = try type(of: self).baseUrl.asURL()
        url.appendPathComponent(path)
        
        // url request
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.timeoutInterval = timeOut
        
        // toekn
        if let _ = token {
            let stringToken = "Bearer \(token!)"
            urlRequest.setValue(stringToken, forHTTPHeaderField: C.Keys.HTTP_HEADER_AUTHORIZATION)
        }
        
        // headers
        if let httpHeaders = headers {
            for header in httpHeaders {
                urlRequest.setValue(header.value, forHTTPHeaderField: header.name)
            }
        }
        
        // request params
        if let parameters = bodyParams {
            if let data = parameters as? Data {
                urlRequest.httpBody = data
            }
            else {
                urlRequest = try JSONEncoding.default.encode(urlRequest, withJSONObject: parameters)
            }
        }
        else if let contentType = headers?["Content-Type"], contentType.caseInsensitiveCompare("application/json") == .orderedSame {
            urlRequest = try JSONEncoding.default.encode(urlRequest, with: params)
        }
        else {
            urlRequest = try URLEncoding.default.encode(urlRequest, with: params)
        }
        
        return urlRequest
    }
}
