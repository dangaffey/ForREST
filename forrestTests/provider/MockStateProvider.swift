//
//  MockStateProvider.swift
//  forrestTests
//
//  Created by Dan Gaffey on 9/21/17.
//  Copyright © 2017 UnchartedRealms. All rights reserved.
//

import Foundation

struct MockStateProvider: OAuthStateProviderProtocol
{
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
        return false
    }
    
    func setUserAccessData(token: String, expiration: String) throws
    {
        
    }
    
    func setUserRefreshData(token: String, expiration: String) throws
    {
        
    }
    
    func setAppAccessData(token: String, expiration: String) throws
    {
        
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
