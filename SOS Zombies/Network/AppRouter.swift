//
//  AppRouter.swift
//  SOS Zombies
//
//  Created by Achref Marzouki on 21/4/21.
//

import Alamofire

/// A type representing the app router, each case of the enum is an endpoint.
enum DataRouter: Routable {
    
    static var baseUrl: String = "http://dmmw-api.australiaeast.cloudapp.azure.com:8080"
    
    case illnesses(limit: Int?, page: Int?)
    case hospitals(limit: Int?, page: Int?)
    
    var method: HTTPMethod {
        return .get
    }
    
    var path: String {
        switch self {
        case .illnesses: return "/illnesses"
        case .hospitals: return "/hospitals"
        }
    }
    
    var params: Parameters? {
        switch self {
        case .illnesses(let limit, let page), .hospitals(let limit, let page):
            var params: [String : Any] = [:]
            if let limit = limit { params[C.Keys.LIMIT] = limit }
            if let page = page { params[C.Keys.PAGE] = page }
            return params
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
    
    var token: String? {
        return nil
    }
}
