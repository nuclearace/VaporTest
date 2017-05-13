//
// Created by Erik Little on 5/12/17.
//

import Foundation
import HTTP
import Routing
import Vapor

let pc = PostController()
let uc = UserController()

func registerAPIs(droplet: Droplet) {
    droplet.grouped("api").group("post") {postGroup in
        postGroup.post(handler: pc.create)
    }

    droplet.grouped("api").group("users") {userGroup in
        userGroup.get(User.self, "posts") {req, user in
            return try droplet.view.make("userPosts", [
                "posts": Node.array(try user.posts().map({ try $0.makeNode() }))
            ])
        }
    }
}

func registerViews(droplet: Droplet) {
    droplet.group("post") {postGroup in
        postGroup.get("create") {req in
            return try droplet.view.make("post.html")
        }
    }
}
