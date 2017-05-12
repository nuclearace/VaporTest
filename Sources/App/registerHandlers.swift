//
// Created by Erik Little on 5/12/17.
//

import Foundation
import HTTP
import Routing
import Vapor

let pc = PostController()

func registerAPIs(droplet: Droplet) {
    droplet.grouped("api").group("post") {postGroup in
        postGroup.post(handler: pc.create)
    }
}

func registerViews(droplet: Droplet) {
    droplet.group("post") {postGroup in
        postGroup.get("create") {req in
            return try droplet.view.make("post.html")
        }
    }
}
