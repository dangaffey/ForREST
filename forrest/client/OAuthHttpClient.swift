//
//  OAuthHttpClient.swift
//  blackforest
//
//  Created by Daniel Gaffey on 7/22/17.
//  Copyright © 2017 UnchartedRealms LLC. All rights reserved.
//

import Foundation
import Alamofire

public class OAuthHttpClient
{
    typealias RedirectClosure = ((URLSession, URLSessionTask, HTTPURLResponse, URLRequest) -> URLRequest?)?
    typealias CachingClosure = ((URLSession, URLSessionDataTask, CachedURLResponse) -> CachedURLResponse?)?
    
    typealias UserResponse = (
        userToken: AccessToken,
        refreshToken: AccessToken,
        additionalData: [String : AnyObject]?
    )
    
    typealias RefreshResponse = (
        userToken: AccessToken,
        refreshToken: AccessToken
    )
    
    public static let sharedInstance = OAuthHttpClient(config: NetworkConfig.sharedInstance)
    
    let config: NetworkConfig
    let oauthStateProvider: OAuthStateProviderProtocol
    let oauthConfigProvider: OAuthConfigProviderProtocol
    let alamofire: Alamofire.SessionManager
    
    var refreshQueue = [DispatchWorkItem]()
    var isRefreshing = false
    
    let AUTH_HEADER = "Authorization"
    
    private init(config: NetworkConfig) {
        self.config = config
        self.oauthStateProvider = config.getStateProvider()!
        self.oauthConfigProvider = config.getConfigProvider()!
        
        let configuration = URLSessionConfiguration.default
        let sessionManager = Alamofire.SessionManager(
            configuration: configuration,
            serverTrustPolicyManager: ServerTrustPolicyManager(policies: config.sslOverridePolicy)
        )
        
        if config.stripMustRevalidate {
            OAuthHttpClient.activateCustomCaching(&sessionManager.delegate.dataTaskWillCacheResponse)
        }

        
        if config.followRedirectsWithAuth {
            OAuthHttpClient.activateCopiedHeaderRedirects(&sessionManager.delegate.taskWillPerformHTTPRedirection)
        }
        
        self.alamofire = sessionManager
    }
    
    
    /**
        Applies a custom redirect case wherein request redirects keep the headers of the initial request
    */
    private static func activateCopiedHeaderRedirects(_ delegateClosure: inout RedirectClosure) {
        delegateClosure = { session, task, response, request in
            var finalRequest = request
            if let originalRequest = task.originalRequest {
                finalRequest.allHTTPHeaderFields = originalRequest.allHTTPHeaderFields
            }
            return finalRequest
        }
    }
    
    
    /**
        Applies a custom caching that strips the problematic 'must-revalidate' entry from the response headers
    */
    private static func activateCustomCaching(_ delegateClosure: inout CachingClosure) {
        delegateClosure = { session, task, cachedResponse in
            
            guard let response = cachedResponse.response as? HTTPURLResponse,
                let cacheSettingsString = response.allHeaderFields["Cache-Control"] as? String,
                var headers = response.allHeaderFields as? [String : String] else {
                    return cachedResponse
            }
            
            headers["Cache-Control"] = cacheSettingsString.filterMustRevalidate()
            guard let updatedCachedResponse = CachedURLResponse(
                url: response.url,
                statusCode: response.statusCode,
                httpVersion: nil,
                headerFields: headers,
                data: cachedResponse.data,
                storagePolicy: cachedResponse.storagePolicy) else {
                    return cachedResponse
            }
            
            return updatedCachedResponse
        }
    }
    
    
    /**
        Routes a request to the correct attempt dispatch procedure
    */
    public func addRequestToQueue<T: ResponseHandleableProtocol & ErrorHandleableProtocol>(request: RequestPrototype<T>) {
        switch request.getType() {

        case .userAuthRequired:
            attemptUserAccessRequest(request: request)
            break

        case .appAuthRequired:
            attemptAppAccessRequest(request: request)
            break

        case .noAuthRequired:
            makeRequest(requestObject: request)
            break
        }
    }
    

    
    /**
     Attempts to execute a request that requires a user-level access
     */
    private func attemptUserAccessRequest<T: ResponseHandleableProtocol & ErrorHandleableProtocol>(request: RequestPrototype<T>)
    {
        if (oauthStateProvider.userAccessTokenValid()) {
            makeRequest(requestObject: request)
            return
        }
        
        
        if (oauthStateProvider.userRefreshTokenValid()) {
            attemptUserAccessRefresh(request: request)
            return
        }
        
        request.getAggregatedHandler().handleError(ForRESTError(.expiredUserToken))
    }
    
    
    
