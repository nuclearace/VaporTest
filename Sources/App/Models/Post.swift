import Vapor
import Fluent
import Foundation

final class Post : Model {
    var id: Node?
    var content: String
    var userId: Node

    var exists = false

    init(content: String, user: User) {
        self.id = nil
        self.content = content
        self.userId = user.id!
    }

    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        content = try node.extract("content")
        userId = try node.extract("user_id")
    }

    func makeNode() throws -> Node {
        return try Node(node: [
            "id": id,
            "content": content,
            "user_id": userId
        ])
    }

    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "content": content,
            "user_id": userId
        ])
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
