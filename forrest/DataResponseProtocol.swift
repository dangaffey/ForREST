//
//  DataResponseProtocol.swift
//  forrest
//
//  Created by Daniel Gaffey on 9/24/17.
//  Copyright © 2017 UnchartedRealms. All rights reserved.
//

import Foundation
import Alamofire

protocol DataResponseProtocol
{
    func handleResponse(response: DataResponse<Data>) -> Void
}
