//
// Created by Erik Little on 5/12/17.
//

import Foundation
import Vapor
import Fluent
import FluentMySQL

struct AddUserToPosts : Preparation {
    static func prepare(_ database: Database) throws {
        try database.modify("posts") {post in
            post.parent(User.self)
        }
    }

    static func revert(_ database: Database) throws { }
}

struct AddTimestampToPosts : Preparation {
    static func prepare(_ database: Database) throws {
        try database.modify("posts") {post in
            post.datetime("timestamp", default: dateFormatter.string(from: Date()))
        }
    }

    static func revert(_ database: Database) throws { }
}
