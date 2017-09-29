//
//  OAuthHttpClient.swift
//  blackforest
//
//  Created by Daniel Gaffey on 7/22/17.
//  Copyright © 2017 UnchartedRealms LLC. All rights reserved.
//

import Foundation
import Alamofire


public enum ForrestError: Error {
    case applicationAuthFailed
    case expiredCredentials
    case parseError
    case persistError
}


class OAuthHttpClient
{
    typealias UserResponse = (
        userToken: AccessToken,
        refreshToken: AccessToken,
        additionalData: [String : AnyObject]?
    )
    
    typealias RefreshResponse = (
        userToken: AccessToken,
        refreshToken: AccessToken
    )
    
    static let sharedInstance = OAuthHttpClient(
        oauthStateProvider: NetworkConfig.sharedInstance.getStateProvider()!,
        oauthConfigProvider: NetworkConfig.sharedInstance.getConfigProvider()!
    )
    
    let oauthStateProvider: OAuthStateProviderProtocol
    let oauthConfigProvider: OAuthConfigProviderProtocol
    
   // var pendingRefreshQueue = [HttpRequestableProtocol]()
    var isRefreshing: Bool = false
    
    let AUTH_HEADER = "Authorization"
    
    private init(
        oauthStateProvider: OAuthStateProviderProtocol,
        oauthConfigProvider: OAuthConfigProviderProtocol
    ) {
        self.oauthStateProvider = oauthStateProvider
        self.oauthConfigProvider = oauthConfigProvider
    }
    
    
    public func addRequestToQueue<T: ResponseHandleableProtocol>(request: RequestPrototype<T>)
    {
        switch request.getType() {
            
        case .UserAuthRequired:
            attemptUserAccessRequest(request: request)
            break
            
        case .AppAuthRequired:
            attemptAnyAccessRequest(request: request)
            break
            
        case .NoAuthRequired:
            makeRequest(requestObject: request)
            break
        }
    }
    
    
    
    /**
     Attempts to execute a request that requires a user-level access
     */
    private func attemptUserAccessRequest<T: ResponseHandleableProtocol>(request: RequestPrototype<T>) -> Void
    {
        if (oauthStateProvider.userAccessIntended()) {
            makeRequest(requestObject: request)
            return
        }
        
        
        if (oauthStateProvider.userRefreshPossible()) {
           // pendingRefreshQueue.append(request)
            attemptUserAccessRefresh(request: request)
            return
        }
        
        request.getResponseHandler().getFailureCallback()(ForrestError.expiredCredentials)
    }
    
    
    
