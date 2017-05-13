//
// Created by Erik Little on 5/13/17.
//

import Dispatch
import Foundation
import Vapor

final class Gateway : Lockable {
    static let shared = Gateway()

    let lock = DispatchSemaphore(value: 1)

    private let queue = DispatchQueue(label: "GatewayQueue")
    private var sockets = [WebSocket]()

    func add(_ socket: WebSocket) {
        protect {
            sockets.append(socket)
        }
    }

    func post(message: String) {
        queue.async {
            let sockets = self.get(self.sockets)

            for socket in sockets {
                do {
                    try socket.send(message)
                } catch {
                    drop.console.error("Error sending post \(message)")
                }
            }
        }
    }

    func remove(_ socket: WebSocket) {
        protect {
            sockets = sockets.filter({ $0 !== socket })
        }
    }
}
