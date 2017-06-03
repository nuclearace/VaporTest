//
// Created by Erik Little on 5/21/17.
//

import Foundation
import FluentProvider
import MySQLProvider

final class Post : Model, Timestampable {
    let content: String
    let poster: User

    let storage = Storage()

    required init(row: Row) throws {
        content = try row.get("content")
        poster = try User.find(row.get("user_id") as Int)!
    }

    init(content: String, user: User) {
        self.content = content
        self.poster = user
    }

    static func cacheKey(forUser user: User) throws -> String {
        return try "posts:\(user.id.converted(to: Int.self, in: nil))"
    }

    func makePostMessage() throws -> JSON {
        // TODO Move the API knowledge else where

        return try JSON(["type": 1, "message": makeJSONAnon()])
    }

    func makeJSONAnon() throws -> JSON {
        var fullJSON = try makeJSON()

        fullJSON["poster_id"] = nil

        return fullJSON
    }

    func makeJSON() throws -> JSON {
        let postId = try id.converted(to: Int.self, in: nil)
        let posterId = try poster.id.converted(to: Int.self, in: nil)

        return JSON(["id": .number(.int(postId)),
                     "poster_id": .number(.int(posterId)),
                     "content": .string(content),
                     "timestamp": .string(dateFormatter.string(from: createdAt!))
                    ])
    }

    func makeRow() throws -> Row {
        var row = Row()

        try row.set("content", content)
        try row.set("user_id", poster.id)

        return row
    }
}

extension Post : Preparation {
    class func prepare(_ database: Database) throws {
        try database.create(Post.self) {builder in
            builder.id()
            builder.foreignId(for: User.self)
            builder.longText("content")
        }
    }

    class func revert(_ database: Database) throws { }
}
