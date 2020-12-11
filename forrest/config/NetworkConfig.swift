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
    private var metricsTracker: RequestMetricsProtocol?
    private var requestLogger: RequestLoggingProtocol?
    
    public var httpAdditionalHeaders: [AnyHashable : Any]?
    public var transportOverrideDomains: [String]?
    public var followRedirectsWithAuth = false
    public var stripMustRevalidate = false
    
    
    /**
         Hide constructor to force static singleton usage
     */
    private init() {}

    
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
    
    /**
     Sets the metrics tracker object
     */
    public func setMetricsTracker(metricsTracker: RequestMetricsProtocol)
    {
        self.metricsTracker = metricsTracker
    }
    
    /**
     Provides the metrics tracker for requests
     */
    public func getMetricsTracker() -> RequestMetricsProtocol?
    {
        return self.metricsTracker
    }
    
    /**
     Sets the request logger object
     */
    public func setRequestLogger(requestLogger: RequestLoggingProtocol)
    {
        self.requestLogger = requestLogger
    }
    
    /**
     Provides the request logger for requests
     */
    public func getRequestLogger() -> RequestLoggingProtocol?
    {
        return self.requestLogger
    }
    
    public func setHttpAdditionalHeaders(_ headers: [AnyHashable : Any])
    {
        self.httpAdditionalHeaders = headers
    }
    
    /**
     Provides the additional headers to add onto all requests
     */
    public func getHttpAdditionalHeaders() -> [AnyHashable : Any]?
    {
        return self.httpAdditionalHeaders
    }
}


