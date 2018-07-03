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
    case refreshFailed
    case parseError
    case persistError
}


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
    
    let oauthStateProvider: OAuthStateProviderProtocol
    let oauthConfigProvider: OAuthConfigProviderProtocol
    let alamofire: Alamofire.SessionManager
    
    var refreshQueue = [DispatchWorkItem]()
    var isRefreshing = false
    
    let AUTH_HEADER = "Authorization"
    
    private init(config: NetworkConfig) {
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
    public func addRequestToQueue<T: ResponseHandleableProtocol>(request: RequestPrototype<T>) {
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
    private func attemptUserAccessRequest<T: ResponseHandleableProtocol>(request: RequestPrototype<T>)
    {
        if (oauthStateProvider.userAccessIntended()) {
            makeRequest(requestObject: request)
            return
        }
        
        
        if (oauthStateProvider.userRefreshPossible()) {
            attemptUserAccessRefresh(request: request)
            return
        }
        
        request.getResponseHandler().getFailureCallback()(ForrestError.expiredCredentials, nil)
    }
    
    
    
    /**
     Attempts to make a request preferring user-level, but trying application-level if unavailable
     */
    private func attemptAnyAccessRequest<T: ResponseHandleableProtocol>(request: RequestPrototype<T>)
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
        failureHandler: @escaping (Error, DataResponse<Data>?) -> ()
    ) {
        let parser = oauthConfigProvider.getAppAuthParser()
        let persistSuccessHandler = { [weak self] (token: AccessToken) in
            do {
                try self?.oauthStateProvider.setAppAccessData(
                    token: token.getId(),
                    expiration: token.getExpiration())
                successHandler()
            } catch (let error) {
                failureHandler(error, nil)
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
                request.getResponseHandler().getFailureCallback()(error, nil)
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
        successHandler: @escaping ([String: AnyObject]?) -> (),
        failureHandler: @escaping (Error, DataResponse<Data>?) -> ()
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
                failureHandler(error, nil)
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
        refreshQueue.append(DispatchWorkItem { [weak self] in
            guard let `self` = self else {
                request.getResponseHandler().getFailureCallback()(ForrestError.refreshFailed, nil)
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
            
            guard let `self` = self else {
                request.getResponseHandler().getFailureCallback()(ForrestError.refreshFailed, nil)
                return
            }
            
            do {
                try self.oauthStateProvider.setUserAccessData(
                    token: response.userToken.id,
                    expiration: response.userToken.expiration)
                
                try self.oauthStateProvider.setUserRefreshData(
                    token: response.refreshToken.id,
                    expiration: response.refreshToken.expiration)
                
            } catch (let error) {
                request.getResponseHandler().getFailureCallback()(error, nil)
                self.refreshQueue.removeAll()
            }
            
            self.isRefreshing = false
            self.sendPendingRequests()
        }
        
        let refreshFailureHandler = { [weak self] (error: Error, response: DataResponse<Data>?) in
            
            guard let `self` = self else {
                request.getResponseHandler().getFailureCallback()(ForrestError.refreshFailed, nil)
                return
            }
            
            request.getResponseHandler().getFailureCallback()(error, nil)
            self.refreshQueue.removeAll()
        }
            
        let responseHandler = ResponseHandler<RefreshResponse>(
            parserClosure: parser.fromJson,
            successCallback: refreshSuccessHandler,
            failureCallback: refreshFailureHandler
        )
        
        let refreshRequest = RequestPrototype<ResponseHandler<RefreshResponse>>(
            type: .NoAuthRequired,
            method: .post,
            url: self.oauthConfigProvider.getRefreshEndpoint(),
            params: parser.toJson(token: self.oauthStateProvider.getUserRefreshData()?.token ?? ""),
            parameterEncoding: JSONEncoding.default,
            responseHandler: responseHandler
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
            .responseData(completionHandler: requestObject.getResponseHandler().handleResponse)
    }
    
    
    
    /**
     Attempts to retrieve the correct authorization header based on the request type
     */
    internal func getAuthorizationHeader(type: RequestType) -> String?
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
