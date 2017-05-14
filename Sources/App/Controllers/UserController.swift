//
// Created by Erik Little on 5/12/17.
//

import Auth
import Foundation
import Vapor
import HTTP

final class UserController : ResourceRepresentable {
    func clear(request: Request) throws -> ResponseRepresentable {
        throw Abort.custom(status: .notImplemented, message: "Clearing users not supported")
    }

    func create(request: Request) throws -> ResponseRepresentable {
        var user = try request.rawUser()
        try user.save()
        try request.auth.login(Identifier(id: user.id!))

        return try user.makeJSON()
    }

    func delete(request: Request, user: User) throws -> ResponseRepresentable {
        throw Abort.custom(status: .notImplemented, message: "Deleting users not supported")
    }

    func index(request: Request) throws -> ResponseRepresentable {
        return try User.all().makeNode().converted(to: JSON.self)
    }

    func login(request: Request) throws -> ResponseRepresentable {
        guard let body = request.body.bytes,
              let json = try? JSON(bytes: body),
              let username = json["username"]?.string,
              let password = json["password"]?.string else {
            throw Abort.badRequest
        }

        try request.auth.login(APIKey(id: username, secret: password))

        return ""
    }

    func logout(request: Request) throws -> ResponseRepresentable {
        try request.auth.logout()

        return ""
    }

    func postsForUser(request: Request, user: User) throws -> Node {
        guard let reqUser = request.user() else { throw Abort.badRequest }

        guard user.is(otherUser: reqUser) else {
            throw Abort.custom(status: .forbidden, message: "You are not authorized to view this user's posts")
        }

        return try Node.array(user.posts().map({ try $0.makeNode() }))
    }

    func replace(request: Request, user: User) throws -> ResponseRepresentable {
        throw Abort.custom(status: .notImplemented, message: "Replacing users not supported")
    }

    func show(request: Request, user: User) throws -> ResponseRepresentable {
        return user
    }

    func update(request: Request, user: User) throws -> ResponseRepresentable {
        throw Abort.custom(status: .notImplemented, message: "Updating users not supported")
    }

    func viewPosts(request: Request, user: User) throws -> ResponseRepresentable {
        return try JSON(postsForUser(request: request, user: user))
    }

    func makeResource() -> Resource<User> {
        return Resource(
            index: index,
            store: create,
            show: show,
            replace: replace,
            modify: update,
            destroy: delete,
            clear: clear
        )
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
