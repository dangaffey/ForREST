//
//  CachedUrlResponseExtensions.swift
//  ForRESTTests
//
//  Created by Dan Gaffey on 2/1/18.
//  Copyright © 2018 UnchartedRealms. All rights reserved.
//

import Foundation

extension CachedURLResponse {
    
    public convenience init?(
        url: URL?,
        statusCode: Int,
        httpVersion: String?,
        headerFields: [String : String]?,
        data: Data,
        userInfo: [AnyHashable : Any]? = nil,
        storagePolicy: URLCache.StoragePolicy) {
        
        guard let responseUrl = url,
            let updatedHeadersResponse = HTTPURLResponse(
                url: responseUrl,
                statusCode: statusCode,
                httpVersion: httpVersion,
                headerFields: headerFields) else {
            return nil
        }
        
        self.init(
            response: updatedHeadersResponse,
            data: data,
            userInfo: userInfo,
            storagePolicy: storagePolicy)
    }
    
}
