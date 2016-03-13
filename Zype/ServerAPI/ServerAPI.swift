//
//  ServerAPI.swift
//  Zype
//
//  Created by Pavel Pantus on 3/11/16.
//  Copyright © 2016 Pavel Pantus. All rights reserved.
//

import Foundation

final class ServerAPI {
    static private let queue = NSOperationQueue()
    
    static private func scheduleOperation(operation: AsyncOperation) {
        queue.addOperations([operation], waitUntilFinished: false)
    }
    
    // MARK: Public API
    
    static func selectVideos(page page: Int, completionHandler: (count: Int, error: ErrorType?) -> Void) {
        let operation = SelectVideosOperation(page: page) { (videos, error) in
            var count = 0
            if error == nil {
                if let videos = videos {
                    videos.forEach { VideosModel.sharedInstance.addEntity($0) }
                    count = videos.count
                }
            }
            completionHandler(count: count, error: error)
        }
        scheduleOperation(operation)
    }
}