    /**
     Attempts to make a request preferring user-level, but trying application-level if unavailable
     */
    private func attemptAnyAccessRequest<T: ResponseHandleableProtocol>(request: RequestPrototype<T>) -> Void
    {
        if (oauthStateProvider.userAccessIntended()) {
            attemptUserAccessRequest(request: request)
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
        let parser = oauthConfigProvider.getAppAuthParser()
        let persistSuccessHandler = { [weak self] (token: AccessToken) in
            do {
                try self?.oauthStateProvider.setAppAccessData(
                    token: token.getId(),
                    expiration: token.getExpiration())
                successHandler()
            } catch (let error) {
                failureHandler(error)
            }
        }
        
        let responseHandler = ResponseHandler<AccessToken>(
            parserClosure: parser.fromJson,
            successCallback: persistSuccessHandler,
            failureCallback: failureHandler
        )
        
        let authRequest = RequestPrototype<ResponseHandler<AccessToken>>(
            type: .NoAuthRequired,
            method: .post,
            url: oauthConfigProvider.getAppAuthEndpoint(),
            params: parser.toJson(
                clientId: oauthConfigProvider.getClientCredentials().getClientId(),
                clientSecret: oauthConfigProvider.getClientCredentials().getClientSecret()),
            parameterEncoding: JSONEncoding.default,
            responseHandler: responseHandler
        )
        
        makeRequest(requestObject: authRequest)
    }
    
    
    /**
     Attempts to execute an application level request
     */
    private func attemptAppAccessRequest<T: ResponseHandleableProtocol>(request: RequestPrototype<T>)
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
    private func attemptAppAuthentication<T: ResponseHandleableProtocol>(request: RequestPrototype<T>)
    {
        let parser = oauthConfigProvider.getAppAuthParser()
        let persistSuccessHandler = { [weak self] (token: AccessToken) in
            do {
                try self?.oauthStateProvider.setAppAccessData(
                    token: token.getId(),
                    expiration: token.getExpiration())
                
                self?.makeRequest(requestObject: request)
                
            } catch (let error) {
                request.getResponseHandler().getFailureCallback()(error)
            }
        }
        
        let responseHandler = ResponseHandler<AccessToken>(
            parserClosure: parser.fromJson,
            successCallback: persistSuccessHandler,
            failureCallback: request.getResponseHandler().getFailureCallback()
        )
        
        let authRequest = RequestPrototype<ResponseHandler<AccessToken>>(
            type: .NoAuthRequired,
            method: .post,
            url: oauthConfigProvider.getAppAuthEndpoint(),
            params: parser.toJson(
                clientId: oauthConfigProvider.getClientCredentials().getClientId(),
                clientSecret: oauthConfigProvider.getClientCredentials().getClientSecret()),
            parameterEncoding: JSONEncoding.default,
            responseHandler: responseHandler
        )
        
        makeRequest(requestObject: authRequest)
    }
    
    
    
    /**
     Attempts to authenticate a user with the password_grant type
     */
    public func attemptUserAuthentication(
        username: String,
        password: String,
        successHandler: @escaping () -> (),
        failureHandler: @escaping (Error) -> ()
    ) {
        
        
        let parser = oauthConfigProvider.getUserAuthParser()
        let persistSuccessHandler = { [weak self] (response: UserResponse) in
            do {
                try self?.oauthStateProvider.setUserAccessData(
                    token: response.userToken.id,
                    expiration: response.userToken.expiration)
                
                try self?.oauthStateProvider.setUserRefreshData(
                    token: response.refreshToken.id,
                    expiration: response.refreshToken.expiration)
                
                successHandler()
                
            } catch (let error) {
                failureHandler(error)
            }
        }
        
        let responseHandler = ResponseHandler<UserResponse>(
            parserClosure: parser.fromJson,
            successCallback: persistSuccessHandler,
            failureCallback: failureHandler
        )
        
        let userRequest = RequestPrototype<ResponseHandler<UserResponse>>(
            type: .NoAuthRequired,
            method: .post,
            url: oauthConfigProvider.getUserAuthEndpoint(),
            params: parser.toJson(username: username, password: password),
            parameterEncoding: JSONEncoding.default,
            responseHandler: responseHandler
        )
        
        makeRequest(requestObject: userRequest)
    }
    
    
    
    /**
     Attempts to refresh the access token for user-level access
     */
    private func attemptUserAccessRefresh<T: ResponseHandleableProtocol>(request: RequestPrototype<T>)
    {
        if (isRefreshing) {
            return
        }
        
        isRefreshing = true
        
        let parser = oauthConfigProvider.getRefreshParser()
        let persistSuccessHandler = { [weak self] (response: RefreshResponse) in
            do {
                try self?.oauthStateProvider.setUserAccessData(
                    token: response.userToken.id,
                    expiration: response.userToken.expiration)
                
                try self?.oauthStateProvider.setUserRefreshData(
                    token: response.refreshToken.id,
                    expiration: response.refreshToken.expiration)
                
                self?.isRefreshing = false
                self?.sendPendingRequests()
                
                
            } catch (let error) {
                request.getResponseHandler().getFailureCallback()(error)
            }
        }
        
        let responseHandler = ResponseHandler<RefreshResponse>(
            parserClosure: parser.fromJson,
            successCallback: persistSuccessHandler,
            failureCallback: request.getResponseHandler().getFailureCallback()
        )

        let refreshRequest = RequestPrototype<ResponseHandler<RefreshResponse>>(
            type: .NoAuthRequired,
            method: .post,
            url: oauthConfigProvider.getRefreshEndpoint(),
            params: parser.toJson(token: oauthStateProvider.getUserRefreshData()?.token ?? ""),
            parameterEncoding: JSONEncoding.default,
            responseHandler: responseHandler
        )
        
        makeRequest(requestObject: refreshRequest)
    }
    
    
    
    
    /**
     Attempts to dispatch the pending requests
     */
    func sendPendingRequests()
    {
//        while (pendingRefreshQueue.count > 0) {
//            let requestable = pendingRefreshQueue.remove(at: 0)
//            makeRequest(requestObject: requestable)
//        }
    }
    
    
    
    /**
     Executes requests through the Alamofire stack
     */
    func makeRequest<T: ResponseHandleableProtocol>(requestObject: RequestPrototype<T>) -> Void
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
                          headers: headers)
            .responseData(completionHandler: requestObject.getResponseHandler().handleResponse)
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
