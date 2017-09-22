//
//  MockService.swift
//  forrestTests
//
//  Created by Dan Gaffey on 9/21/17.
//  Copyright © 2017 UnchartedRealms. All rights reserved.
//

import Foundation
import Alamofire


struct MockService
{
    static let sharedInstance = MockService(
        httpClient: OAuthHttpClient.sharedInstance
    )
    
    let httpClient: OAuthHttpClient
    
    private init(httpClient: OAuthHttpClient)
    {
        self.httpClient = httpClient
    }
    
    
    
    /**
         Attempts to retrieve data from a REST endpoint without OAuth security
     */
    public func getNoAuthData(
        successHandler: @escaping (Any) -> (),
        failureHandler: @escaping (Any) -> ()
    ) {
        let request = RequestPrototype(
            type: RequestType.NoAuthRequired,
            method: .get,
            url: Endpoints.GET_NO_AUTH_DATA,
            params: nil,
            parameterEncoding: URLEncoding.default,
            responseCallback: { response in
                
                switch response.result {
                    
                    case .success(let data):
                        debugPrint(String(data: data, encoding: String.Encoding.utf8)!)
                        successHandler(data)
                        break
                    
                    case .failure(let error):
                        debugPrint(error)
                        failureHandler(error)
                        break
                }
            }
        )
        
        do {
            try httpClient.addRequestToQueue(request: request)
        } catch (let error) {
            debugPrint(error)
        }
    }
}
