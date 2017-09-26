//
//  OAuthHttpClient.swift
//  blackforest
//
//  Created by Daniel Gaffey on 7/22/17.
//  Copyright © 2017 UnchartedRealms LLC. All rights reserved.
//

import Foundation
import Alamofire


public enum OAuthError: Error {
    case applicationAuthFailed
    case expiredCredentials
    case parseError
    case persistError
}


class OAuthHttpClient
{
    static let sharedInstance = OAuthHttpClient(
        oauthStateProvider: NetworkConfig.sharedInstance.getStateProvider()!,
        oauthConfigProvider: NetworkConfig.sharedInstance.getConfigProvider()!
    )
    
    let oauthStateProvider: OAuthStateProviderProtocol
    let oauthConfigProvider: OAuthConfigProviderProtocol
    
    var pendingRefreshQueue = [HttpRequestProtocol]()
    var isRefreshing: Bool = false
    
    let AUTH_HEADER = "Authorization"
    
    private init(
        oauthStateProvider: OAuthStateProviderProtocol,
        oauthConfigProvider: OAuthConfigProviderProtocol
    ) {
        self.oauthStateProvider = oauthStateProvider
        self.oauthConfigProvider = oauthConfigProvider
    }
    
    
    public func addRequestToQueue(request: RequestPrototype) throws
    {
        switch request.getType() {
            
        case .UserAuthRequired:
            try attemptUserAccessRequest(request: request)
            break
            
        case .AppAuthRequired:
            try attemptAnyAccessRequest(request: request)
            break
            
        case .NoAuthRequired:
            makeRequest(requestObject: request)
            break
        }
    }
    
    
    
    /**
     Attempts to execute a request that requires a user-level access
     */
    private func attemptUserAccessRequest(request: HttpRequestProtocol) throws -> Void
    {
        if (oauthStateProvider.userAccessIntended()) {
            makeRequest(requestObject: request)
            return
        }
        
        
        if (oauthStateProvider.userRefreshPossible()) {
            pendingRefreshQueue.append(request)
            attemptUserAccessRefresh(request: request)
            return
        }
        
        
        throw OAuthError.expiredCredentials
    }
    
    
    
    /**
     Attempts to make a request preferring user-level, but trying application-level if unavailable
     */
    private func attemptAnyAccessRequest(request: HttpRequestProtocol) -> Void
    {
        if (oauthStateProvider.userAccessIntended()) {
            try attemptUserAccessRequest(request: request)
            return
        }
        
        attemptAppAccessRequest(request: request)
    }
    
    
    
    /**
     Attempts to authenticate the application
     */
    public func attemptAppAuthentication(
        successHandler: @escaping () -> (),
        failureHandler: @escaping (Error) -> ()
    ) {
        //Create handlre class 
        let responseHandler = DefaultResponseHandler()
        
        let authRequest = RequestPrototype(
            type: .NoAuthRequired,
            method: .post,
            url: oauthConfigProvider.getAppAuthEndpoint(),
            params: oauthConfigProvider.getAppAuthParser().toJson(
                clientId: oauthConfigProvider.getClientCredentials().getClientId(),
                clientSecret: oauthConfigProvider.getClientCredentials().getClientSecret()),
            parameterEncoding: JSONEncoding.default,
            responseCallback: responseHandler.handleResponse as! DataResponseProtocol
        )
        
        makeRequest(requestObject: authRequest)
    }
    
    
    /**
     Attempts to execute an application level request
     */
    private func attemptAppAccessRequest(request: HttpRequestProtocol)
    {
        if (oauthStateProvider.appAccessTokenValid()) {
            makeRequest(requestObject: request)
            return
        }
        
        attemptAppAuthentication(request: request)
    }
    
    
    
    /**
     Attempts to broker a new application access token under a request
     */
    private func attemptAppAuthentication(request: HttpRequestProtocol)
    {
        let authRequest = RequestPrototype(
            type: .NoAuthRequired,
            method: .post,
            url: oauthConfigProvider.getAppAuthEndpoint(),
            params: oauthConfigProvider.getAppAuthParser().toJson(
                clientId: oauthConfigProvider.getClientCredentials().getClientId(),
                clientSecret: oauthConfigProvider.getClientCredentials().getClientSecret()),
            parameterEncoding: JSONEncoding.default,
            responseCallback: { [unowned self] response in
                
                switch response.result {
                    
                case .success:
                    //track time using response.timeline object
                    
                    guard let data = response.result.value,
                        let appToken = self.oauthConfigProvider
                            .getAppAuthParser()
                            .fromJson(jsonData: data) else {
                                debugPrint("COULD NOT GET STRING RESPONSE FROM SERVER")
                                return
                    }
                    
                    do {
                        try self.oauthStateProvider.setAppAccessData(
                            token: appToken.getId(),
                            expiration: appToken.getExpiration())
                        
                        self.makeRequest(requestObject: request)
                        
                    } catch (let error) {
                        //TODO must relay error onto incoming request error
                        
                    }
                    
                    break
                    
                case .failure(let error):
                    //error
                    break
                    
                    
                }
            }
        )
        
        makeRequest(requestObject: authRequest)
    }
    
    
    
