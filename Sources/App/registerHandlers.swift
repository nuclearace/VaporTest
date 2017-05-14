//
// Created by Erik Little on 5/12/17.
//

import Auth
import Foundation
import HTTP
import Routing
import Vapor

private let error = Abort.custom(status: .forbidden, message: "Invalid credentials.")
private let protect = ProtectMiddleware(error: error)
private let pc = PostController()
private let uc = UserController()

func registerAPIs(droplet: Droplet) {
    droplet.grouped("api").grouped(protect).group("post") {postGroup in
        postGroup.post(handler: pc.create)
    }

    droplet.grouped("api").group("users") {userGroup in
        userGroup.grouped(protect).get(User.self, "posts", handler: uc.viewPosts)
        userGroup.post("new", handler: uc.create)
        userGroup.post("login", handler: uc.login)
        userGroup.post("logout", handler: uc.logout)
    }
}

func registerViews(droplet: Droplet) {
    droplet.group("post") {postGroup in
        postGroup.grouped(protect).get("create") {req in
            return try droplet.view.make("post.html")
        }
    }

    droplet.group("users") {userGroup in
        userGroup.get("new") {req in
            return try droplet.view.make("users/new.html")
        }

        userGroup.grouped(protect).get(User.self, "posts") {req, user in
            let posts = try uc.postsForUser(request: req, user: user)

            return try droplet.view.make("userPosts", [
                "posts": posts
            ])
        }

        userGroup.get("login") {req in
            guard req.user() == nil else {
                return Response(redirect: "/post/create")
            }

            return try droplet.view.make("users/login.html")
        }

        userGroup.grouped(protect).get("logout") {req in
            return try droplet.view.make("users/logout.html")
        }
    }
}

func registerWebSocket(droplet: Droplet) {
    droplet.socket("ws") {req, ws in
        try background {
            while ws.state == .open {
                try? ws.ping()
                drop.console.wait(seconds: 10)
            }
        }

        Gateway.shared.add(ws)

        ws.onClose = {ws, code, reason, clean in
            Gateway.shared.remove(ws)
        }
    }
}
