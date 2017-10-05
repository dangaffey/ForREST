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
    static let sharedInstance = MockStateProvider()
    
    private var userToken: AccessToken?
    private var refreshToken: AccessToken?
    private var appToken: AccessToken?
    
    
    private init()
    {
        
    }
    
    func userAccessIntended() -> Bool
    {
        guard let token = userToken,
            token.getId() != "",
            token.getExpiration() != "" else {
            return false
        }
        
        return true
    }
    
    func userRefreshPossible() -> Bool
    {
        guard let _ = refreshToken else {
            return false
        }
        
        return true
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
        self.userToken = AccessToken(id: token, expiration: expiration)
    }
    
    func setUserRefreshData(token: String, expiration: String) throws
    {
        self.refreshToken = AccessToken(id: token, expiration: expiration)
    }
    
    func setAppAccessData(token: String, expiration: String) throws
    {
        self.appToken = AccessToken(id: token, expiration: expiration)
    }
    
    func getUserAccessData() -> (token: String, expiration: String)?
    {
        guard let token = self.userToken,
            token.getId() != "",
            token.getExpiration() != "" else {
            return nil
        }
        
        return (token.getId(), token.getExpiration())
    }
    
    func getUserRefreshData() -> (token: String, expiration: String)?
    {
        guard let token = refreshToken else {
            return nil
        }
        
        return (token.getId(), token.getExpiration())
    }
    
    func getAppAccessData() -> (token: String, expiration: String)?
    {
        guard let token = appToken else {
                return nil
        }
        
        return (token.getId(), token.getExpiration())
    }
}
