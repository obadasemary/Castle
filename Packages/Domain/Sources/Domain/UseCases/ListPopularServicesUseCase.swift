public struct ListPopularServicesUseCase: Sendable {
    private let catalog: any PopularServicesCatalog

    public init(catalog: any PopularServicesCatalog) {
        self.catalog = catalog
    }

    public func execute(query: String = "") async throws -> [PopularService] {
        let all = try await catalog.fetchAll()
        guard !query.isEmpty else { return all }
        let lowercased = query.lowercased()
        return all.filter { $0.name.lowercased().contains(lowercased) }
    }
}
