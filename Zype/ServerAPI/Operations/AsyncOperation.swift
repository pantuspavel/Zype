//
//  AsyncOperation.swift
//  Zype
//
//  Created by Pavel Pantus on 3/11/16.
//  Copyright © 2016 Pavel Pantus. All rights reserved.
//

import Foundation
import SwiftyJSON

class AsyncOperation : NSOperation {
    private var _executing = false
    private var _finished = false
    private let controller : String
    private let parameters : [String: AnyObject]
    var completionClosure: (([JSON]?, ErrorType?) -> Void)?
    
    init(controller: String, parameters: [String: AnyObject], completionClosure: (([JSON]?, ErrorType?) -> Void)?) {
        self.controller = controller
        self.parameters = parameters
        self.completionClosure = completionClosure
    }
    
    override var executing: Bool {
        get { return _executing }
        set {
            willChangeValueForKey("isExecuting")
            _executing = newValue
            didChangeValueForKey("isExecuting")
        }
    }
    
    override var finished: Bool {
        get { return _finished }
        set {
            willChangeValueForKey("isFinished")
            _finished = newValue
            didChangeValueForKey("isFinished")
        }
    }
    
    override var asynchronous: Bool {
        get { return true }
    }
    
    override final func start() {
        super.start()
        
        if cancelled {
            finished = true
            return
        }
        
        executing = true
        
        Transport.postRequest(jsonController: controller, parameters: parameters) { (data, error) -> Void in
            if self.cancelled {
                self.executing = false
                self.finished = true
                return
            }
            
            self.completionClosure?(data, error)
            
            self.executing = false
            self.finished = true
        }
    }
}
