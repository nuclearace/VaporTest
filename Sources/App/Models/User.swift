//
// Created by Erik Little on 5/21/17.
//

import Foundation
import FluentProvider
import CryptoSwift

public final class User : Model {
    public let email: String
    public let username: String

    let pw: String

    public let storage = Storage()

    public required init(row: Row) throws {
        email = try row.get("email")
        pw = try row.get("pw")
        username = try row.get("username")
    }

    init(username: String, email: String, password: String) {
        self.username = username
        self.email = email
        self.pw = User.createSaltedPassword(password: password)
    }

    public func makeRow() throws -> Row {
        var row = Row()

        try row.set("email", email)
        try row.set("pw", pw)
        try row.set("username", username)

        return row
    }

    func makeJSON() throws -> JSON {
        return JSON(["email": .string(email),
                     "username": .string(username)])
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
    public class func prepare(_ database: Database) throws {
        try database.create(User.self) {builder in
            builder.id()
            builder.string("email", length: 256)
            builder.string("pw", length: 512)
            builder.string("username", length: 30)
        }
    }

    public class func revert(_ database: Database) throws { }
}

extension User {
    var posts: Children<User, Post> {
        return children()
    }
}
