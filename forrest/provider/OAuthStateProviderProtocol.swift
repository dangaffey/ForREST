//
//  OAuthStateProviderProtocol.swift
//  forrest
//
//  Created by Daniel Gaffey on 7/22/17.
//  Copyright © 2017 UnchartedRealms LLC. All rights reserved.
//

import Foundation


protocol OAuthStateProviderProtocol
{
    func userAccessIntended() -> Bool
    
    func userRefreshPossible() -> Bool
    
    func appAccessTokenValid() -> Bool
    
    func setUserAccessData(token: String, expiration: String) throws
    
    func setUserRefreshData(token: String, expiration: String) throws
    
    func setAppAccessData(token: String, expiration: String) throws
    
    func getUserAccessData() -> (token: String, expiration: String)?
    
    func getUserRefreshData() -> (token: String, expiration: String)?
    
    func getAppAccessData() -> (token: String, expiration: String)?
}
