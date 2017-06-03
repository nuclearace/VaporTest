import Foundation
import Vapor
import HTTP


final class PostController {
    static func create(request: Request) throws -> ResponseRepresentable {
        let post = try request.post()
        try post.save()

         Gateway.shared.post(message: try String(bytes: post.makePostMessage().serialize()))

        return try post.makeJSON()
    }
}

extension Request {
    func post() throws -> Post {
        guard let body = body.bytes,
              let json = try? JSON(bytes: body),
              let content = json["content"]?.string,
              let user = try? user() else {
            throw Abort.badRequest
        }

        let trimmedContent = content.trimmingCharacters(in: .whitespaces)

        guard trimmedContent != "" else { throw Abort.badRequest }

        return Post(content: trimmedContent, user: user)
    }
}
