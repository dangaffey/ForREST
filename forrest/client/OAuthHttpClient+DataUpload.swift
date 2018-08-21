//
//  OAuthHttpClient+DataUpload.swift
//  ForREST
//
//  Created by Dan Gaffey on 1/10/18.
//  Copyright © 2018 UnchartedRealms. All rights reserved.
//

import Foundation
import Alamofire

extension OAuthHttpClient {
    
    /**
     Routes an upload to the correct attempt dispatch procedure
     */
    public func addUploadToQueue<T: ResponseHandleableProtocol & ErrorHandleableProtocol>(upload: DataUploadPrototype<T>) {
        switch upload.getType() {

        case .userAuthRequired:
            attemptUserAccessUpload(upload: upload)
            break

        case .appAuthRequired:
            attemptAppAccessUpload(upload: upload)
            break

        case .noAuthRequired:
            makeUpload(uploadObject: upload)
            break
        }
    }
    
    
    /**
     Attempts to execute an upload that requires a user-level access
     */
    private func attemptUserAccessUpload<T: ResponseHandleableProtocol & ErrorHandleableProtocol>(upload: DataUploadPrototype<T>) {
        if (oauthStateProvider.userAccessTokenValid()) {
            makeUpload(uploadObject: upload)
            return
        }
        
        
        if (oauthStateProvider.userRefreshTokenValid()) {
            attemptUserAccessRefresh(upload: upload)
            return
        }
        
        upload.getAggregatedHandler().handleError(ForRESTError(.expiredUserToken))
    }
    
    
    
    /**
     Attempts to execute an application level request
     */
    private func attemptAppAccessUpload<T: ResponseHandleableProtocol & ErrorHandleableProtocol>(upload: DataUploadPrototype<T>)
    {
        if (oauthStateProvider.appAccessTokenValid()) {
            makeUpload(uploadObject: upload)
            return
        }
        
        attemptAppAuthentication(upload: upload)
    }
    
    
    
    /**
     Attempts to broker a new application access token under a request
     */
    private func attemptAppAuthentication<T: ResponseHandleableProtocol & ErrorHandleableProtocol>(upload: DataUploadPrototype<T>)
    {
        let parser = oauthConfigProvider.getAppAuthParser()
        let persistSuccessHandler = { [weak self] (token: AccessToken) in
            do {
                try self?.oauthStateProvider.setAppAccessData(
                    token: token.getId(),
                    expiration: token.getExpiration())
                
                self?.makeUpload(uploadObject: upload)
                
            } catch (let error) {
                upload.getAggregatedHandler().handleError(ForRESTError(.appAuthFailed,  error: error))
            }
        }
        
        let entityHandler = EntityHandler<AccessToken>(
            parserClosure: parser.fromJson,
            successCallback: persistSuccessHandler,
            failureCallback: upload.getAggregatedHandler().handleError
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
     Attempts to refresh the access token for user-level access
     */
    private func attemptUserAccessRefresh<T: ResponseHandleableProtocol & ErrorHandleableProtocol>(upload: DataUploadPrototype<T>)
    {
        refreshQueue.append(DispatchWorkItem { [weak self] in
            guard let `self` = self else {
                upload.getAggregatedHandler().handleError(ForRESTError(.refreshFailed))
                return
            }
            self.makeUpload(uploadObject: upload)
        })
        
        if (isRefreshing) {
            return
        }
        isRefreshing = true
        
        let parser = self.oauthConfigProvider.getRefreshParser()
        
        let refreshSuccessHandler = { [weak self] (response: RefreshResponse) in
            
            guard let `self` = self else {
                upload.getAggregatedHandler().handleError(ForRESTError(.refreshFailed))
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
                upload.getAggregatedHandler().handleError(ForRESTError(.refreshFailed, error: error))
                self.refreshQueue.removeAll()
            }
            
            self.isRefreshing = false
            self.sendPendingRequests()
        }
        
        let refreshFailureHandler = { [weak self] (error: ForRESTError) in
            
            guard let `self` = self else {
                upload.getAggregatedHandler().handleError(ForRESTError(.refreshFailed))
                return
            }
            
            upload.getAggregatedHandler().handleError(error)
            self.refreshQueue.removeAll()
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
     Executes requests through the Alamofire stack
     */
    private func makeUpload<T: ResponseHandleableProtocol>(uploadObject: DataUploadPrototype<T>)
    {
        var headers = HTTPHeaders()
        let requestType = uploadObject.getType()
        
        headers["Content-Type"] = uploadObject.getContentType()
        
        if let authorizationHeader = getAuthorizationHeader(type: requestType) {
            headers["Authorization"] = String(format: "Bearer %@", authorizationHeader)
        }
        
        alamofire.upload(
            uploadObject.getData(),
            to: uploadObject.getUrl(),
            method: uploadObject.getMethod(),
            headers: headers)
            .responseData(completionHandler: uploadObject.getAggregatedHandler().handleResponse)
    }
}
