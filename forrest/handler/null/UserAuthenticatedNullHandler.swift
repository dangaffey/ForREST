//
//  UserAuthenticatedNullHandler.swift
//  ForREST
//
//  Created by Daniel Gaffey on 8/19/18.
//  Copyright © 2018 UnchartedRealms. All rights reserved.
//

import Foundation


open class UserAuthenticatedNullHandler: NullHandler {
    
    override open func getFailureCallback() -> (ForRESTError) -> () {
        
        return { (error: ForRESTError) in
            
            if error.httpCode == 401 {
                self.failureCallback(error)
                NotificationCenter.default.post(name: .logout, object: nil)
                return
            }
            
            
            switch error.type {
            case .expiredUserToken, .refreshFailed:
                NotificationCenter.default.post(name: .logout, object: nil)
                
            default:
                break
            }
            
            self.failureCallback(error)
        }
        
        
    }
    
}
