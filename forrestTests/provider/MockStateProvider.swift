//
//  MockStateProvider.swift
//  forrestTests
//
//  Created by Dan Gaffey on 9/21/17.
//  Copyright © 2017 UnchartedRealms. All rights reserved.
//

import Foundation

class MockStateProvider: OAuthStateProviderProtocol
{
    private var appToken: AccessToken?
    
    
    func userAccessIntended() -> Bool
    {
        return false
    }
    
    func userRefreshPossible() -> Bool
    {
        return false
    }
    
    func appAccessTokenValid() -> Bool
    {
        guard let _ = appToken else {
            return false
        }
        
        return true
    }
    
    func setUserAccessData(token: String, expiration: String) throws
    {
        
    }
    
    func setUserRefreshData(token: String, expiration: String) throws
    {
        
    }
    
    func setAppAccessData(token: String, expiration: String) throws
    {
        self.appToken = AccessToken(id: token, expiration: expiration)
    }
    
    func getUserAccessData() -> (token: String, expiration: String)?
    {
        return nil
    }
    
    func getUserRefreshData() -> (token: String, expiration: String)?
    {
        return nil
    }
    
    func getAppAccessData() -> (token: String, expiration: String)?
    {
        return nil
    }
}
