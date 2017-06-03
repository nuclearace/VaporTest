import AuthProvider
import LeafProvider
import MySQLProvider
import FluentProvider
import RedisProvider

extension Config {
    public func setup() throws {
        // allow fuzzy conversions for these types
        // (add your own types here)
        Node.fuzzy = [JSON.self, Node.self]

        try setupProviders()
        try setupPreparations()
    }

    /// Configure providers
    private func setupProviders() throws {
        try addProvider(LeafProvider.Provider.self)
        try addProvider(AuthProvider.Provider.self)
        try addProvider(FluentProvider.Provider.self)
        try addProvider(RedisProvider.Provider.self)
        try addProvider(MySQLProvider.Provider.self)
    }

    private func setupPreparations() throws {
        let preps: [Preparation.Type] = [
            User.self,
            Post.self,
            AddTimestampToPost.self
        ]

        preparations += preps
    }
}
