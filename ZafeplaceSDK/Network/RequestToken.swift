//
//  RequestToken.swift
//  Vibe
//
//  Created by Z4
//Copyright © 2018 Dmitriy Zhyzhko. All rights reserved.
//

import Foundation

class RequestToken {
    private weak var task: URLSessionTask?

    init(task: URLSessionTask) {
        self.task = task
    }

    func cancel() {
        task?.cancel()
    }
}
