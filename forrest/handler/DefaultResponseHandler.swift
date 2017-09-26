//
//  DefaultResponseHandler.swift
//  forrest
//
//  Created by Daniel Gaffey on 9/24/17.
//  Copyright © 2017 UnchartedRealms. All rights reserved.
//

import Foundation
import Alamofire

class DefaultResponseHandler: DataResponseProtocol
{
    //Needs injected for specialty handler class... use generics!!!!
    
    func handleResponse(response: DataResponse<Data>)
    {
        switch response.result {
                
            case .success(let data):
                //track time using response.timeline object
//                guard let appToken = self?.oauthConfigProvider
//                    .getAppAuthParser()
//                    .fromJson(jsonData: data) else {
//                        failureHandler(OAuthError.parseError)
//                        return
//                }
                
                do {
//                    try self?.oauthStateProvider.setAppAccessData(
//                        token: appToken.getId(),
//                        expiration: appToken.getExpiration())
//                    successHandler()
                    
                } catch (let error) {
                   // failureHandler(error)
                }
                
                break
                
            case .failure(let error):
               // failureHandler(error)
                break
            }
    }
    
    
    
}
