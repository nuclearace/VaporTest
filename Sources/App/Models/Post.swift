import Vapor
import Fluent
import Foundation

final class Post : Model {
    var id: Node?
    var content: String
    var userId: Node
    var timestamp: Date

    var exists = false

    init(content: String, user: User) {
        self.id = nil
        self.content = content
        self.userId = user.id!
        self.timestamp = Date()
    }

    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        content = try node.extract("content")
        userId = try node.extract("user_id")

        if let unix = node["timestamp"]?.double {
            timestamp = Date(timeIntervalSince1970: unix)
        } else if let raw = node["timestamp"]?.string {
            guard let timestamp = dateFormatter.date(from: raw) else { throw PostError.dateNotSupported }

            self.timestamp = timestamp
        } else {
            throw PostError.dateNotSupported
        }
    }

    func makePostMessage() throws -> JSON {
        // TODO Move the API knowledge else where

        return try JSON(["type": 1, "message": makeNodeAnon()])
    }

    func makeNodeAnon() throws -> Node {
        return try Node(node: [
            "id": id,
            "content": content,
            "timestamp": dateFormatter.string(from: timestamp)
        ])
    }

    func makeNode() throws -> Node {
        return try Node(node: [
            "id": id,
            "content": content,
            "user_id": userId,
            "timestamp": dateFormatter.string(from: timestamp)
        ])
    }

    func makeNode(context: Context) throws -> Node {
        return try makeNode()
    }
}

extension Post : Preparation {
    static func prepare(_ database: Database) throws {
        try database.create("posts") {post in
            post.id()
            post.string("content")
        }
    }

    static func revert(_ database: Database) throws {

    }
}

enum PostError : Error {
    case dateNotSupported
}
