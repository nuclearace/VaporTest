//
// Created by Erik Little on 6/3/17.
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

        pingSocket(socket)
    }

    func pingSocket(_ socket: WebSocket) {
        protect {
            guard sockets.contains(where: { $0 === socket}) else { return }

            do {
                try socket.ping()
            } catch {
                print("Error pinging socket")
            }

            queue.asyncAfter(deadline: DispatchTime.now() + 10) {
                self.pingSocket(socket)
            }
        }
    }

    func post(message: String) {
        print("sending message")

        queue.async {
            let sockets = self.get(self.sockets)

            for socket in sockets {
                do {
                    try socket.send(message)
                } catch {
                    print("Error")
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
