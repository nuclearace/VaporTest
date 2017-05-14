import Auth
import VaporRedis
import HTTP
import Vapor
import VaporMySQL

let redis = try RedisCache(address: "127.0.0.1", port: 6379)
let drop = Droplet()
let auth = AuthMiddleware(user: User.self, cache: redis)

drop.middleware.append(auth)
try drop.addProvider(VaporMySQL.Provider.self)

drop.preparations.append(Post.self)
drop.preparations.append(User.self)
drop.preparations.append(AddUserToPosts.self)
drop.preparations.append(AddPasswordFieldToUser.self)
drop.preparations.append(AddTimestampToPosts.self)

drop.get {req in
    if req.user() == nil {
        return Response(redirect: "/users/login")
    } else {
        return Response(redirect: "/wall")
    }
}

registerAPIs(droplet: drop)
registerViews(droplet: drop)
registerWebSocket(droplet: drop)

drop.run()
