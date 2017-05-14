//
// Created by Erik Little on 5/12/17.
//

import Auth
import CryptoSwift
import Fluent
import Foundation
import HTTP
import Vapor

final class User : Model {
    var id: Node?
    var username = ""
    var email = ""
    var pw: String? = nil

    var exists = false

    init(username: String, email: String, password: String) {
        self.id = nil
        self.username = username
        self.email = email
        self.pw = User.createSaltedPassword(password: password)
    }

    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        username = try node.extract("username")
        email = try node.extract("email")
        pw = try node.extract("pw")
    }

    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "username": username,
            "email": email,
            "pw": pw
        ])
    }

    func makeJSON() throws -> JSON {
        return JSON(["id": id!,
                     "username": .string(username),
                     "email": .string(email)])
    }

    static func createSaltedPassword(password: String) -> String {
        let salt = UUID().uuidString.sha256()

        return salt + "$" + createSaltedHash(salt: salt, password: password)
    }

    static func createSaltedHash(salt: String, password: String) -> String {
        return (salt + password).sha3(.sha512)
    }
}

extension User : Preparation {
    static func prepare(_ database: Database) throws {
        try database.create("users") {user in
            user.id()
            user.string("username", unique: true)
            user.string("email", unique: true)
        }
    }

    static func revert(_ database: Database) throws { }
}

extension User {
    func posts() throws -> [Post] {
        return try children("user_id", Post.self).all()
    }
}
