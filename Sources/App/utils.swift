//
// Created by Erik Little on 6/3/17.
//

import Dispatch
import Foundation
import RedisProvider

public let redisCache = try! RedisCache(hostname:"127.0.0.1", port: 6379)

private var _df: DateFormatter?

var dateFormatter: DateFormatter {
    if let df = _df {
        return df
    }

    let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd HH:mm:ss"
    _df = df

    return df
}

protocol Lockable {
    var lock: DispatchSemaphore { get }

    func protect(_ block: () -> ())
    func get<T>(_ block: @autoclosure () -> T) -> T
}

extension Lockable {
    func protect(_ block: () -> ()) {
        lock.wait()
        block()
        lock.signal()
    }

    func get<T>(_ block: @autoclosure () -> T) -> T {
        defer { lock.signal() }

        lock.wait()

        return block()
    }
}
