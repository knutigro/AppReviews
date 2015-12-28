//
//  Timer.swift
//  App Reviews
//
//  Created by Knut Inge Grosland on 2015-04-17.
//  Copyright (c) 2015 Cocmoc. All rights reserved.
//

import Foundation

class Timer {
    
    /// Closure will be called every time the timer fires
    typealias Closure = (timer: Timer) -> ()
    
    /// Parameters
    let closure: Closure
    let queue: dispatch_queue_t
    var isSuspended: Bool = true
    
    /// The default initializer
    init(queue: dispatch_queue_t, closure: Closure) {
        self.queue = queue
        self.closure = closure
    }
    
    /// Suspend the timer before it gets destroyed
    deinit {
        suspend()
    }
    
    /// This timer implementation uses Grand Central Dispatch sources
    lazy var source: dispatch_source_t = {
        dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, self.queue)
        }()
    
    /// Convenience class method that creates and start a timer
    class func repeatEvery(repeatEvery: Double, closure: Closure) -> Timer {
        let timer = Timer(queue: dispatch_get_global_queue(0, 0), closure: closure)
        timer.resume(0, `repeat`: repeatEvery, leeway: 0)
        return timer
    }
    
    /// Fire the timer by calling its closure
    func fire() {
        closure(timer: self)
    }
    
    /// Start or resume the timer with the specified double values
    func resume(start: Double, `repeat`: Double, leeway: Double) {
        let NanosecondsPerSecond = Double(NSEC_PER_SEC)
        resume(Int64(start * NanosecondsPerSecond), `repeat`: UInt64(`repeat` * NanosecondsPerSecond), leeway: UInt64(leeway * NanosecondsPerSecond))
    }
    
    /// Start or resume the timer with the specified integer values
    func resume(start: Int64, `repeat`: UInt64, leeway: UInt64) {
        if isSuspended {
            let startTime = dispatch_time(DISPATCH_TIME_NOW, start)
            dispatch_source_set_timer(source, startTime, `repeat`, leeway)
            dispatch_source_set_event_handler(source) { [weak self] in
                if let timer = self {
                    timer.fire()
                }
            }
            dispatch_resume(source)
            isSuspended = false
        }
    }
    
    /// Suspend the timer
    func suspend() {
        if !isSuspended {
            dispatch_suspend(source)
            isSuspended = true
        }
    }
}
