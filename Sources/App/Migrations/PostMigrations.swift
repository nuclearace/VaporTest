//
// Created by Erik Little on 6/3/17.
//

import Foundation
import FluentProvider
import MySQLProvider

struct AddTimestampToPost : Preparation {
    static func prepare(_ database: Database) throws {
        try database.modify(Post.self) {posts in
            posts.date(Post.createdAtKey)
            posts.date(Post.updatedAtKey)
        }
    }

    static func revert(_ database: Database) throws { }
}
