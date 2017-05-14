import Vapor
import HTTP

final class PostController : ResourceRepresentable {
    func clear(request: Request) throws -> ResponseRepresentable {
        throw Abort.custom(status: .notImplemented, message: "")
    }

    func create(request: Request) throws -> ResponseRepresentable {
        var post = try request.post()
        try post.save()

        Gateway.shared.post(message: try String(bytes: post.makePostMessage().serialize()))

        return post
    }

    func delete(request: Request, post: Post) throws -> ResponseRepresentable {
        try post.delete()

        return JSON([:])
    }

    func index(request: Request) throws -> ResponseRepresentable {
        return try Post.all().makeNode().converted(to: JSON.self)
    }

    func replace(request: Request, post: Post) throws -> ResponseRepresentable {
        try post.delete()

        return try create(request: request)
    }

    func show(request: Request, post: Post) throws -> ResponseRepresentable {
        return post
    }

    func update(request: Request, post: Post) throws -> ResponseRepresentable {
        let new = try request.post()
        var post = post
        post.content = new.content
        try post.save()

        return post
    }

    func makeResource() -> Resource<Post> {
        return Resource(
            index: index,
            store: create,
            show: show,
            replace: replace,
            modify: update,
            destroy: delete,
            clear: clear
        )
    }
}

extension Request {
    func post() throws -> Post {
        guard let body = body.bytes,
              let json = try? JSON(bytes: body),
              let content = json["content"]?.string,
              let user = user() else {
            throw Abort.badRequest
        }

        let trimmedContent = content.trimmingCharacters(in: .whitespaces)

        guard trimmedContent != "" else { throw Abort.badRequest }

        return Post(content: trimmedContent, user: user)
    }
}
