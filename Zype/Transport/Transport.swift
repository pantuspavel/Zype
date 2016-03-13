//
//  Transport.swift
//  Zype
//
//  Created by Pavel Pantus on 3/11/16.
//  Copyright © 2016 Pavel Pantus. All rights reserved.
//

import Foundation
import Alamofire
import CocoaLumberjack
import SwiftyJSON

final class Transport {
    static private let networkManager = Alamofire.Manager(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    static private let apiKey = "D5BkNoOibALG3frYyyLH8Q"
    static private let serverURI = "http://api.stg-jkay.zype.com/"
    
    static func postRequest(jsonController controller: String, parameters: [String: AnyObject], completionHandler: (data: [JSON]?, error: ErrorType?) -> Void) {
        var completeParams = parameters
        completeParams["api_key"] = apiKey
        
        debugPrint(">>> \(controller) : ", data: completeParams)
        
        networkManager.request(.GET, serverURI + controller + "/", parameters: completeParams)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success:
                    guard
                        let validData = response.data
                        else {
                            DDLogError("Response data in nil")
                            completionHandler(data: nil, error: NSError(domain: "Response data in nil", code: 0, userInfo: nil))
                            return
                    }
                    
                    self.debugPrint("<<< \(controller) : ", data: JSON(data: validData))
                    
                    let response = JSON(data: validData)["response"]
                    if let responseArray = response.array {
                        completionHandler(data: responseArray, error: nil)
                    } else {
                        completionHandler(data: nil, error: NSError(domain: "Invalid json data", code: 0, userInfo: nil))
                    }
                case .Failure(let error):
                    completionHandler(data: nil, error: error)
                }
        }
    }
    
    static private func debugPrint(prefix: String, data: CustomStringConvertible) -> Void {
        DDLogDebug(prefix + data.description.stringByReplacingOccurrencesOfString("\n", withString: "").stringByReplacingOccurrencesOfString("  ", withString: ""))
    }
}
