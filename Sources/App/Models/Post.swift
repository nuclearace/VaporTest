import Vapor
import Fluent
import Foundation

final class Post: Model {
    var id: Node?
    var content: String
    var exists = false

    init(content: String) {
        self.id = nil
        self.content = content
    }

    init(node: Node, in context: Context) throws {
        id = try node.extract("id")
        content = try node.extract("content")
    }

    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "content": content
        ])
    }
}

extension Post: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create("posts") {post in
            post.id()
            post.string("content")
        }
    }

    static func revert(_ database: Database) throws {

    }
}
