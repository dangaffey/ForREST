//
//  OAuthHttpClient+Null.swift
//  ForREST
//
//  Created by Daniel Gaffey on 8/13/18.
//  Copyright © 2018 UnchartedRealms. All rights reserved.
//

import Foundation
import Alamofire

extension OAuthHttpClient {
    
    /**
     Routes a request to the correct attempt dispatch procedure
     */
    public func addRequestToQueue<T: NullResponseHandleableProtocol>(request: RequestPrototype<T>) {
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
    private func attemptUserAccessRequest<T: NullResponseHandleableProtocol>(request: RequestPrototype<T>)
    {
        if (oauthStateProvider.userAccessIntended()) {
            makeRequest(requestObject: request)
            return
        }
        
        
        if (oauthStateProvider.userRefreshPossible()) {
            attemptUserAccessRefresh(request: request)
            return
        }
        
        request.getResponseHandler().getFailureCallback()(ForRESTError.expiredCredentials)
    }
    
    
    
    /**
     Attempts to make a request preferring user-level, but trying application-level if unavailable
     */
    private func attemptAnyAccessRequest<T: NullResponseHandleableProtocol>(request: RequestPrototype<T>)
    {
        if (oauthStateProvider.userAccessIntended()) {
            attemptUserAccessRequest(request: request)
            return
        }
        
        attemptAppAccessRequest(request: request)
    }
    
    
    /**
     Executes requests through the Alamofire stack
     */
    internal func makeRequest<T: NullResponseHandleableProtocol>(requestObject: RequestPrototype<T>)
    {
        var headers = HTTPHeaders()
        let requestType = requestObject.getType()
        
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
     Attempts to refresh the access token for user-level access
     */
    private func attemptUserAccessRefresh<T: NullResponseHandleableProtocol>(request: RequestPrototype<T>)
    {
        refreshQueue.append(DispatchWorkItem { [weak self] in
            guard let `self` = self else {
                request.getResponseHandler().getFailureCallback()(ForRESTError.refreshFailed)
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
                request.getResponseHandler().getFailureCallback()(ForRESTError.refreshFailed)
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
                request.getResponseHandler().getFailureCallback()(error)
                self.refreshQueue.removeAll()
            }
            
            self.isRefreshing = false
            self.sendPendingRequests()
        }
        
        let refreshFailureHandler = { [weak self] (error: Error) in
            
            guard let `self` = self else {
                request.getResponseHandler().getFailureCallback()(ForRESTError.refreshFailed)
                return
            }
            
            request.getResponseHandler().getFailureCallback()(error)
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
     Attempts to execute an application level request
     */
    private func attemptAppAccessRequest<T: NullResponseHandleableProtocol>(request: RequestPrototype<T>)
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
    private func attemptAppAuthentication<T: NullResponseHandleableProtocol>(request: RequestPrototype<T>)
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
    
}