    /**
     Attempts to authenticate the application
     */
    public func attemptAppAuthentication(
        successHandler: @escaping () -> (),
        failureHandler: @escaping (ForRESTError) -> ()
    ) {
        let parser = oauthConfigProvider.getAppAuthParser()
        let persistSuccessHandler = { [weak self] (token: AccessToken) in
            do {
                try self?.oauthStateProvider.setAppAccessData(
                    token: token.getId(),
                    expiration: token.getExpiration())
                successHandler()
            } catch (let error) {
                failureHandler(ForRESTError(.appAuthFailed, error: error))
            }
        }
        
        let entityHandler = EntityHandler<AccessToken>(
            parserClosure: parser.fromJson,
            successCallback: persistSuccessHandler,
            failureCallback: failureHandler
        )
        
        let authRequest = RequestPrototype<EntityHandler<AccessToken>>(
            type: .noAuthRequired,
            method: .post,
            url: oauthConfigProvider.getAppAuthEndpoint(),
            params: parser.toJson(
                clientId: oauthConfigProvider.getClientCredentials().getClientId(),
                clientSecret: oauthConfigProvider.getClientCredentials().getClientSecret()),
            parameterEncoding: JSONEncoding.default,
            aggregatedHandler: entityHandler
        )
        
        makeRequest(requestObject: authRequest)
    }
    
    
    /**
     Attempts to execute an application level request
     */
    private func attemptAppAccessRequest<T: ResponseHandleableProtocol & ErrorHandleableProtocol>(request: RequestPrototype<T>)
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
    private func attemptAppAuthentication<T: ResponseHandleableProtocol & ErrorHandleableProtocol>(request: RequestPrototype<T>)
    {
        let parser = oauthConfigProvider.getAppAuthParser()
        let persistSuccessHandler = { [weak self] (token: AccessToken) in
            do {
                try self?.oauthStateProvider.setAppAccessData(
                    token: token.getId(),
                    expiration: token.getExpiration())
                
                self?.makeRequest(requestObject: request)
                
            } catch (let error) {
                request.getAggregatedHandler().handleError(ForRESTError(.appAuthFailed, error: error))
            }
        }
        
        let entityHandler = EntityHandler<AccessToken>(
            parserClosure: parser.fromJson,
            successCallback: persistSuccessHandler,
            failureCallback: request.getAggregatedHandler().handleError
        )

        let authRequest = RequestPrototype<EntityHandler<AccessToken>>(
            type: .noAuthRequired,
            method: .post,
            url: oauthConfigProvider.getAppAuthEndpoint(),
            params: parser.toJson(
                clientId: oauthConfigProvider.getClientCredentials().getClientId(),
                clientSecret: oauthConfigProvider.getClientCredentials().getClientSecret()),
            parameterEncoding: JSONEncoding.default,
            aggregatedHandler: entityHandler
        )

        makeRequest(requestObject: authRequest)
    }
    
    
    
