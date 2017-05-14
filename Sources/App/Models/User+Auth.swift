//
// Created by Erik Little on 5/13/17.
//

import Auth
import Foundation
import HTTP
import Vapor

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

    private func checkPassword(_ password: String) -> Bool {
        guard let pw = self.pw else { return false }

        let passwordComponents = pw.components(separatedBy: "$")

        guard passwordComponents.count == 2 else { return false }

        let (salt, hash) = (passwordComponents[0], passwordComponents[1])

        return hash == User.createSaltedHash(salt: salt, password: password)
    }

    func `is`(otherUser: User) -> Bool {
        return otherUser.id == id
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
