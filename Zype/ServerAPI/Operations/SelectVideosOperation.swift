//
//  SelectVideosOperation.swift
//  Zype
//
//  Created by Pavel Pantus on 3/11/16.
//  Copyright © 2016 Pavel Pantus. All rights reserved.
//

import SwiftyJSON

final class SelectVideosOperation: AsyncOperation {
    init(page: Int, completionHandler: ((videos: [TVideo]?, error: ErrorType?) -> Void)?) {
        let parameters = [ "page": page ]
        
        let completionClosure : ([JSON]?, ErrorType?) -> Void = { (data, error) -> Void in
            guard
                error == nil,
                let dataArray = data
                else {
                    completionHandler?(videos: nil, error: error)
                    return
            }

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
                let parsedVideos = dataArray.flatMap { TVideo.init(json: $0) }
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler?(videos: parsedVideos, error: nil)
                }
            }
        }
        
        super.init(controller: "videos", parameters: parameters, completionClosure: completionClosure)
    }
}
