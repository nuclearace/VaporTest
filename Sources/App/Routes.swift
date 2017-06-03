import AuthProvider
import RedisProvider
import Sessions
import Vapor

private let passwordProtect = PasswordAuthenticationMiddleware<User>()

final class Routes: RouteCollection {
    let view: ViewRenderer

    init(_ view: ViewRenderer) {
        self.view = view
    }

    func build(_ builder: RouteBuilder) throws {
        builder.get {req in
            guard req.auth.isAuthenticated(User.self) else { return Response(redirect: "/users/login") }

            return Response(redirect: "/wall")
        }

        builder.grouped(passwordProtect).get("wall") {req in
            return try self.view.make("post.html")
        }

        builder.grouped("api").grouped(passwordProtect).group("post") {postGroup in
            postGroup.post(handler: PostController.create)
        }

        builder.grouped("api").group("users") {userGroup in
            userGroup.grouped(passwordProtect).get(User.parameter, "posts", handler: UserController.viewPosts)
            userGroup.post("new", handler: UserController.create)
            userGroup.grouped(passwordProtect).post("login", handler: UserController.login)
            userGroup.post("logout", handler: UserController.logout)
        }

        builder.group("users") {userGroup in
            userGroup.get("new") {req in
                return try self.view.make("users/new.html")
            }

            userGroup.grouped(passwordProtect).get(User.parameter, "posts") {req in
                let posts = try UserController.postsForUser(request: req)

                return try self.view.make("userPosts", [
                    "posts": posts
                ])
            }

            userGroup.get("login") {req in
                guard req.auth.authenticated(User.self) == nil else {
                    return Response(redirect: "/wall")
                }

                return try self.view.make("users/login.html")
            }

            userGroup.grouped(passwordProtect).get("logout") {req in
                return try self.view.make("users/logout.html")
            }
        }

        builder.socket("ws") {req, ws in
            Gateway.shared.add(ws)

            ws.onClose = {ws, code, reason, clean in
                Gateway.shared.remove(ws)
            }
        }
    }
}