    /**
     Attempts to authenticate a user with the password_grant type
     */
    public func attemptUserAuthentication(username: String, password: String)
    {
        let userRequest = RequestPrototype(
            type: .NoAuthRequired,
            method: .post,
            url: oauthConfigProvider.getUserAuthEndpoint(),
            params: oauthConfigProvider.getUserAuthParser().toJson(username: username, password: password),
            parameterEncoding: JSONEncoding.default,
            responseCallback: { [unowned self] response in
                
                switch response.result {
                    
                case .success(let data):
                    
                    //track time using response.timeline object
                    
                    guard let tokenSet = self.oauthConfigProvider
                        .getRefreshParser()
                        .fromJson(jsonData: data) else {
                            //TODO refresh parse failed
                            return
                    }
                    
                    do {
                        try self.oauthStateProvider.setUserAccessData(
                            token: tokenSet.userToken.id,
                            expiration: tokenSet.userToken.expiration)
                        
                        try self.oauthStateProvider.setUserRefreshData(
                            token: tokenSet.refreshToken.id,
                            expiration: tokenSet.refreshToken.expiration)
                        
                        //RETURN THROUGH CALLBACK
                        
                    } catch (let error) {
                        //TODO logout and log, could not persist important data
                    }
                    
                    break
                    
                case .failure(let error):
                    //TODO logout and log, could not persist important data
                    break
                    
                }
            }
        )
        
        makeRequest(requestObject: userRequest)
    }
    
    
    
    /**
     Attempts to refresh the access token for user-level access
     */
    private func attemptUserAccessRefresh(request: HttpRequestProtocol)
    {
        if (isRefreshing) {
            return
        }
        
        isRefreshing = true
        
        guard let refreshData = oauthStateProvider.getUserRefreshData() else {
            //TODO logout? a seemingly valid refresh has failed
            return
        }
        
        let refreshRequest = RequestPrototype(
            type: .NoAuthRequired,
            method: .post,
            url: oauthConfigProvider.getRefreshEndpoint(),
            params: oauthConfigProvider.getRefreshParser().toJson(token: refreshData.token),
            parameterEncoding: JSONEncoding.default,
            responseCallback: { [unowned self] response in
                
                switch response.result {
                    
                case .success(let data):
                    
                    //track time using response.timeline object
                    guard let tokenSet = self.oauthConfigProvider
                        .getRefreshParser()
                        .fromJson(jsonData: data) else {
                            //TODO refresh parse failed
                            return
                    }
                    
                    do {
                        try self.oauthStateProvider.setUserAccessData(
                            token: tokenSet.userToken.id,
                            expiration: tokenSet.userToken.expiration)
                        
                        try self.oauthStateProvider.setUserRefreshData(
                            token: tokenSet.refreshToken.id,
                            expiration: tokenSet.refreshToken.expiration)
                        
                        self.isRefreshing = false
                        self.sendPendingRequests()
                        
                    } catch (let error) {
                        //TODO logout and log, could not persist important data
                    }
                    
                    break
                    
                case .failure(let error):
                    //TODO logout and log, could not persist important data
                    break
                    
                }
            }
        )
        
        makeRequest(requestObject: refreshRequest)
    }
    
    
    
    
    /**
     Attempts to dispatch the pending requests
     */
    func sendPendingRequests()
    {
        while (pendingRefreshQueue.count > 0) {
            makeRequest(requestObject: pendingRefreshQueue.remove(at: 0))
        }
    }
    
    
    
    /**
     Executes requests through the Alamofire stack
     */
    func makeRequest(requestObject: HttpRequestProtocol) -> Void
    {
        var headers = HTTPHeaders()
        let requestType = requestObject.getType()
        
        if let authorizationHeader = getAuthorizationHeader(type: requestType) {
            headers["Authorization"] = String(format: "Bearer %@", authorizationHeader)
        }
        
        Alamofire.request(requestObject.getUrl(),
                          method: requestObject.getMethod(),
                          parameters: requestObject.getParams(),
                          encoding: requestObject.getEncoding(),
                          headers: headers
            ).responseData(completionHandler: requestObject.getResponseCallback())
    }
    
    
    
    /**
     Attempts to retrieve the correct authorization header based on the request type
     */
    func getAuthorizationHeader(type: RequestType) -> String?
    {
        switch type {
        case .UserAuthRequired:
            guard let header = oauthStateProvider.getUserAccessData()?.token else {
                return nil
            }
            
            return header
            
        case .AppAuthRequired:
            guard oauthStateProvider.userAccessIntended() else {
                guard let header = oauthStateProvider.getAppAccessData()?.token else {
                    return nil
                }
                
                return header
            }
            
            guard let header = oauthStateProvider.getUserAccessData()?.token else {
                return nil
            }
            
            return header
            
        case .NoAuthRequired:
            return nil
        }
    }
    
}
