//
// Created by Erik Little on 5/12/17.
//

import Foundation
import Vapor
import Fluent

struct AddUserToPosts : Preparation {
    static func prepare(_ database: Database) throws {
        try database.modify("posts") {post in
            post.parent(User.self)
        }
    }

    static func revert(_ database: Database) throws { }
}
