//
//  NetworkConfig.swift
//  ForREST
//
//  Created by Daniel Gaffey on 9/20/17.
//  Copyright © 2017 UnchartedRealms. All rights reserved.
//

import Foundation
import Alamofire

public class NetworkConfig
{
    public static let sharedInstance = NetworkConfig()
    
    private var configProvider: OAuthConfigProviderProtocol?
    private var stateProvider: OAuthStateProviderProtocol?
    public var transportOverrideDomains: [String]?
    public var followRedirectsWithAuth = false
    
    /**
         Hide constructor to force static singleton usage
     */
    private init(){}
    
    
    /**
         Provides an optional policy to trust domains, for
         instance, self-signed SSL certs in development env
     */
    var sslOverridePolicy: [String: ServerTrustPolicy]
    {
        var policy = [String: ServerTrustPolicy]()
        guard let overrides = transportOverrideDomains else {
            return policy
        }
        
        for domain in overrides {
            policy[domain] = .disableEvaluation
        }
        return policy
    }
    
    /**
         Sets the config provider object
     */
    public func setConfigProvider(configProvider: OAuthConfigProviderProtocol)
    {
        self.configProvider = configProvider
    }
    
    /**
         Provides the oauth configuration object
     */
    public func getConfigProvider() -> OAuthConfigProviderProtocol?
    {
        return self.configProvider
    }
    
    /**
         Sets the state provider object
     */
    public func setStateProvider(stateProvider: OAuthStateProviderProtocol)
    {
        self.stateProvider = stateProvider
    }
    
    /**
         Provides the oauth state object
     */
    public func getStateProvider() -> OAuthStateProviderProtocol?
    {
        return self.stateProvider
    }
}


