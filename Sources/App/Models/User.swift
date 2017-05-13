//
// Created by Erik Little on 5/12/17.
//

import Fluent
import Foundation
import Vapor

final class User : Model {
    var id: Node?
    var username = ""
    var email = ""

    var exists = false

    init(username: String, email: String) {
        self.id = nil
        self.username = username
        self.email = email
    }

    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        username = try node.extract("username")
        email = try node.extract("email")
    }

    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "username": username,
            "email": email
        ])
    }
}

extension User : Preparation {
    static func prepare(_ database: Database) throws {
        try database.create("users") {user in
            user.id()
            user.string("username")
            user.string("email")
        }
    }

    static func revert(_ database: Database) throws { }
}
