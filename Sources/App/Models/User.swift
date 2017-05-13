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
        self.pw = User.createSaltedHash(password: password)
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

    static func createSaltedHash(password: String) -> String {
        let salt = UUID().uuidString.sha256()

        return salt + "$" + createSaltedPassword(salt: salt, password: password)
    }

    static func createSaltedPassword(salt: String, password: String) -> String {
        return (salt + password).sha3(.sha512)
    }

    func checkPassword(_ password: String) -> Bool {
        guard let pw = self.pw else { return false }

        let passwordComponents = pw.components(separatedBy: "$")

        guard passwordComponents.count == 2 else { return false }

        let (salt, hash) = (passwordComponents[0], passwordComponents[1])

        return hash == User.createSaltedPassword(salt: salt, password: password)
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

extension User : Auth.User {
    enum UserAuthError : Error {
        case badPass
        case notFound
    }

    private static func authenticate(username: String, password: String) throws -> User {
        guard let user = try User.query().filter(User.self, "username", .equals, username).first() else {
            throw UserAuthError.notFound
        }

        guard user.checkPassword(password) else { throw UserAuthError.badPass }

        return user
    }

    static func authenticate(credentials: Credentials) throws -> Auth.User {
        switch credentials {
        case let api as APIKey:
            return try authenticate(username: api.id, password: api.secret)
        case let ident as Identifier:
            guard let user = try User.find(ident.id) else { throw UserAuthError.notFound }

            return user
        default:
            throw AuthError.invalidCredentials
        }
    }

    static func register(credentials: Credentials) throws -> Auth.User {
        throw AuthError.invalidCredentials
    }
}

extension Request {
    func user() -> User? {
        guard let user = try? auth.user() as? User else { return nil }

        return user
    }
}
