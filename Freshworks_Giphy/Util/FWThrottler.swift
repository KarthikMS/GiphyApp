//
//  FWThrottler.swift
//  Freshworks_Giphy
//
//  Created by Karthik Maharajan Skandarajah on 05/10/21.
//

import Foundation

final class FWThrottler {
    private let throttleDelay: TimeInterval
    private let throttleQueue: DispatchQueue

    private var lastFireDate = Date.distantPast
    private var workItem: DispatchWorkItem?

    init(throttleDelay: TimeInterval, throttleQueue: DispatchQueue) {
        self.throttleDelay = throttleDelay
        self.throttleQueue = throttleQueue
    }

    func throttle(_ block: @escaping () -> Void) {
        guard (workItem == nil) else { return }

        let workItem = DispatchWorkItem { [weak self] in
            self?.lastFireDate = Date()
            self?.workItem = nil
            block()
        }

        let delay = (lastFireDate.timeIntervalSinceNow > throttleDelay) ? 0 : throttleDelay
        throttleQueue.asyncAfter(deadline: .now() + delay, execute: workItem)
        self.workItem = workItem
    }
}
