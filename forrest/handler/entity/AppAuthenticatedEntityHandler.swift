//
//  AppAuthenticatedEntityHandler.swift
//  ForREST
//
//  Created by Dan Gaffey on 3/27/19.
//  Copyright © 2019 UnchartedRealms. All rights reserved.
//

import Foundation


open class AppAuthenicatedEntityHandler<T>: EntityHandler<T> {
    
    override open func getFailureCallback() -> (ForRESTError) -> () {
        
        return { (error: ForRESTError) in
            
            if error.httpCode == 401 || error.httpCode == 403 {
                self.failureCallback(error)
                NotificationCenter.default.post(name: Notifications.clearAppToken, object: nil)
                return
            }
            
            
            switch error.type {
            case .appAuthFailed:
                NotificationCenter.default.post(name: Notifications.clearAppToken, object: nil)
                
            default:
                break
            }
            
            self.failureCallback(error)
        }
        
        
    }
}
