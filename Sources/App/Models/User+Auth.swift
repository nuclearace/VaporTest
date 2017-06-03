//
// Created by Erik Little on 5/21/17.
//

import AuthProvider
import Vapor

enum AuthError : Error {
    case badPassword
    case userNotFound
}

extension User : PasswordAuthenticatable {
    public class func authenticate(_ password: Password) throws -> User {
        guard let user = try User.makeQuery().filter(User.self, "username", .equals, password.username).first() else {
            throw AuthError.userNotFound
        }

        guard user.checkPassword(password.password) else { throw AuthError.badPassword }

        return user
    }

    private func checkPassword(_ password: String) -> Bool {
        let passwordComponents = pw.components(separatedBy: "$")

        guard passwordComponents.count == 2 else { return false }

        let (salt, hash) = (passwordComponents[0], passwordComponents[1])

        return hash == User.createSaltedHash(salt: salt, password: password)
    }

    func `is`(otherUser: User) -> Bool {
        return otherUser.id == id
    }
}

extension User: SessionPersistable { }

extension Request {
    func user() throws -> User {
        return try auth.assertAuthenticated(User.self)
    }
}
