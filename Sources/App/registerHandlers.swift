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
        userGroup.grouped(protect).get(User.self, "posts") {req, user in
            return try pc.viewPosts(request: req, user: user)
        }

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

        userGroup.get("login") {req in
            return try droplet.view.make("users/login.html")
        }

        userGroup.grouped(protect).get("logout") {req in
            return try droplet.view.make("users/logout.html")
        }
    }
}
