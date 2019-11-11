//
//  MockBadRefreshConfigProvider.swift
//  ForRESTTests
//
//  Created by Dan Gaffey on 11/11/19.
//  Copyright © 2019 UnchartedRealms. All rights reserved.
//

import Foundation


struct MockBadRefreshConfigProvider: OAuthConfigProviderProtocol
{
    func getUserAuthEndpoint() -> String
    {
        return Endpoints.GET_TOKEN
    }
    
    func getRefreshEndpoint() -> String
    {
        return Endpoints.GET_REFRESH_401
    }
    
    func getAppAuthEndpoint() -> String
    {
        return Endpoints.GET_TOKEN
    }
    
    func getClientCredentials() -> ClientCredentialsProviderProtocol
    {
        return MockClientCredentialsProvider()
    }
    
    func getRefreshParser() -> RefreshParserProtocol
    {
        return MockRefreshParser()
    }
    
    func getAppAuthParser() -> AppAuthParserProtocol
    {
        return MockAppAuthParser()
    }
    
    func getUserAuthParser() -> UserAuthParserProtocol
    {
        return MockUserAuthParser()
    }
}
