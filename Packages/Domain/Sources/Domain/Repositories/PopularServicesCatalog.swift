public protocol PopularServicesCatalog: Sendable {
    func fetchAll() async throws -> [PopularService]
}