    /**
     Attempts to authenticate a user with the password_grant type
     */
    public func attemptUserAuthentication(
        username: String,
        password: String,
        meta: [String: Any]? = nil,
        successHandler: @escaping ([String: AnyObject]?) -> (),
        failureHandler: @escaping (ForRESTError) -> ()
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
                
                successHandler(response.additionalData)
                
            } catch (let error) {
                failureHandler(ForRESTError(.userAuthFailed, error: error))
            }
        }
        
        let entityHandler = EntityHandler<UserResponse>(
            parserClosure: parser.fromJson,
            successCallback: persistSuccessHandler,
            failureCallback: failureHandler
        )
        
        let userRequest = RequestPrototype<EntityHandler<UserResponse>>(
            type: .noAuthRequired,
            method: .post,
            url: oauthConfigProvider.getUserAuthEndpoint(),
            params: parser.toJson(username: username, password: password, meta: meta),
            parameterEncoding: JSONEncoding.default,
            aggregatedHandler: entityHandler
        )
        
        makeRequest(requestObject: userRequest)
    }
    
    
    
    /**
     Attempts to refresh the access token for user-level access
     */
    private func attemptUserAccessRefresh<T: ResponseHandleableProtocol & ErrorHandleableProtocol>(request: RequestPrototype<T>)
    {
        refreshQueue.append(DispatchWorkItem { [weak self] in
            guard let `self` = self else {
                request.getAggregatedHandler().handleError(ForRESTError(.refreshFailed))
                return
            }
            self.makeRequest(requestObject: request)
        })
        
        if (isRefreshing) {
            return
        }
        isRefreshing = true
            
        let parser = self.oauthConfigProvider.getRefreshParser()
        
        let refreshSuccessHandler = { [weak self] (response: RefreshResponse) in
            do {
                try self?.oauthStateProvider.setUserAccessData(
                    token: response.userToken.id,
                    expiration: response.userToken.expiration)
                
                try self?.oauthStateProvider.setUserRefreshData(
                    token: response.refreshToken.id,
                    expiration: response.refreshToken.expiration)
                
            } catch (let error) {
                request.getAggregatedHandler().handleError(ForRESTError(.refreshFailed, error: error))
                self?.refreshQueue.removeAll()
            }
            
            self?.isRefreshing = false
            self?.sendPendingRequests()
        }
        
        let refreshFailureHandler = { [weak self] (error: ForRESTError) in
            error.httpCode = 401 //Set all refresh errors to 401's so client can key off one scenario
            request.getAggregatedHandler().handleError(error)
            self?.isRefreshing = false
            self?.refreshQueue.removeAll()
        }
        
        let entityHandler = EntityHandler<RefreshResponse>(
            parserClosure: parser.fromJson,
            successCallback: refreshSuccessHandler,
            failureCallback: refreshFailureHandler
        )
        
        let refreshRequest = RequestPrototype<EntityHandler<RefreshResponse>>(
            type: .noAuthRequired,
            method: .post,
            url: self.oauthConfigProvider.getRefreshEndpoint(),
            params: parser.toJson(token: self.oauthStateProvider.getUserRefreshData()?.token ?? ""),
            parameterEncoding: JSONEncoding.default,
            aggregatedHandler: entityHandler
        )
        
        self.makeRequest(requestObject: refreshRequest)
    }

    
    /**
        Send the pending queued requests from the refresh process
    */
    internal func sendPendingRequests() {
        for workItem in refreshQueue {
            DispatchQueue.global(qos: .utility).async(execute: workItem)
        }
        refreshQueue.removeAll()
    }
    
    /**
     Executes requests through the Alamofire stack
     */
    internal func makeRequest<T: ResponseHandleableProtocol>(requestObject: RequestPrototype<T>)
    {
        var headers = HTTPHeaders()
        let requestType = requestObject.getType()
        
        if let contentType = requestObject.getContentType() {
            headers["Content-Type"] = contentType
        }

        if let authorizationHeader = getAuthorizationHeader(type: requestType) {
            headers["Authorization"] = String(format: "Bearer %@", authorizationHeader)
        }
       
        alamofire.request(requestObject.getUrl(),
                          method: requestObject.getMethod(),
                          parameters: requestObject.getParams(),
                          encoding: requestObject.getEncoding(),
                          headers: headers)
            .validate(statusCode: 200..<300)
            .responseData(completionHandler: requestObject.getAggregatedHandler().handleResponse)
        
        config.getRequestLogger()?.requestExecuted(requestURL: requestObject.getUrl())
    }
    
    
    
    /**
     Attempts to retrieve the correct authorization header based on the request type
     */
    internal func getAuthorizationHeader(type: RequestType) -> String?
    {
        switch type {
        case .userAuthRequired:
            guard let header = oauthStateProvider.getUserAccessData()?.token else {
                return nil
            }
            
            return header
            
        case .appAuthRequired:
            guard oauthStateProvider.userAccessTokenValid() else {
                guard let header = oauthStateProvider.getAppAccessData()?.token else {
                    return nil
                }
                
                return header
            }
            
            guard let header = oauthStateProvider.getUserAccessData()?.token else {
                return nil
            }
            
            return header
            
        case .noAuthRequired:
            return nil
        }
    }
    
}
