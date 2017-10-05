//
//  OAuthConfigProviderProtocol.swift
//  ForREST
//
//  Created by Daniel Gaffey on 7/22/17.
//  Copyright © 2017 UnchartedRealms LLC. All rights reserved.
//

import Foundation


protocol OAuthConfigProviderProtocol
{
    func getUserAuthEndpoint() -> String
    
    func getRefreshEndpoint() -> String
    
    func getAppAuthEndpoint() -> String
    
    func getClientCredentials() -> ClientCredentialsProviderProtocol
    
    func getRefreshParser() -> RefreshParserProtocol
    
    func getAppAuthParser() -> AppAuthParserProtocol
    
    func getUserAuthParser() -> UserAuthParserProtocol
}
