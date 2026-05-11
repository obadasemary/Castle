import Foundation
import SwiftData

public enum ModelContainerFactory {
    public static func production() throws -> ModelContainer {
        let schema = Schema(versionedSchema: CastleSchemaV1.self)
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        return try ModelContainer(
            for: schema,
            migrationPlan: CastleSchemaMigrationPlan.self,
            configurations: [configuration]
        )
    }

    public static func inMemory() throws -> ModelContainer {
        let schema = Schema(versionedSchema: CastleSchemaV1.self)
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        return try ModelContainer(
            for: schema,
            migrationPlan: CastleSchemaMigrationPlan.self,
            configurations: [configuration]
        )
    }
}
