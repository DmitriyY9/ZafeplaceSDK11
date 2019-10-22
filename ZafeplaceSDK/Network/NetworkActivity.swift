//
//  NetworkActivity.swift
//  Vibe
//
//  Created by Z4
//Copyright © 2018 Dmitriy Zhyzhko. All rights reserved.
//

import UIKit


struct NetworkActivity {
    private static var loadingCount = 0
    private static var lock = NSLock()

    static func started() {

        // Thread save
        lock.lock(); defer { lock.unlock() }

        // Increase counter
        if loadingCount == 0 {
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
            }
        }
        loadingCount += 1
    }

    static func finished() {

        // Thread save
        lock.lock(); defer { lock.unlock() }


        // Decrease counter
        if loadingCount > 0 {
            loadingCount -= 1
        }
        if loadingCount == 0 {
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }

        }
    }
}
