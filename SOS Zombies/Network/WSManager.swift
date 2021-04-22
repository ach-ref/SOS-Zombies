//
//  WSManager.swift
//  SOS Zombies
//
//  Created by Achref Marzouki on 21/4/21.
//

import Foundation
import Alamofire

class WSManager: NSObject {
    
    // MARK: - Shared instance
    
    static let shared = WSManager()
    
    // MARK: - Initialzers
    
    override private init() {
        super.init()
    }
    
    // MARK: - Public
    
    func remoteDataForRoute(_ route: DataRouter, completion: @escaping (Json?) -> Void) {
        var result: Json?
        // get remote data from the backend
        AF.request(route).validate().responseJSON { response in
            switch response.result {
            case .success:
                result = response.value as? Json
            case .failure(let error):
                print(error)
            }
            // completion block
            completion(result)
        }
    }
}
