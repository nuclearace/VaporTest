//
// Created by Erik Little on 6/3/17.
//

import AuthProvider
import Foundation
import Vapor

final class UserController {
    static func create(request: Request) throws -> ResponseRepresentable {
        let user = try request.rawUser()
        try user.save()

        try request.auth.authenticate(user, persist: true)

        return try user.makeJSON()
    }

    static func login(request: Request) throws -> ResponseRepresentable {
        _ = try request.auth.assertAuthenticated(User.self)

        return ""
    }

    static func logout(request: Request) throws -> ResponseRepresentable {
        try request.auth.unauthenticate()

        return ""
    }

    static func postsForUser(request: Request) throws -> JSON {
        guard let reqUser = try? request.auth.assertAuthenticated(User.self) else { throw Abort.badRequest }
        let user = try request.parameters.next(User.self)

        guard user.is(otherUser: reqUser) else {
            throw Abort(.forbidden, reason: "You are not authorized to view this user's posts")
        }

        let cacheKey = try Post.cacheKey(forUser: user)

        if let cachedPosts = try redisCache.get(cacheKey) {
            return JSON(node: cachedPosts)
        }

        let userPosts = try user.posts.all().map({ try $0.makeJSON() })

        try redisCache.set(cacheKey, userPosts, expiration: Date(timeIntervalSinceNow: 30))

        return .array(userPosts)
    }

    static func viewPosts(request: Request) throws -> ResponseRepresentable {
        return try JSON(postsForUser(request: request))
    }
}

extension Request {
    func rawUser() throws -> User {
        guard let body = body.bytes,
              let json = try? JSON(bytes: body),
              let username = json["username"]?.string,
              let email = json["email"]?.string,
              let password = json["password"]?.string else {
            throw Abort.badRequest
        }

        return User(username: username, email: email, password: password)
    }
}
